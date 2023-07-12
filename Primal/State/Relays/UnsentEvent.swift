//
//  UnsentEvent.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.6.23..
//

import Foundation
import GenericJSON

struct UnsentEvent : Identifiable {
    let id: String = UUID().uuidString
    
    let identity: String
    let event: NostrObject
    let callback: (_ result: [JSON], _ relay: String) -> Void
}

extension UnsentEvent : Equatable {
    static func == (lhs: UnsentEvent, rhs: UnsentEvent) -> Bool {
        return lhs.id == rhs.id
    }
}
