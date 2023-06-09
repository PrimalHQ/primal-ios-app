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
    private var cancellables: Set<AnyCancellable> = []
    
    private var pendingResult: PostRequestResult?
    private var isRequestingNewPage = false
    
    init() {
        initPostsEmitterSubscription()
        initUserConnectionSubscription()
    }
    
    static let instance: FeedManager = FeedManager()
    
    let postsEmitter: PassthroughSubject<PostRequestResult, Never> = .init()
    
    @Published var currentFeed: String = ""
    @Published var parsedPosts: [ParsedContent] = []
    @Published var searchPaginationEvent: PrimalSearchPagination?
    @Published var userLikes: Set<String> = []
    @Published var userReposts: Set<String> = []
    @Published var userReplied: Set<String> = []
    @Published var userZapped: Set<String> = []
    @Published var feedUsers: [PrimalUser] = []
    
    var profileId: String?
    
    init(profilePubkey: String) {
        self.profileId = profilePubkey
        initPostsEmitterSubscription()
        initUserConnectionSubscription()
    }
    
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
        Connection.dispatchQueue.async {
            self.sendNewPageRequest()
        }
    }
    
    private func initPostsEmitterSubscription() {
        postsEmitter.sink { [weak self] result in
            guard let self else { return }
            
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
        Publishers.CombineLatest3(IdentityManager.instance.$didFinishInit, Connection.instance.$isConnected.removeDuplicates(), IdentityManager.instance.$userSettings).sink { [weak self] didInit, isConnected, currentUserSettings in
            guard didInit, isConnected, self?.parsedPosts.isEmpty == true, let settings = currentUserSettings else { return }
            
            guard let feedName = settings.content.feeds.first?.name else { fatalError("no feed detected") }
            
            self?.currentFeed = feedName
            self?.refresh()
        }
        .store(in: &cancellables)
    }
    
    private func sendNewPageRequest(limit: Int32 = 20) {
        guard
            let json = generateRequestByFeedType(limit: limit),
            let id = json.arrayValue?.dropFirst().first?.stringValue
        else {
            print("Error encoding req json")
            return
        }
        
        pendingResult = .init(id: id)
        Connection.instance.send(json: json) { res in
            for response in res {
                self.handlePostEvent(response)
            }
            self.emitPosts()
        }
    }
    
    private func generateRequestByFeedType(limit: Int32 = 20) -> JSON? {
        if let profileId {
            return generateProfileFeedRequest(profileId)
        } else if let feed = IdentityManager.instance.userSettings?.content.feeds.first(where: { $0.name == currentFeed }) {
            return generateFeedPageRequest(feed.hex, limit: limit)
        } else {
            fatalError("feed should exist at all times")
        }
    }
    
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        Connection.dispatchQueue.async {
            self.pendingResult = .init(id: subId)
            
            guard let json: JSON = try? JSON(
                ["REQ", "\(subId)", ["cache": ["thread_view", ["event_id": "\(postId)", "limit": limit, "user_pubkey": IdentityManager.instance.userHex]
                                               as [String : Any]] as [Any]]] as [Any]) else {
                print("Error encoding req")
                return
            }
            
            
            Connection.instance.send(json: json) { res in
                for response in res {
                    self.handlePostEvent(response)
                }
                self.emitPosts()
            }
        }
    }
    
    private func generateFeedPageRequest(_ criteria: String, limit: Int32 = 20) -> JSON? {
        let subId = "feed_\(criteria)_\(Connection.instance.identity)"
        
        let until = parsedPosts.last?.post.created_at ?? Int32(Date().timeIntervalSince1970)
        
        let u = searchPaginationEvent?.subId == subId ? (searchPaginationEvent?.since ?? until) : until
        
        return try? JSON([
            "REQ",
            subId,
            [
                "cache": [
                    "feed_directive",
                    [
                        "directive": criteria,
                        "user_pubkey": IdentityManager.instance.userHex,
                        "limit": limit,
                        "until": u
                    ] as [String : Any]
                ] as [Any]
            ]
        ] as [Any])
    }
    
    private func generateProfileFeedRequest(_ profileId: String, limit: Int32 = 20) -> JSON? {
        let subId = "feed_profile\(profileId)"
        
        let until = parsedPosts.last?.post.created_at ?? Int32(Date().timeIntervalSince1970)
        
        return try? JSON([
            "REQ",
            subId,
            [
                "cache": [
                    "feed",
                    [
                        "pubkey": profileId,
                        "user_pubkey": IdentityManager.instance.userHex,
                        "notes": "authored",
                        "limit": limit,
                        "until": until
                    ] as [String : Any]
                ] as [Any]
            ]
        ] as [Any])
    }
    
    private func emitPosts() {
        guard let data = pendingResult else { return }
        pendingResult = nil
        postsEmitter.send(data)
    }
    
    private func handlePostEvent(_ response: JSON) {
        let kind = ResponseKind.fromGenericJSON(response)
        
        switch kind {
        case .metadata:
            guard let contentJSON = response.arrayValue?[2].objectValue else { return }
            
            let nostrUser = NostrContent(json: .object(contentJSON))
            if let user = PrimalUser(nostrUser: nostrUser) {
                pendingResult?.users[nostrUser.pubkey] = user
            }
        case .text:
            guard let contentJSON = response.arrayValue?[2].objectValue else { return }
            
            pendingResult?.posts.append(NostrContent(json: .object(contentJSON)))
        case .noteStats:
            guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding NostrContentStats to json")
                return
            }
            
            pendingResult?.stats[nostrContentStats.event_id] = nostrContentStats
        case .searchPaginationSettingsEvent:
            guard let searchPaginationEvent: PrimalSearchPagination = try? JSONDecoder().decode(PrimalSearchPagination.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding PrimalSearchPagination to json")
                return
            }
            
            self.searchPaginationEvent = searchPaginationEvent
            self.searchPaginationEvent?.subId = response.arrayValue?[1].stringValue
        case .noteActions:
            guard let noteStatus: PrimalNoteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding PrimalNoteStatus to json")
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
                let pubKey = response.arrayValue?[2].objectValue?["pubkey"]?.stringValue,
                let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult?.reposts.append(.init(pubkey: pubKey, post: NostrContent(json: contentJSON)))
        case .mentions:
            guard
                let contentString = response.arrayValue?[2].objectValue!["content"]?.stringValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else { return }
            pendingResult?.mentions.append(NostrContent(json: contentJSON))
        case .mediaMetadata:
            guard
                let contentString = response.arrayValue?[2].objectValue!["content"]?.stringValue,
                let metadata = try? JSONDecoder().decode(MediaMetadata.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult?.mediaMetadata.append(metadata)
        default:
            assertionFailure("FeedManager: requestNewPage: Got unexpected event kind in response: \(response)")
        }
    }
}
