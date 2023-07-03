//
//  Primal.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import GenericJSON

struct Contacts {
    let created_at: Int
    var contacts: [String]
}

struct PrimalNoteStatus: Codable, Hashable {
    let event_id: String
    let replied: Bool
    let liked: Bool
    let reposted: Bool
    let zapped: Bool
}

struct PrimalSettingsFeed: Codable, Hashable {
    var name: String
    let hex: String
}

struct PrimalSettingsContent: Codable, Hashable {
    var description: String?
    var theme: String?
    var feeds: [PrimalSettingsFeed]
    var defaultZapAmount: Int64?
    var zapOptions: [Int64]?
}

struct PrimalSearchPagination: Codable, Hashable {
    let since: Int32
    let until: Int32
    let order_by: String
}

struct PrimalSettings: Codable, Identifiable, Hashable {
    let kind: Int32
    var content: PrimalSettingsContent
    let id: String
    let created_at: Int32
    let pubkey: String
    let sig: String
    let tags: [[String]]
    
    init?(json: JSON) {
        guard let settingsContent: PrimalSettingsContent = try? JSONDecoder().decode(PrimalSettingsContent.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
            print("Error decoding PrimalSettingsContent to json")
            return nil
        }
        
        self.kind = Int32(json.arrayValue?[2].objectValue?["kind"]?.doubleValue ?? -1)
        self.content = settingsContent
        self.id = json.arrayValue?[2].objectValue?["id"]?.stringValue ?? ""
        self.created_at = Int32(json.arrayValue?[2].objectValue?["created_at"]?.doubleValue ?? -1)
        self.pubkey = json.arrayValue?[2].objectValue?["pubkey"]?.stringValue ?? ""
        self.sig = json.arrayValue?[2].objectValue?["sig"]?.stringValue ?? ""
        self.tags = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?.map { $0.arrayValue?.map { $0.stringValue ?? "" } ?? [] } ?? []
    }
}

struct PrimalUser : Codable, Identifiable, Hashable {
    let id: String
    let pubkey: String
    let npub: String
    let name: String
    let about: String
    let picture: String
    let nip05: String
    let banner: String
    let displayName: String
    let location: String
    let lud06: String
    let lud16: String
    let website: String
    let tags: [[String]]
    let created_at: Int32
    let sig: String
    
    init?(nostrUser: NostrContent?, nostrPost: NostrContent? = nil) {
        guard let userMeta: JSON = try? JSONDecoder().decode(JSON.self, from: (nostrUser?.content ?? "{}").data(using: .utf8)!) else {
            print("Error decoding nostrUser: NostrContent to json")
            dump(nostrUser?.content)
            return nil
        }
        
        let tempId = nostrUser?.id ?? ""
        let tempPubkey = nostrUser?.pubkey ?? nostrPost?.pubkey ?? ""
        let tempNpub = bech32_pubkey(tempPubkey) ?? ""
        let tempName = userMeta.objectValue?["name"]?.stringValue ?? tempPubkey
        let tempTags = nostrUser?.tags ?? [[]]
        
        self.id = tempId
        self.pubkey = tempPubkey
        self.npub = tempNpub
        self.name = tempName
        self.about = userMeta.objectValue?["about"]?.stringValue ?? ""
        self.picture = userMeta.objectValue?["picture"]?.stringValue ?? ""
        self.nip05 = userMeta.objectValue?["nip05"]?.stringValue ?? ""
        self.banner = userMeta.objectValue?["banner"]?.stringValue ?? ""
        self.displayName = userMeta.objectValue?["display_name"]?.stringValue ?? ""
        self.location = userMeta.objectValue?["location"]?.stringValue ?? ""
        self.lud06 = userMeta.objectValue?["lud06"]?.stringValue ?? ""
        self.lud16 = userMeta.objectValue?["lud16"]?.stringValue ?? ""
        self.website = userMeta.objectValue?["website"]?.stringValue ?? ""
        self.tags = tempTags
        self.created_at = nostrUser?.created_at ?? -1
        self.sig = nostrUser?.sig ?? ""
    }
    
    func getDomainNip05() -> String {
        if self.nip05.isEmpty {
            return ""
        }
        
        let components = self.nip05.components(separatedBy: "@")
        
        guard let domain = components[safe: 1] else {
            return ""
        }
        
        return domain
    }
    
    var lnurl: String? {
        var addr: String = ""
        
        if lud16 == "" && lud06 == "" {
            return nil
        }
        
        addr = lud16 == "" ? lud06 : lud16
        
        if addr.contains("@") {
            let addr = lnaddress_to_lnurl(addr);
            return addr
        }
        if !addr.lowercased().hasPrefix("lnurl") {
            return nil
        }
        
        return addr;
    }
    
    static func == (lhs: PrimalUser, rhs: PrimalUser) -> Bool {
        return lhs.pubkey == rhs.pubkey
    }
}

struct PrimalFeedPost : Codable, Identifiable, Hashable {
    let id: String
    let pubkey: String
    let created_at: Int32
    let tags: [[String]]
    let content: String
    let sig: String
    let likes: Int32
    let mentions: Int32
    let replies: Int32
    let zaps: Int32
    var satszapped: Int32
    let score24h: Int32
    let reposts: Int32
    
    init(nostrPost: NostrContent, nostrPostStats: NostrContentStats) {
        self.id = nostrPost.id
        self.pubkey = nostrPost.pubkey
        self.created_at = nostrPost.created_at
        self.tags = nostrPost.tags
        self.content = nostrPost.content
        self.sig = nostrPost.sig
        self.likes = nostrPostStats.likes
        self.mentions = nostrPostStats.mentions
        self.replies = nostrPostStats.replies
        self.zaps = nostrPostStats.zaps
        self.satszapped = nostrPostStats.satszapped
        self.score24h = nostrPostStats.score24h
        self.reposts = nostrPostStats.reposts
    }
    
    func toRepostNostrContent() -> NostrContent {
        return NostrContent(kind: 1, content: self.content, id: self.id, created_at: self.created_at, pubkey: self.pubkey, sig: self.sig, tags: self.tags)
    }
}

struct PrimalPost : Codable, Hashable, Identifiable {
    let id: String
    let user: PrimalUser
    let post: PrimalFeedPost
    
    static func == (lhs: PrimalPost, rhs: PrimalPost) -> Bool {
        return lhs.post.id == rhs.post.id
    }
}
