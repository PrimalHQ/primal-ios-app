//
//  FeedManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Combine
import Foundation
import GenericJSON

class ResponseBuffer {
    var posts: [NostrContent] = []
    var users: [String: NostrContent] = [:]
    var stats: [String: NostrContentStats] = [:]
}

final class FdManager {
    private var requestID = ""
    private var cancellables: Set<AnyCancellable> = []
    private var postCache: [String : ResponseBuffer] = [:]
    private var isRequestingNewPage = false
    
    private init() {
        initPostsEmitterSubscription()
        initUserConnectionSubscription()
    }
    
    static let the: FdManager = FdManager()
    
    let postsEmitter: PassthroughSubject<(String, [PrimalPost]), Never> = .init()
    
    @Published var currentFeed: String = ""
    @Published var posts: [PrimalPost] = []
    @Published var parsedPosts: [(PrimalPost, ParsedContent)] = []
    @Published var searchPaginationEvent: PrimalSearchPagination?
    @Published var userLikes: Set<String> = []
    @Published var userReposts: Set<String> = []
    @Published var userReplied: Set<String> = []
    @Published var userZapped: Set<String> = []
    @Published var feedUsers: [PrimalUser] = []
    
    func setCurrentFeed(_ feed: String) {
        currentFeed = feed
        refresh()
    }
    
    func refresh() {
        posts.removeAll()
        parsedPosts.removeAll()
        isRequestingNewPage = false
        requestNewPage()
    }
    
    func requestNewPage() {
        guard !isRequestingNewPage else { return }
        isRequestingNewPage = true
        requestID = requestNewPage(feedName: currentFeed, until: posts.last?.post.created_at ?? 0)
    }
    
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        self.postCache[subId] = .init()
        
        guard let json: JSON = try? JSON(
            ["REQ", "\(subId)", ["cache": ["thread_view", ["event_id": "\(postId)", "limit": limit, "user_pubkey": IdentityManager.the.userHex]
                                           as [String : Any]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        Connection.the.send(json: json) { res in
            for response in res {
                let kind = ResponseKind.fromGenericJSON(response)
                let id = json.arrayValue?[1].stringValue
                
                switch kind {
                case .text:
                    if let id {
                        self.postCache[id]?.posts.append(NostrContent(json: response))
                    }
                case .noteStats:
                    guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding nostrContentStats: NostrContentStats to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    
                    if let id {
                        self.postCache[id]?.stats[nostrContentStats.event_id] = nostrContentStats
                    }
                case .searchPaginationSettingsEvent:
                    guard let searchPaginationEvent: PrimalSearchPagination = try? JSONDecoder().decode(PrimalSearchPagination.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding PrimalSearchPagination to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    
                    self.searchPaginationEvent = searchPaginationEvent
                    self.searchPaginationEvent?.subId = json.arrayValue?[1].stringValue
                    break
                case .noteActions:
                    guard let noteStatus: PrimalNoteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding PrimalNoteStatus to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    if noteStatus.liked {
                        self.userLikes.insert(noteStatus.event_id)
                    }
                    if noteStatus.replied {
                        self.userReplied.insert(noteStatus.event_id)
                    }
                    if noteStatus.reposted {
                        self.userReposts.insert(noteStatus.event_id)
                    }
                    if noteStatus.zapped {
                        self.userZapped.insert(noteStatus.event_id)
                    }
                default:
                    assertionFailure("FeedManager: requestNewPage: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    
    private func initPostsEmitterSubscription() {
        postsEmitter.sink { [weak self] (id, posts) in
            guard let self, id == self.requestID else { return }
            
            var sorted = posts.sorted(by: { $0.post.created_at > $1.post.created_at })
            if (self.posts.count > 0 || sorted.count > 0) && self.posts.last?.post.id == sorted.first?.post.id {
                sorted.removeFirst()
            }
            
            self.posts.append(contentsOf: sorted)
            self.parsedPosts.append(contentsOf: sorted.process())
            self.isRequestingNewPage = false
        }
        .store(in: &cancellables)
    }
    private func initUserConnectionSubscription() {
        Publishers.CombineLatest3(IdentityManager.the.$didFinishInit, Connection.the.$isConnected.removeDuplicates(), IdentityManager.the.$userSettings).sink { [weak self] didInit, isConnected, currentUserSettings in
            guard didInit, isConnected, self?.posts.isEmpty == true, let settings = currentUserSettings else { return }
            
            guard let feedName = settings.content.feeds.first?.name else { fatalError("no feed detected") }
            
            self?.currentFeed = feedName
            self?.refresh()
        }
        .store(in: &cancellables)
    }
    
    private func requestNewPage(feedName: String, until: Int32 = 0, limit: Int32 = 20) -> String {
        guard
            let json = generateRequestByFeedType(feedName: feedName, until: until, limit: limit),
            let id = json.arrayValue?.dropFirst().first?.stringValue
        else {
            print("Error encoding req json")
            return ""
        }
        self.postCache[id] = .init()
        Connection.the.send(json: json) { res in
            for response in res {
                let kind = ResponseKind.fromGenericJSON(response)
                let id = json.arrayValue?[1].stringValue
                
                switch kind {
                case .metadata:
                    let nostrUser = NostrContent(json: response)
                    if let primalUser = PrimalUser(nostrUser: nostrUser) {
                        self.feedUsers.append(primalUser)
                    }
                case .text:
                    if let id {
                        self.postCache[id]?.posts.append(NostrContent(json: response))
                    }
                case .noteStats:
                    guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding NostrContentStats to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    
                    if let id {
                        self.postCache[id]?.stats[nostrContentStats.event_id] = nostrContentStats
                    }
                case .searchPaginationSettingsEvent:
                    guard let searchPaginationEvent: PrimalSearchPagination = try? JSONDecoder().decode(PrimalSearchPagination.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding PrimalSearchPagination to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    
                    self.searchPaginationEvent = searchPaginationEvent
                    self.searchPaginationEvent?.subId = json.arrayValue?[1].stringValue
                    break
                case .noteActions:
                    guard let noteStatus: PrimalNoteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding PrimalNoteStatus to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    if noteStatus.liked {
                        self.userLikes.insert(noteStatus.event_id)
                    }
                    if noteStatus.replied {
                        self.userReplied.insert(noteStatus.event_id)
                    }
                    if noteStatus.reposted {
                        self.userReposts.insert(noteStatus.event_id)
                    }
                    if noteStatus.zapped {
                        self.userZapped.insert(noteStatus.event_id)
                    }
                case .repost:
                    print("got repost")
                case .mentions:
                    print("got mention")
                default:
                    assertionFailure("FeedManager: requestNewPage: Got unexpected event kind in response: \(response)")
                }
            }
        }
        return id
    }
    
    private func generateRequestByFeedType(feedName: String, until: Int32 = 0, limit: Int32 = 20) -> JSON? {
        if let feed = IdentityManager.the.userSettings?.content.feeds.first(where: { $0.name == feedName }) {
            return generateFeedPageRequest(feed.hex, until: until, limit: limit)
        } else {
            fatalError("feed should exist at all times")
        }
    }
    
    private func generateFeedPageRequest(_ criteria: String, until: Int32 = 0, limit: Int32 = 20) -> JSON? {
        let key = until == 0 ? "since" : "until"
        let subId = "feed_\(criteria)_\(Connection.the.identity)"
        
        let u = searchPaginationEvent?.subId == subId ? (searchPaginationEvent?.since ?? until) : until
        
        return try? JSON([
            "REQ",
            subId,
            [
                "cache":
                    [
                        "feed_directive",
                        [
                            "directive": criteria,
                            "user_pubkey": IdentityManager.the.userHex,
                            "limit": limit,
                            "\(key)": u
                        ] as [String : Any]
                    ] as [Any]
            ]
        ] as [Any])
    }
    
    private func emitPosts(subId: String) {
        guard let data = postCache[subId] else { return }
        postCache[subId] = nil
        let posts: [PrimalPost] = data.posts.compactMap { nostrPost in
            guard
                let nostrUser = data.users[nostrPost.pubkey],
                let nostrPostStats = data.stats[nostrPost.id],
                let primalUser = PrimalUser(nostrUser: nostrUser, nostrPost: nostrPost)
            else { return nil }
            
            let primalFeedPost = PrimalFeedPost(nostrPost: nostrPost, nostrPostStats: nostrPostStats)
            
            let primalPost = PrimalPost(id:UUID().uuidString, user: primalUser, post: primalFeedPost)
            
            return primalPost
        }
        
        postsEmitter.send((subId, posts))
    }
}
