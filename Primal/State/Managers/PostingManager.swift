//
//  PostingManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Combine
import Foundation
import UIKit

protocol PostingReferenceObject {
    var reference: (tagLetter: String, universalID: String)? { get }
    var referencePubkey: String { get }
}

extension ParsedFeedFromMarket: PostingReferenceObject {
    var reference: (tagLetter: String, universalID: String)? {
        guard let id = data.id, let pubkey = data.pubkey else {
            return nil
        }
        return ("a", "31990:\(pubkey):\(id)")
    }
    
    var referencePubkey: String { data.pubkey ?? "" }
}

extension PrimalFeedPost: PostingReferenceObject {
    var referencePubkey: String { pubkey }
       
    var universalID: String {
        guard
            let tagId = tags.first(where: { $0.first == "d" })?[safe: 1],
                kind == NostrKind.longForm.rawValue || kind == NostrKind.shortenedArticle.rawValue || kind == NostrKind.live.rawValue
        else { return id }
        
        return "\(kind):\(pubkey):\(tagId)"
    }
    
    var reference: (tagLetter: String, universalID: String)? { (referenceTagLetter, universalID) }
    
    var referenceTagLetter: String {
        kind == NostrKind.longForm.rawValue || kind == NostrKind.live.rawValue ? "a" : "e"
    }
}

extension Article: PostingReferenceObject {
    var reference: (tagLetter: String, universalID: String)? {
        guard
            event.kind == NostrKind.longForm.rawValue || event.kind == NostrKind.shortenedArticle.rawValue,
            let tagId = event.tags.first(where: { $0.first == "d" })?[safe: 1]
        else { return nil }
        
        return ("a", "\(NostrKind.longForm.rawValue):\(event.pubkey):\(tagId)")
    }
    
    var referenceTagLetter: String { "a" }
    
    var referencePubkey: String { event.pubkey }    
}

final class PostingManager {
    private init() {
        ICloudKeychainManager.instance.$userPubkey
            .flatMap { DatabaseManager.instance.getCompletedDrafts(userPubkey: $0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.draftsToPost, onWeak: self)
            .store(in: &cancellables)
        
        $draftsToPost
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] drafts in
                guard let self else { return }
                
                if drafts.isEmpty {
                    attemptToPostCancellable = nil
                    return
                }
                
                attemptToPostCancellable = Timer.publish(every: 15, on: .main, in: .default).autoconnect()
                    .prepend(Date())
                    .waitForConnection(Connection.regular)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self]  _ in
                        for draft in drafts {
                            self?.postDraft(draft)
                        }
                    })
            })
            .store(in: &cancellables)
        
        var notifiedEvs: Set<String> = []
        postedEvent.sink { obj in
            if obj.kind != NostrKind.text.rawValue { return }
            if notifiedEvs.contains(obj.id) { return }
            notifiedEvs.insert(obj.id)
            
            let isRoot = !obj.tags.contains(where: { tag in tag[safe: 3] == "root" })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                RootViewController.instance.finalChild.view.showToastTop("\(isRoot ? "Note" : "Reply") Published")
            }
        }
        .store(in: &cancellables)
    }
    
    func reset() {
        userReposts = []
        userReplied = []
        userLikes = []
    }
    
    static let instance: PostingManager = PostingManager()
    
    @Published var userReposts: Set<String> = []
    @Published var userReplied: Set<String> = []
    @Published var userLikes: Set<String> = []
    
    @Published var draftsToPost: [NoteDraft] = []
    @Published var attemptAmount: [String: Int] = [:]
    
    let postedEvent = PassthroughSubject<NostrObject, Never>()
    
    var cancellables: Set<AnyCancellable> = []
    var attemptToPostCancellable: AnyCancellable?
    
    func hasReposted(_ eventId: String) -> Bool { userReposts.contains(eventId) }
    func hasReplied(_ eventId: String) -> Bool { userReplied.contains(eventId) }
    func hasLiked(_ eventId: String) -> Bool { userLikes.contains(eventId) }
    
    func hasLiked(_ reference: PostingReferenceObject) -> Bool {
        guard let id = reference.reference?.universalID else { return false }
        return userLikes.contains(id)
    }
    
    var lastPostedEvent: NostrObject?
        
    func sendLikeEvent(referenceEvent: PostingReferenceObject) {
        if LoginManager.instance.method() != .nsec { return }
        
        guard let universalID = referenceEvent.reference?.universalID else { return }

        guard !hasLiked(referenceEvent) else {
            return
        }
                
        guard let ev = NostrObject.like(reference: referenceEvent) else {
            print("Error creating nostr like event")
            return
        }
                
        userLikes.insert(universalID)
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in
            // do nothing
        }, errorHandler: {
            self.userLikes.remove(universalID)
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
    
    func sendEvent(_ ev: NostrObject, _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }
        
        RelaysPostbox.instance.request(ev, successHandler: { [weak self] _ in
            callback(true)
            
            self?.postedEvent.send(ev)
            
            Connection.regular.requestCache(name: "import_events", payload: .object(["events": .array([ev.toJSON()])])) { _ in }
        }, errorHandler: {
            callback(false)
        })
    }
    
    func deleteHighlightEvents(_ highlights: [Highlight], _ callback: @escaping (Bool) -> Void) {
        if LoginManager.instance.method() != .nsec { return }
        
        guard let ev = NostrObject.deleteHighlights(highlights) else {
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

private extension PostingManager {
    func postDraft(_ draft: NoteDraft) {
        let numberOfTries = attemptAmount[draft.id, default: 0]
        
        print("\(draft.id) POST ATTEMPT \(Date())")
        
        if numberOfTries > 5 {
            RootViewController.instance.showToast("Couldn't publish your note", icon: UIImage(named: "toastX"))
            
            draftsToPost.removeAll(where: { $0.preparedEvent?.id == draft.preparedEvent?.id })
            var draft = draft
            draft.preparedEvent = nil
            DatabaseManager.instance.saveDraft(draft)
            return
        }
        
        guard let ev = draft.preparedEvent else { return }
        
        attemptAmount[draft.id, default: 0] += 1
        
        sendEvent(ev) { completed in
            if completed {
                print("\(draft.id) POST ATTEMPT SUCCESS")
                self.draftsToPost.removeAll(where: { $0.preparedEvent?.id == draft.preparedEvent?.id })
                
                self.attemptAmount[draft.id] = nil
                
                DatabaseManager.instance.deleteDraft(draft)
            } else {
                print("\(draft.id) POST ATTEMPT FAILED")
            }
        }
    }
}
