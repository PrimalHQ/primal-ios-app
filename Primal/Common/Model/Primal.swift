//
//  Primal.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import GenericJSON

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
            print("Error decoding received string to json")
            dump(nostrUser?.content)
            return nil
        }
        
        let tempId = nostrUser?.id ?? ""
        let tempPubkey = nostrUser?.pubkey ?? nostrPost?.pubkey ?? ""
        let tempNpub = "not implemented yet"
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
    
    init(id: String, pubkey: String, npub: String, name: String, about: String, picture: String, nip05: String, banner: String, displayName: String, location: String, lud06: String, lud16: String, website: String, tags: [[String]], created_at: Int32, sig: String) {
        self.id = id
        self.pubkey = pubkey
        self.npub = npub
        self.name = name
        self.about = about
        self.picture = picture
        self.nip05 = nip05
        self.banner = banner
        self.displayName = displayName
        self.location = location
        self.lud06 = lud06
        self.lud16 = lud16
        self.website = website
        self.tags = tags
        self.created_at = created_at
        self.sig = sig
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
    let satszapped: Int32
    let score24h: Int32
    
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
    }
    
    init(id: String, pubkey: String, created_at: Int32, tags: [[String]], content: String, sig: String, likes: Int32, mentions: Int32, replies: Int32, zaps: Int32, satszapped: Int32, score24h: Int32) {
        self.id = id
        self.pubkey = pubkey
        self.created_at = created_at
        self.tags = tags
        self.content = content
        self.sig = sig
        self.likes = likes
        self.mentions = mentions
        self.replies = replies
        self.zaps = zaps
        self.satszapped = satszapped
        self.score24h = score24h
    }
}

struct PrimalPost : Codable, Hashable, Identifiable {
    let id: String
    let user: PrimalUser
    let post: PrimalFeedPost
    
    static func == (lhs: PrimalPost, rhs: PrimalPost) -> Bool {
        return lhs.post.id == rhs.post.id
    }
    
    static func example() -> PrimalPost {
        let userUUID = UUID().uuidString
        let user: PrimalUser = PrimalUser(
            id: userUUID,
            pubkey: userUUID,
            npub: userUUID,
            name: userUUID,
            about: userUUID,
            picture: "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
            nip05: userUUID,
            banner: "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
            displayName: userUUID,
            location: userUUID,
            lud06: userUUID,
            lud16: userUUID,
            website: userUUID,
            tags: [[]],
            created_at: Int32(Date.now.timeIntervalSince1970),
            sig: userUUID
        )
        let feedPostUUID = UUID().uuidString
        let feedPost: PrimalFeedPost = PrimalFeedPost(
            id: feedPostUUID,
            pubkey: feedPostUUID,
            created_at: 1677374861,
            tags: [[]],
            content: "\(feedPostUUID) \(feedPostUUID)\n \(userUUID)",
            sig: feedPostUUID,
            likes: 420,
            mentions: 69,
            replies: 42,
            zaps: 666,
            satszapped: 666,
            score24h: 13
        )
        
        return PrimalPost(id: UUID().uuidString, user: user, post: feedPost)
    }
}
