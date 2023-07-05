//
//  RelayPool.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.6.23..
//

import Foundation
import Combine
import GenericJSON

final class RelayPool {
    static let dispatchQueue = DispatchQueue(label: "com.primal.relaypool", qos: .background)
    
    private var connections: Set<RelayConnection> = []
    private var unsentEvents: [UnsentEvent] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    var atLeastOneConnected: CurrentValueSubject<Bool, Error> = CurrentValueSubject(false)
    var numOfConnected: CurrentValueSubject<Int, Error> = CurrentValueSubject(0)
    var relays: CurrentValueSubject<[String], Error> = CurrentValueSubject([])
    
    deinit {
        self.disconnect()
    }
    
    func disconnect() {
        for connection in connections {
            connection.disconnect()
        }
        connections = []
        self.relays.send([])
    }
    
    func connect(relays: [String]) {
        for relay in relays {
            self.connect(relay)
        }
    }
    
    func connect(_ relay: String) {
        guard let url = URL(string: relay) else { return }
        let rc = RelayConnection(socketURL: url, dispatchQueue: Self.dispatchQueue)
        
        rc.state
            .receive(on: Self.dispatchQueue)
            .sink(receiveCompletion: { _ in }, receiveValue: { state in
                switch state {
                case .connected:
                    self.atLeastOneConnected.send(true)
                    self.numOfConnected.send(self.numOfConnected.value + 1)
                    
                    for unsentEvent in self.unsentEvents.reversed() {
                        if unsentEvent.identity == rc.identity {
                            rc.request(unsentEvent.event, unsentEvent.callback)
                            if let index = self.unsentEvents.firstIndex(of: unsentEvent) {
                                self.unsentEvents.remove(at: index)
                            }
                        }
                    }
                case .disconnected:
                    let num = self.numOfConnected.value + 1
                    self.numOfConnected.send(num < 0 ? 0 : num)
                    self.atLeastOneConnected.send(num > 0)
                case .connecting:
                    // do nothing
                    break
                }
            }).store(in: &cancellables)
        
        rc.connect()
        
        connections.insert(rc)
        
        self.relays.value.append(relay)
        self.relays.send(self.relays.value)
    }
    
    func request(_ ev: NostrEvent, _ handler: @escaping (_ result: [JSON], _ relay: String) -> Void) {
        Self.dispatchQueue.async {
            for connection in self.connections {
                if connection.state.value == .connected {
                    connection.request(ev, handler)
                } else {
                    self.unsentEvents.append(UnsentEvent(identity: connection.identity, event: ev, callback: handler))
                }
            }
        }
    }
    
    func requestTo(_ specificRelay: String, _ ev: NostrEvent, _ handler: @escaping (_ result: [JSON], _ relay: String) -> Void) {
        Self.dispatchQueue.async {
            for connection in self.connections {
                if connection.identity == specificRelay {
                    if connection.state.value == .connected {
                        connection.request(ev, handler)
                    } else {
                        self.unsentEvents.append(UnsentEvent(identity: connection.identity, event: ev, callback: handler))
                    }
                }
            }
        }
    }
}
