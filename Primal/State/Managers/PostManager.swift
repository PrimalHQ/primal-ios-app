//
//  PostManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Combine
import Foundation

final class PostManager {
    private init() {}
    
    static let instance: PostManager = PostManager()
    
    @Published var userReposts: Set<String> = []
    @Published var userReplied: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    func hasReposted(_ eventId: String) -> Bool { userReposts.contains(eventId) }
    func hasReplied(_ eventId: String) -> Bool { userReplied.contains(eventId) }
    
    var lastPostedEvent: NostrObject?
    
    func sendMessageEvent(message: String, userPubkey: String, _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }
        
        guard let ev = NostrObject.message(message, recipientPubkey: userPubkey) else {
            print("Error creating message event")
            return
        }
        
        RelaysPostbox.instance.request(ev, specificRelay: nil) { result in
            callback(true)
        } errorHandler: {
            callback(false)
        }
    }
    
    func sendRepostEvent(nostrContent: NostrContent) {
        if LoginManager.instance.method() != .nsec { return }

        guard var ev = NostrObject.repost(nostrContent) else {
            print("Error creating repost event")
            return
        }
        
        if let lastPostedEvent, lastPostedEvent.content == ev.content {
            ev = lastPostedEvent
        }
        lastPostedEvent = ev
        
        self.userReposts.insert(ev.id)
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            // do nothing
        }, errorHandler: {
            self.userReposts.remove(ev.id)
        })
    }
    
    func sendPostEvent(_ content: String, mentionedPubkeys: [String], _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }

        guard var ev = NostrObject.post(content, mentionedPubkeys: mentionedPubkeys) else {
            callback(false)
            return
        }
        
        if let lastPostedEvent, lastPostedEvent.content == ev.content {
            ev = lastPostedEvent
        }
        lastPostedEvent = ev
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            callback(true)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            print("Posting failed for id: \(ev.id)")
            callback(false)
        })
    }
    
    func sendReplyEvent(_ content: String, mentionedPubkeys: [String], post: PrimalFeedPost, _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }

        guard var ev = NostrObject.reply(content, post: post, mentionedPubkeys: mentionedPubkeys) else {
            callback(false)
            return
        }
        
        if let lastPostedEvent, lastPostedEvent.content == ev.content {
            ev = lastPostedEvent
        }
        lastPostedEvent = ev
        
        self.userReplied.insert(post.id)
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            callback(true)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            self.userReplied.remove(post.id)
            callback(false)
        })
    }
}
