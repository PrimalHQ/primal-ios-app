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
    
    @Published private(set) var connections: Set<RelayConnection> = []
    private var unsentEvents: [UnsentEvent] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var atLeastOneConnected = false
    @Published var numOfConnected = 0
    @Published var relays: [String] = []
    
    deinit {
        self.disconnect()
    }
    
    func disconnect() {
        for connection in connections {
            connection.disconnect()
        }
        connections = []
        relays = []
        
        cancellables = []
        atLeastOneConnected = false
        numOfConnected = 0
    }
    
    func connect(relays: [String]) {
        for relay in relays {
            self.connect(relay)
        }
    }
    
    func disconnect(relay: String) {
        guard let connection = connections.first(where: { $0.identity == relay }) else { return }
        connections.remove(connection)
    }
    
    func connect(_ relay: String) {
        guard let url = URL(string: relay), relay.hasPrefix("wss://") else { return }
        let rc = RelayConnection(socketURL: url, dispatchQueue: Self.dispatchQueue)
        
        rc.state
            .receive(on: Self.dispatchQueue)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .connected:
                    self.atLeastOneConnected = true
                    self.numOfConnected += 1
                    
                    for unsentEvent in self.unsentEvents.reversed() {
                        if unsentEvent.identity == rc.identity {
                            rc.request(unsentEvent.event, unsentEvent.callback)
                            if let index = self.unsentEvents.firstIndex(of: unsentEvent) {
                                self.unsentEvents.remove(at: index)
                            }
                        }
                    }
                case .disconnected:
                    let num = self.numOfConnected + 1
                    self.numOfConnected = num < 0 ? 0 : num
                    self.atLeastOneConnected = num > 0
                case .connecting:
                    // do nothing
                    break
                }
            }).store(in: &cancellables)
        
        rc.connect()
        
        connections.insert(rc)
        
        relays.append(relay)
    }
    
    func request(_ ev: NostrObject, _ handler: @escaping (_ result: [JSON], _ relay: String) -> Void) {
        Self.dispatchQueue.async {
            for connection in self.connections {
                if connection.state.value == .connected {
                    connection.request(ev, handler)
                } else {
                    connection.connect()
                    
                    Self.dispatchQueue.asyncAfter(deadline: .now() + .seconds(3)) {
                        if connection.state.value == .connected {
                            connection.request(ev, handler)
                        } else {
                            // self.unsentEvents.append(UnsentEvent(identity: connection.identity, event: ev, callback: handler))
                        }
                    }
                }
            }
        }
    }
}
