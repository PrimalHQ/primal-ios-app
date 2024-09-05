//
//  ArticleFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.8.24..
//

import Combine
import Foundation

class ArticleFeedManager {
    @Published var articles: [Article] = []
    
    let feed: ReadsFeed
    var paginationInfo: PrimalPagination?
    
    var cancellables: Set<AnyCancellable> = []
    init(feed: ReadsFeed) {
        self.feed = feed
        
        load()
    }
    
    func load() {
        let until = paginationInfo?.since ?? 0
        
//        return
        SocketRequest(name: "mega_feed_directive", payload: .object([
                "spec": .string(feed.spec),
                "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
                "limit": .number(Double(40)),
//                "until": .number(until.rounded())
            ]))
            .publisher()
            .map { $0.getArticles() }
            .receive(on: DispatchQueue.main)
            .assign(to: \.articles, onWeak: self)
//            .sink(receiveValue: { result in
//                print(result)
//            })
            .store(in: &cancellables)
    }
    
    func refresh() {
        load()
    }
}
