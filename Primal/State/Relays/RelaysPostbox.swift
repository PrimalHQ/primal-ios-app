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
        self.pool.disconnect()
    }
    
    var loadedRalays: [String] = []
    
    func connect(_ relays: [String]) {
        loadedRalays = relays
        self.pool.connect(relays: relays)
    }
    
    func reconnect() {
        pool.disconnect()
        pool.connect(relays: loadedRalays)
    }
    
    func request(_ ev: NostrObject, specificRelay: String?, errorDelay: Double = 10, successHandler: @escaping (_ result: [JSON]) -> Void, errorHandler: @escaping () -> Void) {
        var didSucceed: Bool?
        
        func resultHandler(result: [JSON], relay: String) {
            DispatchQueue.main.async {
                if didSucceed != true {
                    didSucceed = true
                    successHandler(result)
                }                
            }
        }
        
        if let specificRelay {
            self.pool.requestTo(specificRelay, ev, resultHandler)
        } else {
            self.pool.request(ev, resultHandler)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + errorDelay) {
            if didSucceed == nil {
                didSucceed = false
                errorHandler()
            }
        }
    }
}
