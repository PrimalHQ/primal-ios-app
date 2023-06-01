//
//  ResponseBuffer.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Foundation

class PostRequestResult {
    let id: String
    var posts: [NostrContent] = []
    var mentions: [NostrContent] = []
    var reposts: [NostrRepost] = []
    var users: [String: PrimalUser] = [:]
    var stats: [String: NostrContentStats] = [:]
    
    init(id: String) {
        self.id = id
    }
}

struct NostrRepost {
    let pubkey: String
    let post: NostrContent
}
