//
//  LikingManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 11.5.23..
//

import Foundation
import GenericJSON

final class LikingManager {
    let feed: SocketManager
    
    init(feed: SocketManager) {
        self.feed = feed
    }
    
    func hasLiked(_ eventId: String) -> Bool { feed.currentUserLikes.contains(eventId) }
    
    func sendLikeEvent(post: PrimalFeedPost) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev  = make_like_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, post: post)
        
        feed.postBox.pool.register_handler(sub_id: ev.id, handler: self.handleLikeEvent)
        
        feed.postBox.send(ev)
    }
    
    private func handleLikeEvent(relayId: String, ev: NostrConnectionEvent) {
        switch ev {
        case .ws_event(let wsev):
            switch wsev {
            case .connected:
                break
            case .error(let err):
                print(String(describing: err))
            default:
                break
            }
        case .nostr_event(let resp):
            switch resp {
            case .notice:
                break
            case .event:
                break
            case .eose:
                break
            case .ok(let res):
                if res.ok {
                    feed.currentUserLikes.insert(res.event_id)
                }
                break
            }
        }
    }
}
