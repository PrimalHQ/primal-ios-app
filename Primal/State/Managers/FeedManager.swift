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
    
    let postsEmitter: PassthroughSubject<PostRequestResult, Never> = .init()
        
    let newParsedPosts: PassthroughSubject<[ParsedContent], Never> = .init()
    @Published var parsedPosts: [ParsedContent] = []
    @Published var searchPaginationEvent: PrimalSearchPagination?
    
    @Published var currentFeed: PrimalSettingsFeed?
    var profilePubkey: String?
    var didReachEnd = false
    var search: String?
    
    var muteObserver: AnyObject?
    
    init() {
        initPostsEmitterSubscription()
        initUserConnectionSubscription()
    }
    
    init(profilePubkey: String) {
        self.profilePubkey = profilePubkey
        initPostsEmitterSubscription()
        initUserConnectionSubscription()
    }
    
    init(search: String) {
        self.search = search
        currentFeed = .init(name: "Search: \(search)", hex: "search;\(search)")
        initPostsEmitterSubscription()
        refresh()
    }
    
    init(threadId: String) {
        initPostsEmitterSubscription()
        requestThread(postId: threadId)
    }
    
    deinit {
        if let muteObserver {
            NotificationCenter.default.removeObserver(muteObserver)
        }
    }
    
    func setCurrentFeed(_ feed: PrimalSettingsFeed) {
        currentFeed = feed
        refresh()
    }
    
    func refresh() {
        parsedPosts.removeAll()
        searchPaginationEvent = nil
        isRequestingNewPage = false
        didReachEnd = false
        requestNewPage()
    }
    
    func requestNewPage() {
        guard !isRequestingNewPage, !didReachEnd else { return }
        isRequestingNewPage = true
        Connection.dispatchQueue.async {
            self.sendNewPageRequest()
        }
    }
    
    func futurePostsPublisher() -> AnyPublisher<[ParsedContent], Never> {
        guard
            let directive = currentFeed?.hex,
            let first = parsedPosts.first
        else {
            return Just([]).eraseToAnyPublisher()
        }
        
        let since = first.reposted?.date.timeIntervalSince1970 ?? first.post.created_at
        
        return Connection.instance.$isConnected
            .filter { $0 }
            .first()
            .flatMap { _ in
                SocketRequest(name: "feed_directive", payload: .object([
                    "directive": .string(directive),
                    "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
                    "limit": .number(Double(40)),
                    "since": .number(since.rounded())
                ]))
                .publisher()
            }
            .map { $0.process() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    private func initPostsEmitterSubscription() {
        muteObserver = NotificationCenter.default.addObserver(forName: .userMuted, object: nil, queue: .main) { [weak self] notification in
            guard let self, let pubkey = notification.object as? String else { return }
            
            self.parsedPosts = self.parsedPosts.filter { $0.user.data.pubkey != pubkey && $0.reposted?.user?.data.pubkey != pubkey }
        }
        
        postsEmitter.sink { [weak self] result in
            guard let self else { return }
            
            var sorted = result.process()
            
            if (self.parsedPosts.count > 0 || sorted.count > 0) && self.parsedPosts.last?.post.id == sorted.first?.post.id {
                 sorted.removeFirst()
            }
            
            if sorted.isEmpty {
                didReachEnd = true
            }
            
            var parsed = self.parsedPosts
            
            let allReposts = sorted.filter { $0.reposted != nil }
            
            // First group all recieved reposts
            var groupedReposts: [ParsedContent] = []
            for repost in allReposts {
                guard
                    let index = groupedReposts.firstIndex(where: { $0.post.id == repost.post.id }),
                    let oldRepost = groupedReposts[index].reposted
                else {
                    groupedReposts.append(repost)
                    continue
                }
                
                groupedReposts[index].reposted = .init(users: oldRepost.users + (repost.reposted?.users ?? []), date: oldRepost.date, id: oldRepost.id)
            }
            
            // Filter reposts that are not already in posts
            var groupedRepostsNotAlreadyInPosts: [ParsedContent] = []
            for groupedRepost in groupedReposts {
                guard
                    let index = parsed.firstIndex(where: { $0.post.id == groupedRepost.post.id && $0.reposted != nil }),
                    let oldRepost = parsed[index].reposted
                else {
                    groupedRepostsNotAlreadyInPosts.append(groupedRepost)
                    continue
                }
                
                parsed[index].reposted = .init(users: oldRepost.users + (groupedRepost.reposted?.users ?? []), date: oldRepost.date, id: oldRepost.id)
            }
            
            // I tried matching by ID, I tried matching by date, I tried matching by user, but none of those situations work 100% of the time
            // Sometimes ID is the same for multiple repost events, sometimes user is the same for multiple report events, sometimes date is the same for multiple
            // Only thing that works is keeping a set of all existing reposts
            var addedIds = Set<String>()
            
            // To perserve the sorted order we must map the old sorted array, but skip reposts that are already added
            sorted = sorted.compactMap { post -> ParsedContent? in
                if post.reposted == nil { return post }
                
                return groupedRepostsNotAlreadyInPosts.first(where: {
                    if $0.post.id == post.post.id && !addedIds.contains($0.post.id) {
                        addedIds.insert($0.post.id)
                        return true
                    }
                    return false
                })
            }
            
            parsed += sorted
            
            self.newParsedPosts.send(sorted)
            self.parsedPosts = parsed
            self.isRequestingNewPage = false
        }
        .store(in: &cancellables)
    }
    private func initUserConnectionSubscription() {
        Publishers.CombineLatest3(IdentityManager.instance.$didFinishInit, Connection.instance.$isConnected.removeDuplicates(), IdentityManager.instance.$userSettings).sink { [weak self] didInit, isConnected, currentUserSettings in
            guard didInit, isConnected, self?.parsedPosts.isEmpty == true, let settings = currentUserSettings else { return }
            
            guard let feed = settings.content.feeds?.first else {
                print("no feed detected")
                return
            }
            
            self?.currentFeed = feed
            self?.refresh()
        }
        .store(in: &cancellables)
    }
    
    private func sendNewPageRequest(limit: Int32 = 20) {
        let json = generateRequestByFeedType(limit: limit)
        
        pendingResult = .init()
        Connection.instance.request(json) { res in
            for response in res {
                self.handlePostEvent(response)
            }
            self.emitPosts()
        }
    }
    
    private func generateRequestByFeedType(limit: Int32 = 20) -> JSON {
        if let profilePubkey {
            return generateProfileFeedRequest(profilePubkey)
        }
        if let currentFeed {
            return generateFeedPageRequest(currentFeed, limit: limit)
        }
        print("No feed error")
        return .object([:])
    }
    
    func requestThread(postId: String, limit: Int32 = 100) {
        pendingResult = .init()
        parsedPosts.removeAll()
        
        let request: JSON = .object([
            "cache": .array([
                .string("thread_view"),
                .object([
                    "event_id": .string(postId),
                    "limit": .number(Double(limit)),
                    "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
                ])
            ])
        ])
        
        Connection.instance.request(request) { res in
            for response in res {
                self.handlePostEvent(response)
            }
            self.emitPosts()
        }
    }
    
    private func generateFeedPageRequest(_ feed: PrimalSettingsFeed, limit: Int32 = 20) -> JSON {
        let until: Double = {
            if let since = searchPaginationEvent?.since { return since }
            
            guard let last = parsedPosts.last else { return Date().timeIntervalSince1970 }
            
            return last.reposted?.date.timeIntervalSince1970 ?? last.post.created_at
        }()
        
        var payload: [String: JSON] = [
            "directive": .string(feed.hex),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "limit": .number(Double(limit)),
            "until": .number(until.rounded())
        ]
        
        if feed.includeReplies == true {
            payload["include_replies"] = .bool(feed.includeReplies ?? false)
        }
        
        return .object([
            "cache": .array([
                .string("feed_directive"),
                .object(payload)
            ])
        ])
    }
    
    private func generateProfileFeedRequest(_ profileId: String, limit: Double = 20) -> JSON {
        let until: Double = {
            guard let last = parsedPosts.last else { return Date().timeIntervalSince1970 }
            return last.reposted?.date.timeIntervalSince1970 ?? last.post.created_at
        }()
        
        return .object([
            "cache": .array([
                .string("feed"),
                .object([
                    "pubkey": .string(profileId),
                    "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
                    "notes": .string("authored"),
                    "limit": .number(limit),
                    "until": .number(until.rounded())
                ])
            ])
        ])
    }
    
    private func emitPosts() {
        guard let data = pendingResult else { return }
        pendingResult = nil
        postsEmitter.send(data)
    }
    
    private func handlePostEvent(_ response: JSON) {
        let kind = NostrKind.fromGenericJSON(response)
        
        switch kind {
        case .metadata:
            guard let contentJSON = response.arrayValue?[2].objectValue else { return }
            
            let nostrUser = NostrContent(json: .object(contentJSON))
            if let user = PrimalUser(nostrUser: nostrUser) {
                pendingResult?.users[nostrUser.pubkey] = user
            }
        case .text:
            guard let contentJSON = response.arrayValue?[2].objectValue else { return }
            
            let content = NostrContent(json: .object(contentJSON))
            pendingResult?.posts.append(content)
            pendingResult?.order.append(content.id)
        case .noteStats:
            guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding NostrContentStats to json")
                return
            }
            
            pendingResult?.stats[nostrContentStats.event_id] = nostrContentStats
        case .searchPaginationSettingsEvent:
            guard let searchPaginationEvent: PrimalSearchPagination = try? JSONDecoder().decode(PrimalSearchPagination.self, from: Data((response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").utf8)) else {
                print("Error decoding PrimalSearchPagination to json")
                return
            }
            
            self.searchPaginationEvent = searchPaginationEvent
        case .noteActions:
            guard let noteStatus: PrimalNoteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding PrimalNoteStatus to json")
                return
            }
            if noteStatus.liked {
                LikeManager.instance.userLikes.insert(noteStatus.event_id)
            }
            if noteStatus.replied {
                PostManager.instance.userReplied.insert(noteStatus.event_id)
            }
            if noteStatus.reposted {
                PostManager.instance.userReposts.insert(noteStatus.event_id)
            }
            if noteStatus.zapped {
                ZapManager.instance.userZapped[noteStatus.event_id] = 0
            }
        case .repost:
            guard
                let payload = response.arrayValue?[2].objectValue,
                let pubKey = payload["pubkey"]?.stringValue,
                let contentString = payload["content"]?.stringValue,
                let dateNum = payload["created_at"]?.doubleValue,
                let id = payload["id"]?.stringValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else { return }
            
            let content = NostrContent(json: contentJSON)
            pendingResult?.reposts.append(.init(id: id, pubkey: pubKey, post: content, date: .init(timeIntervalSince1970: dateNum)))
            pendingResult?.order.append(content.id)
        case .mentions:
            guard
                let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else { return }
            pendingResult?.mentions.append(NostrContent(json: contentJSON))
        case .mediaMetadata:
            guard
                let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue,
                let metadata = try? JSONDecoder().decode(MediaMetadata.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult?.mediaMetadata.append(metadata)
        case .webPreview:
            guard
                let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue,
                let webPreview = try? JSONDecoder().decode(WebPreviews.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult?.webPreviews.append(webPreview)
        default:
            print("FeedManager: requestNewPage: Got unexpected event kind in response: \(kind)")
        }
    }
}
