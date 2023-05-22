//
//  RepostingManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.5.23..
//

import Foundation

class RepostingManager {
    private var feed: SocketManager
    
    init(feed: SocketManager) {
        self.feed = feed
    }
    
    public func hasReposted(_ eventId: String) -> Bool { feed.currentUserReposts.contains(eventId) }
    
    func sendRepostEvent(nostrContent: NostrContent) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_repost_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, nostrContent: nostrContent)
        
        if let repostEvent = ev {
            feed.postBox.pool.register_handler(sub_id: repostEvent.id, handler: self.handleRepostEvent)
            
            feed.postBox.send(repostEvent)
        } else {
            print("Error creating repost event")
        }
    }
    
    private func handleRepostEvent(relayId: String, ev: NostrConnectionEvent) {
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
                    feed.currentUserReposts.insert(res.event_id)
                }
                break
            }
        }
    }
}
