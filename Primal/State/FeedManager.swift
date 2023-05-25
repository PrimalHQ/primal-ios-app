//
//  FeedManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import Foundation

final class FeedManager {
    let connection: SocketManager
    
    @Published var currentFeed: String = ""
    @Published var posts: [PrimalPost] = []
    @Published var parsedPosts: [(PrimalPost, ParsedContent)] = []
    
    private var isRequestingNewPage = false
    private var cancellables: Set<AnyCancellable> = []
    private var requestID = ""
    
    init(socket: SocketManager) {
        connection = socket
        
        socket.postsEmitter.sink { [weak self] (id, posts) in
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
        
        Publishers.CombineLatest3(socket.$didFinishInit, socket.$isConnected.removeDuplicates(), socket.$currentUserSettings).sink { [weak self] didInit, isConnected, currentUserSettings in
            guard didInit, isConnected, self?.posts.isEmpty == true, let settings = currentUserSettings else { return }
            
            guard let feedName = settings.content.feeds.first?.name else { fatalError("no feed detected") }
            
            self?.currentFeed = feedName
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
        requestID = connection.requestNewPage(feedName: currentFeed, until: posts.last?.post.created_at ?? 0)
    }
}
