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
    
    func hasReposted(_ eventId: String) -> Bool { userReposts.contains(eventId) }
    func hasReplied(_ eventId: String) -> Bool { userReplied.contains(eventId) }
    
    func sendRepostEvent(nostrContent: NostrContent) {
        if LoginManager.instance.method() != .nsec { return }

        let ev = NostrObject.repost(nostrContent)
        
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
    
    func sendPostEvent(_ content: String, mentionedPubkeys: [String], _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }

        guard let ev = NostrObject.post(content, mentionedPubkeys: mentionedPubkeys) else {
            return
        }
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            callback(true)
            
            Connection.instance.requestCache(name: "import_events", request: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            print("Posting failed for id: \(ev.id)")
            callback(false)
        })
    }
    
    func sendReplyEvent(_ content: String, mentionedPubkeys: [String], post: PrimalFeedPost, _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }

        guard let ev = NostrObject.reply(content, post: post, mentionedPubkeys: mentionedPubkeys) else {
            callback(false)
            return
        }
        
        self.userReplied.insert(post.id)
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            callback(true)
            
            Connection.instance.requestCache(name: "import_events", request: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            self.userReplied.remove(post.id)
            callback(false)
        })
    }
}
