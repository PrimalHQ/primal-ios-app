//
//  PostingManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Combine
import Foundation

final class PostingManager {
    private init() {}
    
    static let instance: PostingManager = PostingManager()
    
    @Published var userReposts: Set<String> = []
    @Published var userReplied: Set<String> = []
    @Published var userLikes: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    func hasReposted(_ eventId: String) -> Bool { userReposts.contains(eventId) }
    func hasReplied(_ eventId: String) -> Bool { userReplied.contains(eventId) }
    func hasLiked(_ eventId: String) -> Bool { userLikes.contains(eventId) }
    
    var lastPostedEvent: NostrObject?
    
    func sendLikeEvent(post: PrimalFeedPost) {
        if LoginManager.instance.method() != .nsec { return }

        guard !hasLiked(post.id) else {
            return
        }
                
        guard let ev = NostrObject.like(post: post) else {
            print("Error creating nostr like event")
            return
        }
                
        userLikes.insert(post.id)
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
            // do nothing
        }, errorHandler: {
            self.userLikes.remove(ev.id)
        })
    }
    
    func sendMessageEvent(message: String, userPubkey: String, _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }
        
        guard let ev = NostrObject.message(message, recipientPubkey: userPubkey) else {
            print("Error creating message event")
            return
        }
        
        RelaysPostbox.instance.request(ev) { result in
            callback(true)
        } errorHandler: {
            callback(false)
        }
    }
    
    func sendRepostEvent(post: PrimalFeedPost) {
        if LoginManager.instance.method() != .nsec { return }

        guard var ev = NostrObject.repost(post) else {
            print("Error creating repost event")
            return
        }
        
        if let lastPostedEvent, lastPostedEvent.content == ev.content {
            ev = lastPostedEvent
        }
        lastPostedEvent = ev
        
        userReposts.insert(ev.id)
        RelaysPostbox.instance.request(ev, successHandler: { _ in
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
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
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
        
        userReplied.insert(post.universalID)
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
            callback(true)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            self.userReplied.remove(post.universalID)
            callback(false)
        })
    }
    
    func sendPostHighlightEvent(_ content: String, mentionedPubkeys: [String], highlight: NostrContent, article: Article, _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }

        guard var ev = NostrObject.postHighlight(content, highlight: highlight, article: article, mentionedPubkeys: mentionedPubkeys) else {
            callback(false)
            return
        }
        
        if let lastPostedEvent, lastPostedEvent.content == ev.content {
            ev = lastPostedEvent
        }
        lastPostedEvent = ev
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
            callback(true)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            callback(false)
        })
    }
    
    func sendHighlightEvent(_ content: String, article: Article, _ callback: @escaping (Bool) -> Void) -> NostrObject? {
        if LoginManager.instance.method() != .nsec { return nil }

        guard let ev = NostrObject.highlight(content, article: article) else {
            callback(false)
            return nil
        }
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
            callback(true)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            callback(false)
        })
        
        return ev
    }
    
    func deleteHighlightEvents(_ highlights: [Highlight], _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }
        
        guard let ev = NostrObject.delete(highlights) else {
            callback(false)
            return
        }
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
            callback(true)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            callback(false)
        })
    }
}
