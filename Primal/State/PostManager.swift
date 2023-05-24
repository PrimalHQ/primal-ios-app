//
//  PostingManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 24.5.23..
//

import Foundation

final class PostManager {
    private let feed: SocketManager
    
    init(feed: SocketManager) {
        self.feed = feed
    }
    
    public func hasReposted(_ eventId: String) -> Bool { feed.currentUserReposts.contains(eventId) }
    public func hasReplied(_ eventId: String) -> Bool { feed.currentUserReplied.contains(eventId) }
    
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
    func sendPostEvent(_ content: String, _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_post_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, content: content)
        
        feed.postBox.pool.register_handler(sub_id: ev.id, handler: handlePostEvent(callback))
        feed.postBox.send(ev)
    }
    func sendReplyEvent(_ content: String, post: PrimalFeedPost, _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_reply_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, content: content, post: post)
        
        feed.postBox.pool.register_handler(sub_id: ev.id, handler: handleReplyEvent(callback))
        feed.postBox.send(ev)
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
    private func handlePostEvent(_ callback: @escaping () -> Void) -> (_ relayId: String, _ ev: NostrConnectionEvent) -> Void {
        func handle(relayId: String, ev: NostrConnectionEvent) {
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
                        callback()
                    }
                    break
                }
            }
        }
        
        return handle
    }
    private func handleReplyEvent(_ callback: @escaping () -> Void) -> (_ relayId: String, _ ev: NostrConnectionEvent) -> Void {
        func handle(relayId: String, ev: NostrConnectionEvent) {
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
                        callback()
                    }
                    break
                }
            }
        }
        
        return handle
    }
}
