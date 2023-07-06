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
    private let pool = RelayPool()
    
    static let instance = RelaysPostbox()
    
    var relays: CurrentValueSubject<[String], Error> {
        get {
            return self.pool.relays
        }
    }
    
    func disconnect() {
        self.pool.disconnect()
    }
    
    func connect(_ relays: [String]) {
        self.pool.connect(relays: relays)
    }
    
    func request(_ ev: NostrEvent, specificRelay: String?, successHandler: @escaping (_ result: [JSON]) -> Void, errorHandler: @escaping () -> Void) {
        var receivedAlready = false
        
        func resultHandler(result: [JSON], relay: String) {
            if !receivedAlready {
                receivedAlready = true
                successHandler(result)
            }
        }
        
        if let specificRelay {
            self.pool.requestTo(specificRelay, ev, resultHandler)
        } else {
            self.pool.request(ev, resultHandler)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if !receivedAlready {
                errorHandler()
            }
        }
    }
    
    func request(_ ev: NostrObject, specificRelay: String?, successHandler: @escaping (_ result: [JSON]) -> Void, errorHandler: @escaping () -> Void) {
        var receivedAlready = false
        
        func resultHandler(result: [JSON], relay: String) {
            if !receivedAlready {
                receivedAlready = true
                successHandler(result)
            }
        }
        
        if let specificRelay {
            self.pool.requestTo(specificRelay, ev, resultHandler)
        } else {
            self.pool.request(ev, resultHandler)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if !receivedAlready {
                errorHandler()
            }
        }
    }
}
