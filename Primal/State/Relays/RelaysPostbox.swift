//
//  RelaysPostbox.swift
//  Primal
//
//  Created by Nikola Lukovic on 21.6.23..
//

import Foundation
import Combine
import GenericJSON

final class RelaysPostbox {
    let pool = RelayPool()
    
    static let instance = RelaysPostbox()
    
    func disconnect() {
        loadedRalays = []
        self.pool.disconnect()
    }
    
    var loadedRalays: [String] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    func connect(_ relays: [String]) {
        if NetworkSettings.enhancedPrivacy { return } // Disable connecting to the relays
        
        loadedRalays += relays
        self.pool.connect(relays: relays)
    }
    
    func reconnect() {
        pool.disconnect()
        pool.connect(relays: loadedRalays)
    }
    
    func request(_ ev: NostrObject, errorDelay: Double = 10, successHandler: ((_ result: [JSON]) -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        var didSucceed: Bool?
        
        func resultHandler(result: [JSON], relay: String) {
            DispatchQueue.main.async {
                if didSucceed != true {
                    didSucceed = true
                    successHandler?(result)
                }                
            }
        }
        
        pool.request(ev, resultHandler)
        
        var relays = IdentityManager.instance.userRelays?.keys as? [String] ?? []
        if relays.isEmpty { relays = bootstrap_relays }
        
        if let jsonEV: JSON = ev.encodeToString()?.decode() {
            SocketRequest(name: "broadcast_events", payload: [
                "events": .array([jsonEV]),
                "relays": .array(relays.map { .string($0) })
            ])
            .publisher()
            .sink { res in
                if res.eventBroadcastSuccessful {
                    resultHandler(result: [], relay: "")
                }
            }
            .store(in: &cancellables)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + errorDelay) {
            if didSucceed == nil {
                didSucceed = false
                errorHandler?()
            }
        }
    }
}
