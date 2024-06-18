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
    let created_at: Double
    let pubkey: String
    let sig: String
    let tags: [[String]]
    
    init(kind: Int32, content: String, id: String, created_at: Double, pubkey: String, sig: String, tags: [[String]]) {
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
        self.created_at = json.objectValue?["created_at"]?.doubleValue ?? -1
        self.pubkey = json.objectValue?["pubkey"]?.stringValue ?? ""
        self.sig = json.objectValue?["sig"]?.stringValue ?? ""
        self.tags = json.objectValue?["tags"]?.arrayValue?.map { $0.arrayValue?.map { $0.stringValue ?? "" } ?? [] } ?? []
    }
    
    init(jsonData: [String: JSON]) {
        kind = Int32(jsonData["kind"]?.doubleValue ?? -1)
        content = jsonData["content"]?.stringValue ?? ""
        id = jsonData["id"]?.stringValue ?? ""
        created_at = jsonData["created_at"]?.doubleValue ?? -1
        pubkey = jsonData["pubkey"]?.stringValue ?? ""
        sig = jsonData["sig"]?.stringValue ?? ""
        tags = jsonData["tags"]?.arrayValue?.compactMap { $0.arrayValue?.map { $0.stringValue ?? "" } } ?? []
    }
}

struct NostrContentStats: Codable {
    let event_id: String
    let likes: Int
    let mentions: Int
    let replies: Int
    let zaps: Int
    let satszapped: Int
    let score: Int
    let score24h: Int
    let reposts: Int
    
    static func empty(_ id: String) -> NostrContentStats {
        .init(event_id: id, likes: 0, mentions: 0, replies: 0, zaps: 0, satszapped: 0, score: 0, score24h: 0, reposts: 0)
    }
}

struct NostrUserProfileInfo: Codable {
    let follows_count: Int32?
    let followers_count: Int32?
    let note_count: Int32?
    let reply_count: Int32?
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
    let thumbnails: [String: String]?
    
    struct Resource: Codable {
        let url: String
        let variants: [Variant]
        
        struct Variant: Codable {
            var a: Int
            var h: Int
            var w: Int
            var s: String
            var media_url: String
            var dur: Double?
            
            var height: Int { h }
            var width: Int { w }
            var url: URL? { URL(string: media_url) }
            var animated: Bool { a != 1 }
            var size: MediaSize { .init(rawValue: s) ?? .medium }
            var duration: Double? { dur }
        }
        
        func url(for size: MediaSize) -> URL? {
            (variants.first(where: { $0.size == size }) ?? variants.first(where: { $0.size == .original }) ?? variants.first)?.url
                ?? URL(string: url)
        }
    }
}

struct WebPreviews: Codable {
    var event_id: String
    var resources: [WebPreview]
}

struct WebPreview: Codable {
    var icon_url: String?
    var md_image: String?
    
    var md_title: String?
    var md_description: String?
    
    var url: String
}

struct LongFormPost: Codable {
    var title: String?
    var image: String?
    var summary: String?
    
    var event: NostrContent
}
