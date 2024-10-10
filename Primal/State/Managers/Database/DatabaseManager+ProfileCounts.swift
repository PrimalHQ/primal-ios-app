//
//  DatabaseManager+ProfileCounts.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.9.24..
//

import Foundation
import GRDB
import Combine

extension ProfileCount {
    init(pubkey: String, stats: NostrUserProfileInfo) {
        self = .init(profilePubkey: pubkey, follows: stats.follows, followers: stats.followers, replies: stats.replies, notes: stats.notes, articles: stats.articles, media: stats.media, timeJoined: stats.time_joined)
    }
    
    var info: NostrUserProfileInfo {
        .init(follows_count: follows, followers_count: followers, note_count: notes, reply_count: replies, time_joined: timeJoined, long_form_note_count: articles, media_count: media)
    }
}

extension DatabaseManager {
    func saveProfileFollowers(_ info: [String: Int]) {
        if info.isEmpty { return }
        
        let pubkeys = Array(info.keys)
        
        performUpdates { db in
            let allCounts = try ProfileCount.all().filterPubkeys(pubkeys).fetchAll(db)
            
            for (pubkey, followers) in info {
                if var old = allCounts.first(where: { $0.profilePubkey == pubkey }) {
                    old.followers = followers
                    try old.save(db)
                } else {
                    var new = ProfileCount(profilePubkey: pubkey, followers: followers)
                    try new.save(db)
                }
            }
        }
    }
    
    func saveProfileStats(_ pubkey: String, stats: NostrUserProfileInfo) {
        performUpdates { db in
            var count = ProfileCount(pubkey: pubkey, stats: stats)
            try count.save(db)
        }
    }
    
    func getProfileStatsPublisher(_ pubkey: String) -> AnyPublisher<ProfileCount?, Never> {
        dbWriter.readPublisher { db in
            try ProfileCount.all().filterPubkeys([pubkey]).fetchOne(db)
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }
}
