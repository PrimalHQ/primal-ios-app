//
//  FeedManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Combine
import Foundation
import GenericJSON
import UIKit

final class FeedManager {
    private var cancellables: Set<AnyCancellable> = []
    
    private var isRequestingNewPage = false
    
    let postsEmitter: PassthroughSubject<PostRequestResult, Never> = .init()
        
    let newParsedPosts: PassthroughSubject<[ParsedContent], Never> = .init()
    @Published var parsedPosts: [ParsedContent] = []
    @Published var parsedLongForm: [Article] = []
    var paginationInfo: PrimalPagination?
    
    @Published var newAddedPosts = 0
    @Published var newPostObjects: [ParsedContent] = []
    @Published var newPosts: (Int, [ParsedUser]) = (0, [])
    
    @Published var currentFeed: PrimalSettingsFeed?
    @Published var newFeed: PrimalFeed?
    var profilePubkey: String?
    var didReachEnd = false
    
    var contentStyle = ParsedContentTextStyle.regular
    
    var lastRefreshDate: Date = .distantPast
    var blockFuturePosts: Bool { lastRefreshDate.timeIntervalSinceNow > -10 }
    
    // this is a map, matches post id of the repost with the original already added post in the post list
    var alreadyAddedReposts: [String: ParsedContent] = [:]

    var withRepliesOverride: Bool? {
        didSet {
            refresh()
        }
    }
    
    var addFuturePostsDirectly: () -> Bool = { true }
    
    init(loadLocalHomeFeed: Bool) {
        newFeed = PrimalFeed.getActiveFeeds(.note).first ?? .defaultNotesFeed
        
        initSubscriptions()
        refresh()
        
        if loadLocalHomeFeed {
            loadLocally()
        }
    }
    
    init(profilePubkey: String) {
        self.profilePubkey = profilePubkey
        initSubscriptions()
        refresh(useHTTP: true)
    }
    
    init(newFeed: PrimalFeed) {
        self.newFeed = newFeed
        initSubscriptions()
        refresh()
        initFuturePublishersAndObservers()
    }
    
    init(feed: PrimalSettingsFeed) {
        currentFeed = feed
        initSubscriptions()
        refresh()
    }
    
    init(search: String) {
        currentFeed = .init(name: "Search: \(search)", hex: "search;\(search)")
        initSubscriptions()
        refresh()
    }
    
    init(threadId: String) {
        contentStyle = .threadChildren
        initSubscriptions()
        requestThread(postId: threadId)
    }
    
    func updateTheme() {
        (newPostObjects + parsedPosts).forEach {
            $0.buildContentString(style: contentStyle)
            $0.embededPost?.buildContentString(style: .embedded)
        }
    }
    
    func didShowPost(_ index: Int) {
        guard index < newAddedPosts else { return }
        newAddedPosts = index
    }
    
    func addAllFuturePosts() {
        if !newPostObjects.isEmpty {
            parsedPosts.insert(contentsOf: newPostObjects, at: 0)
            newPostObjects = []
        }
        newAddedPosts = 0
    }
    
    func setCurrentFeed(_ feed: PrimalSettingsFeed) {
        currentFeed = feed
        refresh()
    }
    
    func refresh(useHTTP: Bool = false) {
        lastRefreshDate = .now
        newPostObjects = []
        newAddedPosts = 0
        alreadyAddedReposts = [:]
        parsedPosts.removeAll()
        parsedLongForm.removeAll()
        paginationInfo = nil
        isRequestingNewPage = false
        didReachEnd = false
        requestNewPage(useHTTP: useHTTP)
    }
    
    func requestNewPage(useHTTP: Bool = false) {
        guard !isRequestingNewPage, !didReachEnd else { return }
        guard paginationInfo?.order_by == nil || paginationInfo?.order_by == "created_at" else { return }
        isRequestingNewPage = true
        sendNewPageRequest(useHTTP: useHTTP)
    }
            
    func requestThread(postId: String, limit: Int32 = 100) {
        parsedPosts.removeAll()
        
        SocketRequest(
            useHTTP: true,
            name: "thread_view",
            payload: .object([
                "event_id": .string(postId),
                "limit": .number(Double(limit)),
                "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
            ])
        )
        .publisher()
        .sink { [weak self] result in
            self?.postsEmitter.send(result)
        }
        .store(in: &cancellables)
    }
}

private extension FeedManager {
    func loadLocally() {
        guard
            let data = HomeFeedLocalLoadingManager.savedFeed,
            !data.posts.isEmpty
        else {
            refresh()
            return
        }
        paginationInfo = data.pagination
        postsEmitter.send(data)
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        NotificationCenter.default.publisher(for: .userMuted)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pubkey in
                guard let self else { return }
                
                parsedPosts = parsedPosts.filter { $0.user.data.pubkey != pubkey && $0.reposted?.user?.data.pubkey != pubkey }
                newPostObjects = newPostObjects.filter { $0.user.data.pubkey != pubkey && $0.reposted?.user?.data.pubkey != pubkey }
            }
            .store(in: &cancellables)
        
        postsEmitter.sink { [weak self] result in
            guard let self else { return }
            
            self.parsedLongForm += result.getArticles()
            
            var sorted = result.process(contentStyle: contentStyle)
            
            if (self.parsedPosts.count > 0 || sorted.count > 0) && self.parsedPosts.last?.post.id == sorted.first?.post.id {
                 sorted.removeFirst()
            }
            
            if sorted.isEmpty {
                self.parsedPosts = self.parsedPosts
                didReachEnd = true
                return
            }
            
            let repostsGrouping = Dictionary(grouping: sorted.filter { $0.reposted != nil }, by: { $0.post.id })
            for (id, reposts) in repostsGrouping {
                // Remove same post without repost from page if it exists
                sorted = sorted.filter { $0.post.id != id || $0.reposted != nil }
                
                if let old = self.alreadyAddedReposts[id], let oldReposted = old.reposted {
                    old.reposted = .init(users: oldReposted.users + reposts.flatMap { $0.reposted?.users ?? [] }, date: oldReposted.date, id: oldReposted.id)
                } else if let first = reposts.first {
                    if let oldReposted = first.reposted {
                        first.reposted = .init(users: reposts.flatMap { $0.reposted?.users ?? [] }, date: oldReposted.date, id: oldReposted.id)
                    }
                    self.alreadyAddedReposts[id] = first
                }
            }
            // Now remove all grouped reposts, we do this by ensuring that the post is either not a repost or the designated main repost from the "alreadyAddedReposts" map
            sorted = sorted.filter { $0.reposted == nil || self.alreadyAddedReposts[$0.post.id] === $0 }
            
            if sorted.isEmpty {
                didReachEnd = true
                return
            }
                        
            self.newParsedPosts.send(sorted)
            self.parsedPosts += sorted
            self.isRequestingNewPage = false
        }
        .store(in: &cancellables)
    }
    
    /// This method is only required for the home feed manager
    func initFuturePublishersAndObservers() {
        Publishers.CombineLatest3($newAddedPosts, $newPostObjects, $parsedPosts)
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .map { added, notAdded, old  in (added + notAdded.count, (notAdded + old.prefix(added)).map { $0.user }) }
            .assign(to: \.newPosts, onWeak: self)
            .store(in: &cancellables)
        
        Publishers.Merge(
            Timer.publish(every: 30, on: .main, in: .default).autoconnect(),
            Timer.publish(every: 3, on: .main, in: .default).autoconnect().first()
        )
        .flatMap { [weak self] _ -> AnyPublisher<[ParsedContent], Never> in
            self?.futurePostsPublisher() ?? Just([]).eraseToAnyPublisher()
        }
        .sink { [weak self] sorted in
            guard let self, !blockFuturePosts else { return }
            
            processFuturePosts(sorted)
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .dropFirst()
            .flatMap { [weak self] _ in
                self?.futurePostsPublisher() ?? Just([]).eraseToAnyPublisher()
            }
            .sink { [weak self] sorted in
                guard let self, !blockFuturePosts else { return }

                processFuturePosts(sorted)
            }
            .store(in: &cancellables)
    }
    
    func futurePostsPublisher() -> AnyPublisher<[ParsedContent], Never> {
        let feed = newFeed
        
        guard
            let spec = newFeed?.spec,
            let paginationInfo,
            paginationInfo.order_by == "created_at",
            let until = paginationInfo.until
        else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return SocketRequest(name: "mega_feed_directive", payload: .object([
                "spec": .string(spec),
                "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
                "limit": .number(Double(40)),
                "since": .number(until.rounded())
            ]))
            .publisher()
            .receive(on: DispatchQueue.main)
            .map { [weak self] in
                guard let self else { return $0.process(contentStyle: .regular) }
                if let pagination = $0.pagination {
                    self.paginationInfo?.until = pagination.until
                }
                
                if $0.posts.count > 5 && feed?.name == "Latest" {
                    HomeFeedLocalLoadingManager.savedFeed = $0
                }
                
                return $0.process(contentStyle: contentStyle)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func processFuturePosts(_ sorted: [ParsedContent]) {
        var sorted = sorted.filter { post in
            !post.post.id.isEmpty &&
            !parsedPosts.contains(where: { $0.post.id == post.post.id }) &&
            !newPostObjects.contains(where: { $0.post.id == post.post.id })
        }
        
        let repostsGrouping = Dictionary(grouping: sorted.filter { $0.reposted != nil }, by: { $0.post.id })
        for (id, reposts) in repostsGrouping {
            // Remove same post without repost from page if it exists
            sorted = sorted.filter { $0.post.id != id || $0.reposted != nil }
            
            if let old = alreadyAddedReposts[id], let oldReposted = old.reposted {
                old.reposted = .init(users: oldReposted.users + reposts.flatMap { $0.reposted?.users ?? [] }, date: oldReposted.date, id: oldReposted.id)
            } else if let first = reposts.first {
                if let oldReposted = first.reposted {
                    first.reposted = .init(users: oldReposted.users + reposts.flatMap { $0.reposted?.users ?? [] }, date: oldReposted.date, id: oldReposted.id)
                }
                alreadyAddedReposts[id] = first
            }
        }
        // Now remove all grouped reposts, we do this by ensuring that the post is either not a repost or the designated main repost from the "alreadyAddedReposts" map
        sorted = sorted.filter { $0.reposted == nil || alreadyAddedReposts[$0.post.id] === $0 }

        if sorted.isEmpty { return }
        
        if newPostObjects.isEmpty && addFuturePostsDirectly() {
            parsedPosts.insert(contentsOf: sorted, at: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { // We need to wait for parsedPosts to propagate to posts
                self.newAddedPosts += sorted.count
            }
        } else {
            newPostObjects = sorted + newPostObjects
        }
    }
    
    // MARK: - Requests
    func sendNewPageRequest(useHTTP: Bool = false) {
        let (name, payload) = generateRequestByFeedType()
        
        SocketRequest(useHTTP: useHTTP, name: name, payload: payload).publisher()
            .sink { [weak self] result in
                guard let self else { return }
                
                defer { self.postsEmitter.send(result) }
                
                guard let pagination = result.pagination else { return }
                
                if var oldInfo = self.paginationInfo {
                    oldInfo.since = pagination.since
                    self.paginationInfo = oldInfo
                } else {
                    self.paginationInfo = pagination
                    
                    if self.currentFeed?.name == "Latest" {
                        HomeFeedLocalLoadingManager.savedFeed = result
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func generateRequestByFeedType() -> (String, JSON) {
        if let profilePubkey {
            return generateProfileFeedRequest(profilePubkey)
        }
        if let currentFeed {
            return generateFeedPageRequest(currentFeed)
        }
        if let newFeed {
            return generateNewFeedPageRequest(newFeed)
        }
        
        currentFeed = .latest
        return generateFeedPageRequest(.latest)
    }
    
    func generateNewFeedPageRequest(_ feed: PrimalFeed) -> (String, JSON) {
        var payload: [String: JSON] = [
            "spec": .string(feed.spec),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "limit": .number(Double(20))
        ]
        
        if let until: Double = paginationInfo?.since {
            payload["until"] = .number(until.rounded())
        }
        
        return ("mega_feed_directive", .object(payload))
    }
    
    func generateFeedPageRequest(_ feed: PrimalSettingsFeed) -> (String, JSON) {
        var payload: [String: JSON] = [
            "directive": .string(feed.hex),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "limit": 40
        ]
        
        if let until: Double = paginationInfo?.since {
            payload["until"] = .number(until.rounded())
        }
        
        if feed.includeReplies == true {
            payload["include_replies"] = .bool(feed.includeReplies ?? false)
        }
        
        return ("feed_directive", .object(payload))
    }
    
    func generateProfileFeedRequest(_ profileId: String) -> (String, JSON) {
        var payload: [String: JSON] = [
            "pubkey": .string(profileId),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "notes": .string("authored"),
            "limit": .number(40)
        ]
        
        if let until = paginationInfo?.since {
            payload["until"] = .number(until.rounded())
        } else if let last = parsedPosts.last {
            let until: Double = last.reposted?.date.timeIntervalSince1970 ?? last.post.created_at
            payload["until"] = .number(until.rounded())
        }
        
        if withRepliesOverride == true {
            payload["include_replies"] = true
        }
        
        return ("feed", .object(payload))
    }
}
