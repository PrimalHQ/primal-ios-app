//
//  LikeManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation

final class LikeManager {
    private init() {}
    
    static let instance: LikeManager = LikeManager()
    
    @Published var userLikes: Set<String> = []
    
    func hasLiked(_ eventId: String) -> Bool { userLikes.contains(eventId) }
    
    func sendLikeEvent(post: PrimalFeedPost) {
        if LoginManager.instance.method() != .nsec { return }

        guard !hasLiked(post.id) else {
            print("Error getting saved keypair")
            return
        }
                
        guard let ev = NostrObject.like(post: post) else {
            print("Error creating nostr like event")
            return
        }
                
        userLikes.insert(post.id)
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            // do nothing
        }, errorHandler: {
            self.userLikes.remove(ev.id)
        })
    }
}
