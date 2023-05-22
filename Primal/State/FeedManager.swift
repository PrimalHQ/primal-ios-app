//
//  FeedManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import Foundation

class FeedManager {
    let feed: SocketManager
    
    @Published var currentFeed: String = "Latest"
    @Published var posts: [PrimalPost] = []
    @Published var parsedPosts: [(PrimalPost, ParsedContent)] = []
    
    var isRequestingNewPage = false
    
    var cancellables: Set<AnyCancellable> = []
    
    var requestID = ""
    
    init(feed: SocketManager) {
        self.feed = feed
        
        feed.postsEmitter.sink { [weak self] (id, posts) in
            guard let self, id == self.requestID else { return }
            
            var sorted = posts.sorted(by: { $0.post.created_at > $1.post.created_at })
            if self.posts.last?.post.id == sorted.first?.post.id {
                sorted.removeFirst()
            }
            
            self.isRequestingNewPage = false
            self.posts.append(contentsOf: posts)
            self.parsedPosts.append(contentsOf: posts.process())
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(feed.$didFinishInit, feed.$isConnected.removeDuplicates()).sink { [weak self] didInit, isConnected in
            guard didInit, isConnected, self?.posts.isEmpty == true else { return }
            self?.refresh()
        }
        .store(in: &cancellables)
    }
    
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
        requestID = feed.requestNewPage(feedName: currentFeed, until: posts.last?.post.created_at ?? 0)
    }
}
