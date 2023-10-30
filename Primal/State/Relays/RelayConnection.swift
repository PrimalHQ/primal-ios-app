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
    private var socket: NWWebSocket? {
        didSet {
            if oldValue !== socket {
                oldValue?.delegate = nil
            }
        }
    }
    private var socketURL: URL

    private var dispatchQueue: DispatchQueue
    
    private var subHandlers: [String: (_ result: [JSON], _ relay: String) -> Void] = [:]
    private var responseBuffer: [String: [JSON]] = [:]
    
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var timeOut: Int = 1
    
    var state: CurrentValueSubject = CurrentValueSubject<RelayConnectionState, RelayConnectionError>(.disconnected)
    var identity: String
    
    init(socketURL: URL, dispatchQueue: DispatchQueue) {
        self.socketURL = socketURL
        self.dispatchQueue = dispatchQueue
        self.identity = socketURL.absoluteString
    }
    
    deinit {
        socket?.disconnect()
        socket = nil
    }

    var isWaitingForConnection = false
    func connect() {
        state.send(.connecting)
    
        socket = NWWebSocket(url: socketURL, connectionQueue: self.dispatchQueue)
        socket?.delegate = self
        socket?.connect()
        socket?.ping(interval: 10.0)
        
        guard !isWaitingForConnection else { return }
        timeOut *= 2
        isWaitingForConnection = true
        dispatchQueue.asyncAfter(deadline: .now() + .seconds(max(timeOut, 5))) { [weak self] in
            guard let self else { return }
            if case .connected = self.state.value { return }
            self.isWaitingForConnection = false
            self.connect()
        }
    }
    
    func disconnect() {
        socket?.disconnect()
        socket?.delegate = nil
        state.send(.disconnected)
    }
    
    func request(_ ev: NostrObject, _ handler: @escaping (_ result: [JSON], _ relay: String) -> Void) {
        self.dispatchQueue.async {
            guard
                let jsonData = try? JSONEncoder().encode(ev.toEventJSON()),
                let jsonStr = String(data: jsonData, encoding: .utf8)
            else {
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
        
        print("TYPE: \(type)")
        print("RESPONSE: \(json)")
        
        if type == "OK" {
            guard let okBool = json.arrayValue?[2].boolValue else {
                print("error getting bool value from OK response")
                return
            }
            
            if responseBuffer.keys.contains(subId) {
                responseBuffer[subId]?.append(json)
            }
            
            if let handler = subHandlers[subId], let b = responseBuffer[subId], okBool == true {
                DispatchQueue.main.async {
                    handler(b, self.socketURL.absoluteString)
                }
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
        timeOut = 1
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        state.send(.disconnected)
        
        if !isWaitingForConnection {
            connect()
        }
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("WSERROR: \(self.socketURL) - \(error)")
        state.send(.disconnected)
        
        if !isWaitingForConnection {
            connect()
        }
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
