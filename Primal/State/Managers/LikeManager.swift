//
//  LManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation

final class LManager {
    private init() {}
    
    static let the: LManager = LManager()
    
    func hasLiked(_ eventId: String) -> Bool { FdManager.the.userLikes.contains(eventId) }
    
    func sendLikeEvent(post: PrimalFeedPost) {
        guard
            !hasLiked(post.id),
            let keypair = get_saved_keypair()
        else {
            print("Error getting saved keypair")
            return
        }
        
        let ev  = make_like_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, post: post)
        
        RelaysPostBox.the.registerHandler(sub_id: ev.id, handler: self.handleLikeEvent)
        
        RelaysPostBox.the.send(ev)
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
                    FdManager.the.userLikes.insert(res.event_id)
                }
                break
            }
        }
    }
}
