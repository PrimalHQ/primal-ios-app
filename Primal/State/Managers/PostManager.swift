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
    
    public func hasReposted(_ eventId: String) -> Bool { userReposts.contains(eventId) }
    public func hasReplied(_ eventId: String) -> Bool { userReplied.contains(eventId) }
    
    func sendRepostEvent(nostrContent: NostrContent) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_repost_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, nostrContent: nostrContent)
        
        if let repostEvent = ev {
            self.userReposts.insert(repostEvent.id)
            RelaysPostbox.instance.request(repostEvent, specificRelay: nil, successHandler: { _ in
                // do nothing
            }, errorHandler: {
                self.userReposts.remove(repostEvent.id)
            })
        } else {
            print("Error creating repost event")
        }
    }
    func sendPostEvent(_ content: String, mentionedPubkeys: [String], _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_post_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, content: content, mentionedPubkeys: mentionedPubkeys)
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            callback()
        }, errorHandler: {
            print("Posting failed for id: \(ev.id)")
        })
    }
    
    func sendReplyEvent(_ content: String, mentionedPubkeys: [String], post: PrimalFeedPost, _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let ev = make_reply_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, content: content, post: post, mentionedPubkeys: mentionedPubkeys)
        
        self.userReplied.insert(post.id)
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            // do nothing
        }, errorHandler: {
            self.userReplied.remove(post.id)
        })
    }
}
