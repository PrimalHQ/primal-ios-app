//
//  Nostr.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import GenericJSON

struct NostrContent: Codable {
    let kind: Int8
    let content: String
    let id: String
    let created_at: Int32
    let pubkey: String
    let sig: String
    let tags: [[String]]
    
    init(kind: Int8, content: String, id: String, created_at: Int32, pubkey: String, sig: String, tags: [[String]]) {
        self.kind = kind
        self.content = content
        self.id = id
        self.created_at = created_at
        self.pubkey = pubkey
        self.sig = sig
        self.tags = tags
    }
    
    init(json: JSON) {
        self.kind = Int8(json.arrayValue?[2].objectValue?["kind"]?.doubleValue ?? -1)
        self.content = json.arrayValue?[2].objectValue?["content"]?.stringValue ?? ""
        self.id = json.arrayValue?[2].objectValue?["id"]?.stringValue ?? ""
        self.created_at = Int32(json.arrayValue?[2].objectValue?["created_at"]?.doubleValue ?? -1)
        self.pubkey = json.arrayValue?[2].objectValue?["pubkey"]?.stringValue ?? ""
        self.sig = json.arrayValue?[2].objectValue?["sig"]?.stringValue ?? ""
        self.tags = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?.map { $0.arrayValue?.map { $0.stringValue ?? "" } ?? [] } ?? []
    }
}

struct NostrContentStats: Codable {
    let event_id: String
    let likes: Int32
    let mentions: Int32
    let replies: Int32
    let zaps: Int32
    let score24h: Int32
    
    init(json: JSON) {
        self.event_id = json.arrayValue?[2].objectValue?["event_id"]?.stringValue ?? ""
        self.likes = Int32(json.arrayValue?[2].objectValue?["likes"]?.doubleValue ?? -1)
        self.mentions = Int32(json.arrayValue?[2].objectValue?["mentions"]?.doubleValue ?? -1)
        self.replies = Int32(json.arrayValue?[2].objectValue?["replies"]?.doubleValue ?? -1)
        self.zaps = Int32(json.arrayValue?[2].objectValue?["zaps"]?.doubleValue ?? -1)
        self.score24h = Int32(json.arrayValue?[2].objectValue?["score24h"]?.doubleValue ?? -1)
    }
}
