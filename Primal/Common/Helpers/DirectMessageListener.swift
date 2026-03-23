//
//  DirectMessageListener.swift
//  Primal
//
//  Subscribes directly to a chat partner's write relays for kind:4
//  (NIP-04) events to supplement the cache server with faster
//  real-time DM delivery.
//

import Foundation
import Combine
import GenericJSON

final class DirectMessageListener {

    private let userPubkey: String
    private let chatPartnerPubkey: String

    private var relayConnections: [RelayDMConnection] = []

    private var cancellables: Set<AnyCancellable> = []

    let newMessages = PassthroughSubject<[ProcessedMessage], Never>()

    init(chatPartnerPubkey: String) {
        self.chatPartnerPubkey = chatPartnerPubkey
        self.userPubkey = IdentityManager.instance.userHexPubkey
    }

    deinit {
        disconnect()
    }

    func connect() {
        SocketRequest(name: "get_user_relays_2", payload: ["pubkeys": [.string(chatPartnerPubkey)]]).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }

                var relays = result.relayData.filter({ $0.value.write }).map({ $0.key })
                if relays.isEmpty {
                    relays = Array(bootstrap_relays.prefix(3))
                }

                for urlString in relays.prefix(3) {
                    guard let url = URL(string: urlString) else { continue }

                    let connection = RelayDMConnection(
                        relayURL: url,
                        userPubkey: self.userPubkey,
                        chatPartnerPubkey: self.chatPartnerPubkey,
                        newMessages: self.newMessages
                    )
                    self.relayConnections.append(connection)
                    connection.connect()
                }
            }
            .store(in: &cancellables)
    }

    func disconnect() {
        cancellables = []
        for connection in relayConnections {
            connection.disconnect()
        }
        relayConnections = []
    }
}

// MARK: - Per-Relay Connection

private final class RelayDMConnection: NSObject, URLSessionWebSocketDelegate {

    private let relayURL: URL
    private let userPubkey: String
    private let chatPartnerPubkey: String
    private let newMessages: PassthroughSubject<[ProcessedMessage], Never>

    private var task: URLSessionWebSocketTask?
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
    private let delegateQueue = OperationQueue()
    private var subId: String?
    private var isDisconnected = true
    private var retryCount = 0
    private static let maxRetries = 3

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    init(relayURL: URL, userPubkey: String, chatPartnerPubkey: String, newMessages: PassthroughSubject<[ProcessedMessage], Never>) {
        self.relayURL = relayURL
        self.userPubkey = userPubkey
        self.chatPartnerPubkey = chatPartnerPubkey
        self.newMessages = newMessages
        super.init()
        delegateQueue.maxConcurrentOperationCount = 1
    }

    func connect() {
        delegateQueue.addOperation { [weak self] in
            guard let self else { return }
            self.isDisconnected = false
            self.retryCount = 0
            self.startTask()
        }
    }

    func disconnect() {
        // Strong self so cleanup completes even if the parent releases us
        delegateQueue.cancelAllOperations()
        delegateQueue.addOperation {
            self.isDisconnected = true
            self.subId = nil
            self.task?.cancel(with: .normalClosure, reason: nil)
            self.task = nil
            self.session.finishTasksAndInvalidate()
        }
    }

    // MARK: - URLSessionWebSocketDelegate

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol proto: String?) {
        guard !isDisconnected else { return }
        retryCount = 0
        subscribe()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        guard !isDisconnected else { return }
        reconnectIfNeeded()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !isDisconnected, error != nil else { return }
        reconnectIfNeeded()
    }

    // MARK: - Private

    private func startTask() {
        task?.cancel(with: .normalClosure, reason: nil)
        let newTask = session.webSocketTask(with: relayURL)
        task = newTask
        newTask.resume()
        receiveNext()
    }

    private func reconnectIfNeeded() {
        retryCount += 1
        guard retryCount <= Self.maxRetries else { return }
        delegateQueue.schedule(after: .init(Date(timeIntervalSinceNow: 2))) { [weak self] in
            guard let self, !self.isDisconnected else { return }
            self.startTask()
        }
    }

    private func receiveNext() {
        task?.receive { [weak self] result in
            guard let self, !self.isDisconnected else { return }

            switch result {
            case .success(let message):
                if case .string(let string) = message {
                    self.processMessage(string)
                }
                self.receiveNext()
            case .failure:
                self.reconnectIfNeeded()
            }
        }
    }

    private func subscribe() {
        let id = "dm_\(UUID().uuidString.prefix(8))"
        subId = id

        let filter: JSON = .object([
            "kinds": .array([.number(4)]),
            "#p": .array([.string(userPubkey)]),
            "authors": .array([.string(chatPartnerPubkey)]),
            "since": .number(Double(Int(Date().timeIntervalSince1970)))
        ])

        let req: JSON = .array([.string("REQ"), .string(id), filter])

        guard let data = try? jsonEncoder.encode(req), let str = String(data: data, encoding: .utf8) else { return }
        task?.send(.string(str)) { _ in }
    }

    private func sendClose(_ id: String) {
        let close: JSON = .array([.string("CLOSE"), .string(id)])
        guard let data = try? jsonEncoder.encode(close), let str = String(data: data, encoding: .utf8) else { return }
        task?.send(.string(str)) { _ in }
    }

    private func processMessage(_ string: String) {
        guard
            let json: JSON = try? jsonDecoder.decode(JSON.self, from: Data(string.utf8)),
            let type = json.arrayValue?.first?.stringValue,
            type == "EVENT",
            let eventJSON = json.arrayValue?[safe: 2]?.objectValue,
            let kind = eventJSON["kind"]?.doubleValue, Int(kind) == NostrKind.encryptedDirectMessage.rawValue,
            let pubkey = eventJSON["pubkey"]?.stringValue,
            let id = eventJSON["id"]?.stringValue,
            let content = eventJSON["content"]?.stringValue,
            let createdAt = eventJSON["created_at"]?.doubleValue,
            let recipientPubkey = eventJSON["tags"]?.arrayValue?.first(where: { $0.arrayValue?.first?.stringValue == "p" })?.arrayValue?[safe: 1]?.stringValue
        else { return }

        guard
            let loginInfo = ICloudKeychainManager.instance.getLoginInfo()?.hexVariant,
            let privkey = loginInfo.privkey
        else { return }

        let otherPubkey = pubkey == loginInfo.pubkey ? recipientPubkey : pubkey

        guard var message = decryptDirectMessage(content, privkey: privkey, pubkey: otherPubkey) else { return }

        let invoices = message.extractInvoices()
        for invoice in invoices {
            message = message.replacingOccurrences(of: invoice.string, with: "")
        }
        message = message.trimmingCharacters(in: .whitespacesAndNewlines)

        let user = ParsedUser(data: .init(pubkey: pubkey))
        let date = Date(timeIntervalSince1970: createdAt)

        var result: [ProcessedMessage] = invoices.map {
            .init(id: id, user: user, date: date, message: .invoice($0), status: .sent)
        }

        if !message.isEmpty {
            result.insert(.init(id: id, user: user, date: date, message: .text(message), status: .sent), at: 0)
        }

        if !result.isEmpty {
            DispatchQueue.main.async {
                self.newMessages.send(result)
            }
        }
    }
}
