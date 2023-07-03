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
}
