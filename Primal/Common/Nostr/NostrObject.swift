//
//  Nostr_Event.swift
//  Primal
//
//  Created by Nikola Lukovic on 5.7.23..
//

import Foundation

struct NostrObject: Encodable, Decodable, Equatable {
    let id: String
    let sig: String
    let tags: [[String]]
    let pubkey: String
    let created_at: Int64
    let kind: Int
    let content: String
}
