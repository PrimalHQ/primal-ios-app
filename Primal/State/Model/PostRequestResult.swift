//
//  ResponseBuffer.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Foundation
import GenericJSON

class PostRequestResult {
    var posts: [NostrContent] = []
    var mentions: [NostrContent] = []
    var reposts: [NostrRepost] = []
    var mediaMetadata: [MediaMetadata] = []
    
    var users: [String: PrimalUser] = [:]
    var stats: [String: NostrContentStats] = [:]
    var userScore: [String: Int] = [:]
    
    var timestamps: [Date] = []
    
    var popularHashtags: [PopularHashtag] = []
    var notifications: [PrimalNotification] = []
}

struct NostrRepost {
    let pubkey: String
    let post: NostrContent
}

struct PopularHashtag {
    var title: String
    var apperances: Double
}
