//
//  RelayHintManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.4.24..
//

import Foundation

class RelayHintManager {
    static let instance = RelayHintManager()
    
    var hints: [String: String] = [:]
    
    @MainActor
    func addHints(_ hints: [String: String]) {
        for (key, value) in hints {
            self.hints[key] = value
        }
    }
    
    func getRelayHint(_ id: String) -> String { hints[id] ?? "" }
}
