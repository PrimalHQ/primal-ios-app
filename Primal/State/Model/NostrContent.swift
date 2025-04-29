//
//  Nostr.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import GenericJSON

struct NostrContent: Codable, Equatable, Hashable {
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

struct NostrContentStats: Codable, Hashable {
    let event_id: String
    let likes: Int?
    let mentions: Int?
    let replies: Int?
    let zaps: Int?
    let satszapped: Int?
    let score: Int?
    let score24h: Int?
    let reposts: Int?
    
    static func empty(_ id: String) -> NostrContentStats {
        .init(event_id: id, likes: 0, mentions: 0, replies: 0, zaps: 0, satszapped: 0, score: 0, score24h: 0, reposts: 0)
    }
}

struct NostrUserProfileInfo: Codable, Hashable {
    let follows_count: Int?
    let followers_count: Int?
    let note_count: Int?
    let reply_count: Int?
    let time_joined: Int?
    let long_form_note_count: Int?
    let media_count: Int?
    
    var replies: Int { reply_count ?? 0 }
    var follows: Int { follows_count ?? 0 }
    var followers: Int { followers_count ?? 0 }
    var notes: Int { note_count ?? 0 }
    var articles: Int { long_form_note_count ?? 0 }
    var media: Int { media_count ?? 0 }
}

struct MediaMetadata: Codable, Hashable {
    let event_id: String?
    let resources: [Resource]
    let thumbnails: [String: String]?
    
    struct Resource: Codable, Hashable {
        let url: String
        let variants: [Variant]
        
        struct Variant: Codable, Hashable {
            var a: Int
            var h: CGFloat
            var w: CGFloat
            var s: String
            var media_url: String
            var dur: Double?
            
            var height: CGFloat { h }
            var width: CGFloat { w }
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

struct WebPreview: Codable, Hashable {
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
    
    var shortened: Bool { event.kind == NostrKind.shortenedArticle.rawValue }
}
