//
//  TemporaryConnection.swift
//  Primal
//
//  Created by Nikola Lukovic on 28.6.23..
//
import Foundation
import Network
import NWWebSocket
import GenericJSON

final class TemporaryConnection {
    static let dispatchQueue = DispatchQueue(label: "com.primal.temporary-connection")
    
    private let socketURL = URL(string: "wss://cache1.primal.net/v1")!
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var socket: NWWebSocket?
    private var subHandlers: [String: (_: [JSON]) -> Void] = [:]
    private var responseBuffer: [String: [JSON]] = [:]
    
    init() {
        identity = UUID().uuidString
    }
    
    deinit {
        socket?.disconnect()
    }
    
    let identity: String
    @Published var isConnected: Bool = false
    
    func connect() {
        let options = NWProtocolWebSocket.Options()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let ua = "\(APP_NAME)/\(appVersion) (temporary)"
        options.autoReplyPing = true // from default settings of NWWebsocket
        options.setAdditionalHeaders([("User-Agent", ua)])
        
        socket = NWWebSocket(url: socketURL, options: options, connectionQueue: Self.dispatchQueue)
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
            
            print("TC REQUEST:\n\(jsonStr)")
            self.responseBuffer[subId] = .init()
            self.subHandlers[subId] = handler
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
            }
        } else if type == "EOSE" {
            if let handler = subHandlers[subId], let b = responseBuffer[subId] {
                handler(b)
            }
            responseBuffer[subId] = nil
            subHandlers[subId] = nil
        }
    }
}

extension TemporaryConnection: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        isConnected = true
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        isConnected = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.connect()
        }
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("TC WSERROR: \(error)")
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
