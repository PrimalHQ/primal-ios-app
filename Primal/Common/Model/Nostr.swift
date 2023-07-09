//
//  Nostr.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import GenericJSON

struct NostrContent: Codable {
    let kind: Int32
    let content: String
    let id: String
    let created_at: Int32
    let pubkey: String
    let sig: String
    let tags: [[String]]
    
    init(kind: Int32, content: String, id: String, created_at: Int32, pubkey: String, sig: String, tags: [[String]]) {
        self.kind = kind
        self.content = content
        self.id = id
        self.created_at = created_at
        self.pubkey = pubkey
        self.sig = sig
        self.tags = tags
    }
    
    init(json: JSON) {
        self.kind = Int32(json.objectValue?["kind"]?.doubleValue ?? -1)
        self.content = json.objectValue?["content"]?.stringValue ?? ""
        self.id = json.objectValue?["id"]?.stringValue ?? ""
        self.created_at = Int32(json.objectValue?["created_at"]?.doubleValue ?? -1)
        self.pubkey = json.objectValue?["pubkey"]?.stringValue ?? ""
        self.sig = json.objectValue?["sig"]?.stringValue ?? ""
        self.tags = json.objectValue?["tags"]?.arrayValue?.map { $0.arrayValue?.map { $0.stringValue ?? "" } ?? [] } ?? []
    }
    
    init(jsonData: [String: JSON]) {
        kind = Int32(jsonData["kind"]?.doubleValue ?? -1)
        content = jsonData["content"]?.stringValue ?? ""
        id = jsonData["id"]?.stringValue ?? ""
        created_at = Int32(jsonData["created_at"]?.doubleValue ?? -1)
        pubkey = jsonData["pubkey"]?.stringValue ?? ""
        sig = jsonData["sig"]?.stringValue ?? ""
        tags = jsonData["tags"]?.arrayValue?.compactMap { $0.arrayValue?.map { $0.stringValue ?? "" } } ?? []
    }
}

struct NostrContentStats: Codable {
    let event_id: String
    let likes: Int32
    let mentions: Int32
    let replies: Int32
    let zaps: Int32
    let satszapped: Int32
    let score: Int32
    let score24h: Int32
    let reposts: Int32
}

struct NostrUserProfileInfo: Codable {
    let follows_count: Int32?
    let followers_count: Int32?
    let note_count: Int32?
    let time_joined: Int32?
    
    var follows: Int32 { follows_count ?? 0 }
    var followers: Int32 { followers_count ?? 0 }
    var notes: Int32 { note_count ?? 0 }
}

enum MediaSize: String {
    case small = "s"
    case large = "l"
    case medium = "m"
    case original = "o"
}

struct MediaMetadata: Codable {
    let event_id: String
    let resources: [Resource]
    
    struct Resource: Codable {
        let url: String
        let variants: [Variant]
        
        struct Variant: Codable {
            var a: Int
            var h: Int
            var w: Int
            var s: String
            var media_url: String
            
            var height: Int { h }
            var width: Int { w }
            var url: URL? { URL(string: media_url) }
            var animated: Bool { a != 1 }
            var size: MediaSize { .init(rawValue: s) ?? .medium }
        }
        
        func url(for size: MediaSize) -> URL? {
            (variants.first(where: { $0.size == size }) ?? variants.first(where: { $0.size == .original }) ?? variants.first)?.url
                ?? URL(string: url)
        }
    }
}
