//
//  Connection.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation
import Combine
import Network
import GenericJSON

class ContinousConnection {
    let id: String
    private weak var connection: Connection?
    
    init(id: String, connection: Connection) {
        self.id = id
        self.connection = connection
    }
    
    func end() {
        connection?.endContinous(id)
    }
    
    deinit {
        end()
    }
}

final class Connection {
    // MARK: - Static
    
    static var dispatchQueue = DispatchQueue(label: "com.primal.connection")
    
    static let regular = Connection(socketURL: PrimalEndpointsManager.regularURL)
    static let wallet = Connection(socketURL: PrimalEndpointsManager.walletURL)
    
    private static func connect() {
        regular.connect()
        wallet.connect()
    }
    
    private static func disconnect() {
        regular.disconnect()
        wallet.disconnect()
    }
    
    static func reconnect() {
        disconnect()
        
        regular.timeToReconnect = 2
        wallet.timeToReconnect = 2
        
        dispatchQueue = .init(label: "connection-\(UUID().uuidString.prefix(15))")
        
        connect()
    }
    
    // MARK: - Class
    
    @Published var socketURL: URL {
        didSet {
            disconnect()
            connect()
        }
    }
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var socket: WebSocket
    private var subHandlers: [String: ([JSON]) -> Void] = [:]
    private var responseBuffer: [String: [JSON]] = [:]
    
    private var continousSubHandlers: [String: (JSON) -> Void] = [:]
    
    private var timeToReconnect: Int = 1
    
    init(socketURL: URL) {
        socket = WebSocket(socketURL, session: URLSession(configuration: .default))
        self.socketURL = socketURL
        self.connect()
        
        isConnectedPublisher.dropFirst().sink { isConnected in
            print("CONNECTION IS CONNECTED \(self === Connection.regular ? "REG" : "WALL") = \(isConnected)")
        }
        .store(in: &cancellables)
        
        messageReceived
            .debounce(for: 10, scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: \.isConnected, onWeak: self)
            .store(in: &cancellables)
    }
    
    deinit {
        socket.disconnect()
    }
    
    var cancellables: Set<AnyCancellable> = []
    var socketResponse: AnyCancellable?
    
    var messageReceived = PassthroughSubject<Void, Never>()

    var cantConnectPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            isConnectedPublisher.filter({ $0 }),
            isConnectedPublisher.debounce(for: 10, scheduler: RunLoop.main).filter({ !$0 })
        )
        .map({ !$0 })
        .eraseToAnyPublisher()
    }
    let isConnectedPublisher = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var isConnected: Bool = false {
        didSet {
            if oldValue != isConnected {
                isConnectedPublisher.send(isConnected)
            }
        }
    }
    
    private func connect() {
        disconnect()
        
        socket = WebSocket(socketURL, session: URLSession(configuration: .default))
        
        socketResponse = socket.subject.receive(on: Self.dispatchQueue).sink { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .connected:
                isConnected = true
                messageReceived.send(())
            case .message(let message):
                isConnected = true
                switch message {
                case .string(let string):
                    guard let json: JSON = string.decode() else { return }
                    processMessage(json)
                case .data(var data):
                    do {
                        data.removeFirst(2) // REMOVE HEADER
                        let decompressedData = try (data as NSData).decompressed(using: .zlib) as Data
                        let json: JSON = try JSONDecoder().decode(JSON.self, from: decompressedData)
                        processBulkMessage(json)
                    } catch {
                        print("HEX DATA ERROR: \(error)")
                    }
                @unknown default:
                    return
                }
                messageReceived.send(())
            case .disconnected(_, _):
                isConnected = false
            case .error(_):
                isConnected = false
            }
        }
        
        socket.connect()
        
        DispatchQueue.main.async {
            SocketRequest(name: "set_primal_protocol", payload: ["compression": "zlib"])
                .publisher()
                .sink(receiveValue: { result in
                    print(result)
                })
                .store(in: &self.cancellables)
        }
    }
    
    private func disconnect() {
        socketResponse = nil
        socket.disconnect()
        isConnected =  false
    }
    
    func requestWallet(_ content: String, _ handler: @escaping (_ result: [JSON]) -> Void) {
        guard let walletEvent = NostrObject.wallet(content) else { return }
        requestCache(name: "wallet", payload: ["operation_event": walletEvent.toJSON()], handler)
    }
    
    func requestCache(name: String, payload: JSON?, _ handler: @escaping (_ result: [JSON]) -> Void) {
        if let payload {
            request(.object(["cache" : .array([.string(name), payload])]), handler)
        } else {
            request(.object(["cache" : .array([.string(name)])]), handler)
        }
    }
    
    func request(_ request: JSON, _ handler: @escaping (_ result: [JSON]) -> Void) {        
        let subId = "ios_" + UUID().uuidString
        let json: JSON = .array([.string("REQ"), .string(subId), request])
        Self.dispatchQueue.async {
            guard let jsonData = try? self.jsonEncoder.encode(json) else {
                print("Error encoding req json")
                return
            }
            let jsonStr = String(data: jsonData, encoding: .utf8)!
                 
            print("REQUEST:\n\(jsonStr)")
            self.responseBuffer[subId] = .init()
            self.subHandlers[subId] = handler
            self.socket.send(.string(jsonStr))
        }
    }
    
    
    func requestCacheContinous(name: String, request: JSON?, _ handler: @escaping (JSON) -> Void) -> ContinousConnection {
        if let request {
            return requestContinous(.object([
                "cache" : .array(
                    [.string(name), request]
                )
            ]), subId: "\(name)-\(UUID().uuidString)", handler)
        } else {
            return requestContinous(.object([
                "cache" : .array([.string(name)])
            ]), subId: "\(name)-\(UUID().uuidString)", handler)
        }
    }
    
    func requestContinous(_ request: JSON, subId: String = UUID().uuidString, _ handler: @escaping (JSON) -> Void) -> ContinousConnection {
        let json: JSON = .array([.string("REQ"), .string(subId), request])
        Self.dispatchQueue.async {
            guard let jsonData = try? self.jsonEncoder.encode(json) else {
                print("Error encoding req json")
                return
            }
            let jsonStr = String(data: jsonData, encoding: .utf8)!
                 
            print("REQUEST:\n\(jsonStr)")

            self.continousSubHandlers[subId] = handler
            self.socket.send(.string(jsonStr))
        }
        return .init(id: subId, connection: self)
    }
    
    func endContinous(_ id: String) {
        let json = JSON.array([.string("CLOSE"), .string(id)])
        Self.dispatchQueue.async {
            guard let jsonData = try? self.jsonEncoder.encode(json) else {
                print("Error encoding req json")
                return
            }
            let jsonStr = String(data: jsonData, encoding: .utf8)!
                 
//            print("REQUEST:\n\(jsonStr)")
            self.continousSubHandlers[id] = nil
            self.socket.send(.string(jsonStr))
        }
    }
    
    private func processBulkMessage(_ json: JSON) {
        guard
            let subId = json.arrayValue?[safe: 1]?.stringValue,
            let arrayOfMessages = json.arrayValue?[safe: 2]?.arrayValue,
            let handler = subHandlers[subId]
        else {
            print("error getting subId or array of bulk")
            return
        }
        
        handler(arrayOfMessages)
        responseBuffer[subId] = nil
        subHandlers[subId] = nil
    }
    
    private func processMessage(_ json: JSON) {
        guard
            let subId = json.arrayValue?[safe: 1]?.stringValue,
            let type = json.arrayValue?.first
        else {
            print("error getting subId and/or type")
            return
        }
        
        if type == "EOSE" {
            if let handler = subHandlers[subId], let b = responseBuffer[subId] {
                handler(b)
            }
            responseBuffer[subId] = nil
            subHandlers[subId] = nil
        } else {
            if let interestingJSON = json.arrayValue?[safe: 2] {
                responseBuffer[subId]?.append(interestingJSON)
            }
            continousSubHandlers[subId]?(json)
        }
    }
    
    func autoConnectReset() {
        Self.dispatchQueue.async {
            self.timeToReconnect = 1
            
            self.autoReconnect()
        }
    }
    
    var isReconnecting = false
    private func autoReconnect() {
        if isConnected {
            timeToReconnect = 1
            return
        }
        
        if isReconnecting { return }
        
        isReconnecting = true
        Self.dispatchQueue.asyncAfter(deadline: .now() + .seconds(2)) {
            self.isReconnecting = false
        }
        
        connect()
        
        timeToReconnect = min(timeToReconnect * 2, 30) + 1
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        print("CONNECTION - \(Self.wallet === self ? "WALLET" : "REG") \(timeToReconnect) \(Date())")

        Self.dispatchQueue.asyncAfter(deadline: .now() + .seconds(timeToReconnect)) { [weak self] in
            self?.autoReconnect()
        }
    }
}
