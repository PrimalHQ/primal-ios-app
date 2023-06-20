//
//  RelayConnection.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.6.23..
//

import Foundation
import NWWebSocket
import Network
import GenericJSON
import Combine

enum RelayConnectionState {
    case connected
    case disconnected
    case connecting
}

enum RelayConnectionError : Error {
    case error
}

final class RelayConnection {
    private var socket: NWWebSocket?
    private var socketURL: URL

    private var dispatchQueue: DispatchQueue
    
    private var subHandlers: [String: (_: [JSON]) -> Void] = [:]
    private var responseBuffer: [String: [JSON]] = [:]
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    var state: CurrentValueSubject = CurrentValueSubject<RelayConnectionState, RelayConnectionError>(.disconnected)
    var identity: String
    
    init(socketURL: String, dispatchQueue: DispatchQueue = DispatchQueue.main) {
        self.socketURL = URL(string: socketURL)!
        self.dispatchQueue = dispatchQueue
        self.identity = socketURL
    }
    
    deinit {
        socket?.disconnect()
        socket = nil
    }

    func connect() {
        state.send(.connecting)
        
        socket = NWWebSocket(url: socketURL)
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
        state.send(.disconnected)
    }
    
    func request(_ ev: NostrEvent, _ handler: @escaping (_ result: [JSON]) -> Void) {
        self.dispatchQueue.async {
            guard let jsonStr = ev.toJSONString() else {
                return
            }
            
            print("REQUEST:\n\(jsonStr)")
            self.responseBuffer[ev.id] = .init()
            self.subHandlers[ev.id] = handler
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

extension RelayConnection : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}

extension RelayConnection : Equatable {
    static func == (lhs: RelayConnection, rhs: RelayConnection) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension RelayConnection : WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        state.send(.connected)
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        state.send(.disconnected)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.connect()
        }
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("WSERROR: \(self.socketURL) - \(error)")
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
