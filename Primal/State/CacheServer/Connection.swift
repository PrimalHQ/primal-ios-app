//
//  Connection.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation
import Combine
import NWWebSocket
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
    
    static func connect() {
        regular.connect()
        wallet.connect()
    }
    
    static func disconnect() {
        regular.disconnect()
        wallet.disconnect()
    }
    
    static func reconnect() {
        disconnect()
        
        // There is an issue with blocked DispatchQueue, don't know what's causing it but it's fixed by creating a new dispatch queue
        Self.dispatchQueue = DispatchQueue(label: "com.primal.connection-\(UUID().uuidString.prefix(10))")
        
        regular.timeToReconnect = 2
        wallet.timeToReconnect = 2
        
        connect()
    }
    
    // MARK: - Class
    
    var socketURL: URL {
        didSet {
            disconnect()
            connect()
        }
    }
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var socket: NWWebSocket?
    private var subHandlers: [String: ([JSON]) -> Void] = [:]
    private var responseBuffer: [String: [JSON]] = [:]
    
    private var continousSubHandlers: [String: (JSON) -> Void] = [:]
    
    private var timeToReconnect: Int = 1
    private var attemptReconnection = true
    
    init(socketURL: URL) {
        self.socketURL = socketURL
        self.connect()
        
        $isConnected.dropFirst().sink { isConnected in
            print("CONNECTION IS CONNECTED \(self === Connection.regular ? "REG" : "WALL") = \(isConnected)")
        }
        .store(in: &cancellables)
    }
    
    deinit {
        socket?.disconnect()
    }
    
    var cancellables: Set<AnyCancellable> = []

    @Published var isConnected: Bool = false
    
    private func connect() {
        disconnect()
        
        let options = NWProtocolWebSocket.Options()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let ua = "\(APP_NAME)/\(appVersion) (main)"
        options.autoReplyPing = true // from default settings of NWWebsocket
        options.setAdditionalHeaders([("User-Agent", ua)])
        socket = NWWebSocket(url: socketURL, options: options, connectionQueue: Self.dispatchQueue)
        
        attemptReconnection = true
        socket?.delegate = self
        socket?.connect()
        socket?.ping(interval: 10.0)
    }
    
    private func disconnect() {
        attemptReconnection = false
        socket?.delegate = nil
        socket?.disconnect()
        socket = nil
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
        let subId = UUID().uuidString
        let json: JSON = .array([.string("REQ"), .string(subId), request])
        Self.dispatchQueue.async {
            guard let jsonData = try? self.jsonEncoder.encode(json) else {
                print("Error encoding req json")
                return
            }
            let jsonStr = String(data: jsonData, encoding: .utf8)!
                 
//            print("REQUEST:\n\(jsonStr)")
            self.responseBuffer[subId] = .init()
            self.subHandlers[subId] = handler
            self.socket?.send(string: jsonStr)
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
                 
//            print("REQUEST:\n\(jsonStr)")

            self.continousSubHandlers[subId] = handler
            self.socket?.send(string: jsonStr)
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
            self.socket?.send(string: jsonStr)
        }
    }
    
    private func processMessage(_ json: JSON) {
        guard
            let subId = json.arrayValue?[1].stringValue,
            let type = json.arrayValue?[0]
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
            responseBuffer[subId]?.append(json)
            continousSubHandlers[subId]?(json)
        }
    }
    
    func autoConnectReset() {
        DispatchQueue.main.async {
            self.timeToReconnect = 1
            
            self.autoReconnect()
        }
    }
    
    var isReconnecting = false
    var countReconnectAttempts = 0
    private func autoReconnect() {
        if isConnected || !attemptReconnection {
            timeToReconnect = 1
            countReconnectAttempts = 0
            return
        }
        
        if isReconnecting { return }
        
        countReconnectAttempts += 1
        isReconnecting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.isReconnecting = false
        }
        
        if countReconnectAttempts < 4 {
            connect()
        } else {
            countReconnectAttempts = 0
            Connection.reconnect()
        }
        
        timeToReconnect = min(timeToReconnect * 2, 30) + 1
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        print("CONNECTION - \(Self.wallet === self ? "WALLET" : "REG") \(timeToReconnect) \(Date())")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeToReconnect)) { [weak self] in
            self?.autoReconnect()
        }
    }
}

extension Connection: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        isConnected = true
        timeToReconnect = 1
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        isConnected = false
        
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        autoReconnect()
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("WSERROR: \(error)")
        
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        isConnected = false
        
        autoReconnect()
    }
    
    func webSocketDidReceivePong(connection: WebSocketConnection) {
        
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        guard let json: JSON = try? self.jsonDecoder.decode(JSON.self, from: string.data(using: .utf8)!) else {
            print("Error decoding received string to json")
            dump(string)
            return
        }
        
        self.processMessage(json)
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        
    }
}
