//
//  NoteFeedViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.10.24..
//

import UIKit

class NoteFeedViewController: PostFeedViewController {    
    override var posts: [ParsedContent] {
        didSet {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    override init(feed: FeedManager) {
        super.init(feed: feed)
        
        feed.addFuturePostsDirectly = { [weak self] in
            guard let self else { return true }
            return self.table.contentOffset.y > 300
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        setupPublishers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension NoteFeedViewController {
    func setupPublishers() {
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if posts.isEmpty {
                    if self?.refreshControl.isRefreshing == false {
                        self?.posts = []
                    }
                } else {
                    self?.posts = posts
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
}
