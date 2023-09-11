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
    
    init(id: String) {
        self.id = id
    }
    
    func end() {
        Connection.instance.endContinous(id)
    }
    
    deinit {
        end()
    }
}

final class Connection {
    static let dispatchQueue = DispatchQueue(label: "com.primal.connection")
    
    private let socketURL = URL(string: "wss://cache1.primal.net/v1")!
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var socket: NWWebSocket?
    private var subHandlers: [String: ([JSON]) -> Void] = [:]
    private var responseBuffer: [String: [JSON]] = [:]
    
    private var continousSubHandlers: [String: (JSON) -> Void] = [:]
    
    private init() {
        self.connect()
    }
    
    deinit {
        socket?.disconnect()
    }
    
    static let instance = Connection()
    
    @Published var isConnected: Bool = false
    
    func connect() {
        if isConnected {
            disconnect()
        }
        let options = NWProtocolWebSocket.Options()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let ua = "\(APP_NAME)/\(appVersion) (main)"
        options.autoReplyPing = true // from default settings of NWWebsocket
        options.setAdditionalHeaders([("User-Agent", ua)])
        
        if socket == nil {
            socket = NWWebSocket(url: socketURL, options: options, connectionQueue: Self.dispatchQueue)
        }
        socket?.delegate = self
        socket?.connect()
        socket?.ping(interval: 10.0)
    }
    func reconnect() {
        socket?.delegate = nil
        socket?.disconnect()
        connect()
    }
    
    func disconnect() {
        socket?.delegate = nil
        socket?.disconnect()
        isConnected =  false
    }
    
    func requestCache(name: String, request: JSON?, _ handler: @escaping (_ result: [JSON]) -> Void) {
        if let request {
            requestCache(.array([.string(name), request]), handler)
        } else {
            requestCache(.array([.string(name)]), handler)
        }
    }
    
    func requestCache(_ cacheRequest: JSON, _ handler: @escaping (_ result: [JSON]) -> Void) {
        request(.object(["cache" : cacheRequest]), handler)
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
            ]), handler)
        } else {
            return requestContinous(.object([
                "cache" : .array([.string(name)])
            ]), handler)
        }
    }
    
    func requestContinous(_ request: JSON, _ handler: @escaping (JSON) -> Void) -> ContinousConnection {
        let subId = UUID().uuidString
        let json: JSON = .array([.string("REQ"), .string(subId), request])
        Self.dispatchQueue.async {
            guard let jsonData = try? self.jsonEncoder.encode(json) else {
                print("Error encoding req json")
                return
            }
            let jsonStr = String(data: jsonData, encoding: .utf8)!
                 
            print("REQUEST:\n\(jsonStr)")

            self.continousSubHandlers[subId] = handler
            self.socket?.send(string: jsonStr)
        }
        return .init(id: subId)
    }
    
    func endContinous(_ id: String) {
        let json = JSON.array([.string("CLOSE"), .string(id)])
        Self.dispatchQueue.async {
            guard let jsonData = try? self.jsonEncoder.encode(json) else {
                print("Error encoding req json")
                return
            }
            let jsonStr = String(data: jsonData, encoding: .utf8)!
                 
            print("REQUEST:\n\(jsonStr)")
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
        
        if type == "EVENT" {
            if responseBuffer.keys.contains(subId) {
                responseBuffer[subId]?.append(json)
            } else {
                continousSubHandlers[subId]?(json)
            }
        } else if type == "EOSE" {
            if let handler = subHandlers[subId], let b = responseBuffer[subId] {
                handler(b)
            }
            responseBuffer[subId] = nil
            subHandlers[subId] = nil
        } else {
            print(json)
        }
    }
    
    func autoReconnect() {
        if isConnected { return }
        
        connect()
        
        Self.dispatchQueue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.autoReconnect()
        }
    }
}

extension Connection: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        isConnected = true
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        isConnected = false
        
        autoReconnect()
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("WSERROR: \(error)")
        
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
