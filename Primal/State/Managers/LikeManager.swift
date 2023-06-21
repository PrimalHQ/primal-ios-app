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
        guard
            !hasLiked(post.id),
            let keypair = get_saved_keypair()
        else {
            print("Error getting saved keypair")
            return
        }
                
        let ev  = make_like_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, post: post)
        
        userLikes.insert(post.id)
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            // do nothing
        }, errorHandler: {
            self.userLikes.remove(ev.id)
        })
    }
}
