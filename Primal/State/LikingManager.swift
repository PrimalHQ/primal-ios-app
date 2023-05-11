//
//  LikingManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 11.5.23..
//

import Foundation
import GenericJSON

class LikingManager {
    let feed: Feed
    private let subId: String = "Primal-iOS-Likes-SubId"
    
    init(feed: Feed) {
        self.feed = feed
        self.feed.postBox.pool.subscribe(sub_id: subId, filters: [], handler: self.handle_get_likes_event)
    }
    
    func sendLikeEvent(post: PrimalFeedPost) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev  = make_like_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, post: post)
        
        feed.postBox.send(ev)
    }
    
    private func getLikes() {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }

        let request = [
            "authors": keypair.pubkey,
            "kinds": [7]
        ] as [String : Any]
        
        guard let json: JSON = try? JSON(["REQ", "\(subId)", request] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        feed.postBox.pool.send(.json(json))
    }
    
    private func handle_get_likes_event(relay: String, ev: NostrConnectionEvent) {
        switch ev {
        case .ws_event( _):
            break
        case .nostr_event(let resp):
            switch resp {
            case .notice(let msg):
                print(msg)
            case .event(let r, let ev):
                print("event")
            case .eose:
                break
            case .ok:
                break
            }
        }
    }
}
