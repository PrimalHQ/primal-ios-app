//
//  ArticleFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.8.24..
//

import Combine
import Foundation

class ArticleFeedManager: BaseFeedManager {
    // Accessed from the main thread
    @Published var articles: [Article] = []
    
    @Published private var oldArticles: [Article] = []
    
    let feed: PrimalFeed    
    let hasPremium = WalletManager.instance.hasPremium
    private var cancellables: Set<AnyCancellable> = []
    init(feed: PrimalFeed) {
        self.feed = feed
        
        super.init(request: FeedManagerRequest(name: "mega_feed_directive", body: [
            "spec": .string(feed.spec),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
        ]))

        baseDelegate = self
        
        requestResultEmitter
            .map { $0.getArticles() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notes in
                guard let self else { return }
                self.articles = oldArticles + notes
                self.oldArticles = self.articles
            }
            .store(in: &cancellables)
        
        refresh()
    }
    
    override func refresh() {
        oldArticles = []
        
        super.refresh()
    }
    
    override func requestNewPage() {
        Self.dispatchQueue.async { [self] in
            guard !isRequestingNewPage, !didReachEnd else { return }
            
            if paginationInfo != nil, !hasPremium, feed.isFromAdvancedSearchScreen {
                didReachEnd = true
                return
            }
            
            isRequestingNewPage = true
            sendNewPageRequest()
        }
    }
}

extension ArticleFeedManager: BaseFeedManagerDelegate {
    func userMuted(pubkey: String) {
        articles = articles.filter { $0.user.data.pubkey != pubkey }
        oldArticles = oldArticles.filter { $0.user.data.pubkey != pubkey }
    }
    
    func requestOffset(until: Double) -> Int {
        1
    }
}
