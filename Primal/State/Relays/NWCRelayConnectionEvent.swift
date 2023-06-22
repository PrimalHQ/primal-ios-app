//
//  NWCRelayConnectionEvent.swift
//  Primal
//
//  Created by Nikola Lukovic on 21.6.23..
//

import Foundation

enum NWCRelayConnectionEvent {
    case connected
    case message(URLSessionWebSocketTask.Message)
    case disconnected(URLSessionWebSocketTask.CloseCode, String?)
    case error(Error)
    
    var description: String? {
        switch self {
        case .connected:
            return "Connected"
        case .message(_):
            return "Received message"
        case .disconnected(let close_code, let reason):
            return "Disconnected: Close code: \(close_code), reason: \(reason ?? "unknown")"
        case .error(let error):
            return "Error: \(error)"
        }
    }
}
