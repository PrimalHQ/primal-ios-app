//
//  FeedManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Combine
import Foundation
import GenericJSON

final class FeedManager {
    private var requestID = ""
    private var cancellables: Set<AnyCancellable> = []
    private var postCache: [String : PostRequestResult] = [:]
    private var isRequestingNewPage = false
    
    private init() {
        initPostsEmitterSubscription()
        initUserConnectionSubscription()
    }
    
    static let the: FeedManager = FeedManager()
    
    let postsEmitter: PassthroughSubject<PostRequestResult, Never> = .init()
    
    @Published var currentFeed: String = ""
    @Published var parsedPosts: [ParsedContent] = []
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
        parsedPosts.removeAll()
        isRequestingNewPage = false
        requestNewPage()
    }
    
    func requestNewPage() {
        guard !isRequestingNewPage else { return }
        isRequestingNewPage = true
        requestID = requestNewPage(feedName: currentFeed, until: parsedPosts.last?.post.created_at ?? 0)
    }
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        self.postCache[subId] = .init(id: subId)
        
        guard let json: JSON = try? JSON(
            ["REQ", "\(subId)", ["cache": ["thread_view", ["event_id": "\(postId)", "limit": limit, "user_pubkey": IdentityManager.the.userHex]
                                           as [String : Any]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        Connection.the.send(json: json) { res in
            for response in res {
                self.handlePostEvent(response)
            }
            guard let id = res.last?.arrayValue?[1].stringValue else { return }
            self.emitPosts(subId: id)
        }
    }
    
    private func initPostsEmitterSubscription() {
        postsEmitter.sink { [weak self] result in
            guard let self, result.id == self.requestID else { return }
            
            var sorted = result.process()
            
            if (self.parsedPosts.count > 0 || sorted.count > 0) && self.parsedPosts.last?.post.id == sorted.first?.post.id {
                 sorted.removeFirst()
            }
            
            self.parsedPosts.append(contentsOf: sorted)
            self.isRequestingNewPage = false
        }
        .store(in: &cancellables)
    }
    private func initUserConnectionSubscription() {
        Publishers.CombineLatest3(IdentityManager.the.$didFinishInit, Connection.the.$isConnected.removeDuplicates(), IdentityManager.the.$userSettings).sink { [weak self] didInit, isConnected, currentUserSettings in
            guard didInit, isConnected, self?.parsedPosts.isEmpty == true, let settings = currentUserSettings else { return }
            
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
        self.postCache[id] = .init(id: id)
        Connection.the.send(json: json) { res in
            for response in res {
                self.handlePostEvent(response)
            }
            guard let id = res.last?.arrayValue?[1].stringValue else { return }
            self.emitPosts(subId: id)
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
        postsEmitter.send(data)
    }
    private func handlePostEvent(_ response: JSON) {
        let kind = ResponseKind.fromGenericJSON(response)
        let id = response.arrayValue?[1].stringValue
        
        switch kind {
        case .metadata:
            guard let contentJSON = response.arrayValue?[2].objectValue else { return }
            
            let nostrUser = NostrContent(json: .object(contentJSON))
            if let id {
                postCache[id]?.users[nostrUser.pubkey] = nostrUser
            }
        case .text:
            guard let id, let contentJSON = response.arrayValue?[2].objectValue else { return }
            
            postCache[id]?.posts.append(NostrContent(json: .object(contentJSON)))
        case .noteStats:
            guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding NostrContentStats to json")
                dump(response.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            
            if let id {
                self.postCache[id]?.stats[nostrContentStats.event_id] = nostrContentStats
            }
        case .searchPaginationSettingsEvent:
            guard let searchPaginationEvent: PrimalSearchPagination = try? JSONDecoder().decode(PrimalSearchPagination.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding PrimalSearchPagination to json")
                dump(response.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            
            self.searchPaginationEvent = searchPaginationEvent
            self.searchPaginationEvent?.subId = response.arrayValue?[1].stringValue
            break
        case .noteActions:
            guard let noteStatus: PrimalNoteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding PrimalNoteStatus to json")
                dump(response.arrayValue?[2].objectValue?["content"]?.stringValue)
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
            guard
                let id,
                let pubKey = response.arrayValue?[2].objectValue?["pubkey"]?.stringValue,
                let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue,
                let contentData = contentString.data(using: .utf8),
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: contentData)
            else { return }
            
            postCache[id]?.reposts.append(.init(pubkey: pubKey, post: NostrContent(json: contentJSON)))
        case .mentions:
            guard
                let id,
                let contentString = response.arrayValue?[2].objectValue!["content"]?.stringValue,
                let contentData = contentString.data(using: .utf8),
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: contentData)
            else { return }
            postCache[id]?.mentions.append(NostrContent(json: contentJSON))
        default:
            assertionFailure("FeedManager: requestNewPage: Got unexpected event kind in response: \(response)")
        }
    }
}
