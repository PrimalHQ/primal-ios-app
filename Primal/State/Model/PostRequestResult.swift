//
//  ResponseBuffer.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Foundation

class PostRequestResult {
    var posts: [NostrContent] = []
    var mentions: [NostrContent] = []
    var reposts: [NostrRepost] = []
    var mediaMetadata: [MediaMetadata] = []
    
    var users: [String: PrimalUser] = [:]
    var stats: [String: NostrContentStats] = [:]
    var userScore: [String: Int] = [:]
    
    var popularHashtags: [PopularHashtag] = []
}

struct NostrRepost {
    let pubkey: String
    let post: NostrContent
}

public struct PopularHashtag {
    var title: String
    var apperances: Int
}
