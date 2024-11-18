//
//  ResponseBuffer.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Foundation
import GenericJSON

class PostRequestResult: Codable {
    var events: [[String: JSON]] = []
    
    var posts: [NostrContent] = []
    var mentions: [NostrContent] = []
    var reposts: [NostrRepost] = []
    var mediaMetadata: [MediaMetadata] = []
    var webPreviews: [WebPreviews] = []
    
    var postZaps: [PrimalZapEvent] = []
    var zapReceipts: [String: JSON] = [:]
    
    var order: [String] = []
    
    var users: [String: PrimalUser] = [:]
    var stats: [String: NostrContentStats] = [:]
    var userScore: [String: Int] = [:]
    var userFollowers: [String: Int] = [:]
    var userStats: NostrUserProfileInfo?
    
    var longFormWordCount: [String: Int] = [:]
    var longFormPosts: [LongFormPost] = []
    
    var eventBroadcastSuccessful = false
    
    var message: String?
    var pagination: PrimalPagination?
    
    var messageArray: [String]?
    var userPubkey: String?
    
    var highlights: [NostrContent] = []
    
    var relayData: [String: RelayInfo] = [:]
    var relayHint: String?
    
    var contacts: DatedSet?
    var allContacts: [DatedSet] = []
    var bookmarks: DatedTagArray?
    
    var timestamps: [Date] = []
    
    var popularHashtags: [PopularHashtag] = []
    var notifications: [PrimalNotification] = []
    
    var encryptedMessages: [EncryptedMessage] = []
    var chatsMetadata: [String: ChatMetadata] = [:]
    
    var isFollowingUser: Bool?
}

struct NostrRepost: Codable {
    let id: String
    let pubkey: String
    let post: NostrContent
    let date: Date
}

struct PopularHashtag: Codable {
    var title: String
    var appearances: Double
}

struct EncryptedMessage: Codable {
    var id: String
    var pubkey: String
    var recipientPubkey: String
    var date: Date
    var message: String
}

struct ChatMetadata: Codable {
    var cnt: Int
    var latest_at: Double
    var latest_event_id: String
}
