//
//  PostManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Foundation

final class PostManager {
    private init() {}
    
    static let instance: PostManager = PostManager()
    
    @Published var userReposts: Set<String> = []
    @Published var userReplied: Set<String> = []
    @Published var userZapped: Set<String> = []
    
    public func hasReposted(_ eventId: String) -> Bool { userReposts.contains(eventId) }
    public func hasReplied(_ eventId: String) -> Bool { userReplied.contains(eventId) }
    
    func sendRepostEvent(nostrContent: NostrContent) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_repost_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, nostrContent: nostrContent)
        
        if let repostEvent = ev {
            RelaysPostBox.the.registerHandler(sub_id: repostEvent.id, handler: self.handleRepostEvent)
            RelaysPostBox.the.send(repostEvent)
        } else {
            print("Error creating repost event")
        }
    }
    func sendPostEvent(_ content: String, mentionedPubkeys: [String], _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_post_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, content: content)
        ev.tags = mentionedPubkeys.map { ["p", $0, "", "mention"] }
        
        RelaysPostBox.the.registerHandler(sub_id: ev.id, handler: handlePostEvent(callback))
        RelaysPostBox.the.send(ev)
    }
    func sendReplyEvent(_ content: String, mentionedPubkeys: [String], post: PrimalFeedPost, _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_reply_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, content: content, post: post)
        ev.tags = mentionedPubkeys.map { ["p", $0, "", "mention"] }
        
        RelaysPostBox.the.registerHandler(sub_id: ev.id, handler: handleReplyEvent(callback))
        RelaysPostBox.the.send(ev)
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
                    userReposts.insert(res.event_id)
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
                        userReplied.insert(res.event_id)
                        callback()
                    }
                    break
                }
            }
        }
        
        return handle
    }
}
