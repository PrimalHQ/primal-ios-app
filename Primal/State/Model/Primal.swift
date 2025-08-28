//
//  Primal.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import GenericJSON

struct DatedSet: Codable {
    let created_at: Int
    var set: Set<String> = []
}

struct Tag: Codable, Hashable, Equatable {
    var type: String
    var text: String
}

struct DatedTagArray: Codable {
    let created_at: Int
    var array: [Tag] = []
}

struct PrimalNoteStatus: Codable, Hashable {
    let event_id: String
    let replied: Bool
    let liked: Bool
    let reposted: Bool
    let zapped: Bool
}

struct PrimalZapDefaultSettings: Codable, Hashable {
    var amount: Int
    var message: String?
}

struct PrimalZapListSettings: Codable, Hashable {
    var emoji: String
    var amount: Int
    var message: String?
}

struct PrimalSettingsContent: Codable, Hashable {
    var description: String? = "Sync app settings"
    var theme: String?
    var notifications: PrimalSettingsNotifications?
    var pushNotifications: PrimalSettingsPushNotifications?
    var notificationsAdditional: PrimalSettingsAdditionalNotifications?
    var zapDefault: PrimalZapDefaultSettings?
    var zapConfig: [PrimalZapListSettings]?
    
    mutating func merge(with settings: PrimalSettingsContent) {
        if self.description == nil {
            self.description = "Sync app settings"
        }
        
        if self.theme == nil {
            self.theme = settings.theme
        }
        
        if self.notifications == nil {
            self.notifications = settings.notifications
        }
        
        if self.zapDefault == nil {
            self.zapDefault = settings.zapDefault
        }
        
        if self.zapConfig?.isEmpty != false {
            self.zapConfig = settings.zapConfig
        }
    }
    
    func isBorked() -> Bool {
        return self.theme == nil
            || self.notifications == nil
            || self.zapDefault == nil
            || self.zapConfig?.isEmpty != false
    }
}

struct PrimalSettingsPushNotifications: Codable, Hashable {
    var NEW_FOLLOWS: Bool = true
    var ZAPS: Bool = true
    var REACTIONS: Bool = true
    var REPLIES: Bool = true
    var REPOSTS: Bool = true
    var MENTIONS: Bool = true
    var DIRECT_MESSAGES: Bool = true
    var WALLET_TRANSACTIONS: Bool = true
}

struct PrimalSettingsAdditionalNotifications: Codable, Hashable {
    var ignore_events_with_too_many_mentions = true
    var only_show_dm_notifications_from_users_i_follow = true
    var only_show_reactions_from_users_i_follow: Bool? = false
    var show_wallet_push_notifications_above_sats: Int? = 1
}

struct PrimalSettingsNotifications: Codable, Hashable {
    var NEW_USER_FOLLOWED_YOU: Bool

    var YOUR_POST_WAS_ZAPPED: Bool
    var YOUR_POST_WAS_LIKED: Bool
    var YOUR_POST_WAS_REPOSTED: Bool
    var YOUR_POST_WAS_REPLIED_TO: Bool
    var YOU_WERE_MENTIONED_IN_POST: Bool
    var YOUR_POST_WAS_MENTIONED_IN_POST: Bool

    var POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED: Bool
    var POST_YOU_WERE_MENTIONED_IN_WAS_LIKED: Bool
    var POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED: Bool
    var POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO: Bool

    var POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED: Bool
    var POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED: Bool
    var POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED: Bool
    var POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO: Bool
    
    var YOUR_POST_WAS_HIGHLIGHTED: Bool?
    var YOUR_POST_WAS_BOOKMARKED: Bool?
}

struct PrimalPagination: Codable, Hashable {
    var since: Double?
    var until: Double?
    var order_by: String
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
        guard var settingsContent: PrimalSettingsContent = json.objectValue?["content"]?.stringValue?.decode() else {
            print("Error decoding PrimalSettingsContent to json")
            return nil
        }
        
        if settingsContent.description == nil {
            settingsContent.description = "Sync app settings"
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
    var about: String
    var picture: String
    var nip05: String
    let banner: String
    let displayName: String
    let location: String
    let lud06: String
    var lud16: String
    var website: String
    let tags: [[String]]
    let created_at: Double
    let sig: String
    let deleted: Bool?
    var rawData: String?
    
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
        let tempDeleted = userMeta.objectValue?["deleted"]?.boolValue ?? false
        
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
        self.deleted = tempDeleted
    }
    
    init(pubkey: String) {
        self.init(id: "", pubkey: pubkey, npub: bech32_pubkey(pubkey) ?? "", name: "unknown", about: "", picture: "", nip05: "", banner: "", displayName: "", location: "", lud06: "", lud16: "", website: "", tags: [], created_at: 0, sig: "", deleted: false)
    }
    
    init(id: String, pubkey: String, npub: String, name: String, about: String, picture: String, nip05: String, banner: String, displayName: String, location: String, lud06: String, lud16: String, website: String, tags: [[String]], created_at: Double, sig: String, deleted: Bool) {
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
        self.deleted = deleted
    }
    
    var address: String? {
        if lud16.isEmpty && lud06.isEmpty {
            return nil
        }
        
        return lud16.isEmpty ? lud06 : lud16
    }
    
    static func == (lhs: PrimalUser, rhs: PrimalUser) -> Bool {
        return lhs.pubkey == rhs.pubkey
    }
}

struct PrimalFeedPost : Codable, Identifiable, Hashable {
    let id: String
    let kind: Int
    let pubkey: String
    let created_at: Double
    let tags: [[String]]
    var content: String
    let sig: String
    var likes: Int
    let mentions: Int
    var replies: Int
    var zaps: Int
    var satszapped: Int
    let score24h: Int
    var reposts: Int
    var rawData: String?
    
    init(nostrPost: NostrContent, nostrPostStats: NostrContentStats) {
        self.id = nostrPost.id
        self.kind = Int(nostrPost.kind)
        self.pubkey = nostrPost.pubkey
        self.created_at = nostrPost.created_at
        self.tags = nostrPost.tags
        self.content = nostrPost.content
        self.sig = nostrPost.sig
        self.likes = nostrPostStats.likes ?? 0
        self.mentions = nostrPostStats.mentions ?? 0
        self.replies = nostrPostStats.replies ?? 0
        self.zaps = nostrPostStats.zaps ?? 0
        self.satszapped = nostrPostStats.satszapped ?? 0
        self.score24h = nostrPostStats.score24h ?? 0
        self.reposts = nostrPostStats.reposts ?? 0
        self.rawData = nostrPost.encodeToString()
    }
    
    init(id: String, pubkey: String, created_at: Double, tags: [[String]], content: String, sig: String, likes: Int, mentions: Int, replies: Int, zaps: Int, satszapped: Int, score24h: Int, reposts: Int) {
        self.id = id
        self.kind = 1
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
        self.reposts = reposts
    }
    
    func toRepostNostrContent() -> NostrContent {
        return NostrContent(kind: Int32(kind), content: content, id: id, created_at: self.created_at, pubkey: self.pubkey, sig: self.sig, tags: self.tags)
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

extension PrimalUser {
    static let empty: PrimalUser = {
        let userUUID = "empty"
        return PrimalUser(
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
            created_at: Date.now.timeIntervalSince1970,
            sig: userUUID,
            deleted: false
        )
    }()
    
    var profileData: NostrProfile {
        NostrProfile(
            name: name,
            display_name: displayName,
            about: about,
            picture: picture,
            banner: banner,
            website: website,
            lud06: lud06,
            lud16: lud16,
            nip05: nip05
        )
    }
}

extension PrimalFeedPost {
    static let empty: PrimalFeedPost = {
        let feedPostUUID = "empty"
        return PrimalFeedPost(
            id: feedPostUUID,
            pubkey: feedPostUUID,
            created_at: 1677374861,
            tags: [[]],
            content: "\(feedPostUUID) \(feedPostUUID)",
            sig: feedPostUUID,
            likes: 420,
            mentions: 69,
            replies: 42,
            zaps: 666,
            satszapped: 666,
            score24h: 13,
            reposts: 42
        )
    }()
    
    var isEmpty: Bool {
        id == "empty" || (id.isEmpty && pubkey.isEmpty)
    }
}

struct PrimalZapEvent: Codable {
    var created_at: Double
    var event_id: String
    var zap_receipt_id: String
    var receiver: String
    var amount_sats: Int
    var sender: String
}
