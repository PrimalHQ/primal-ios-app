//
//  ArticleFeedViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.8.24..
//

import UIKit

class ArticleFeedViewController: ArticleListController {
    let manager: ArticleFeedManager
    init(feed: ReadsFeed) {
        manager = .init(feed: feed)
        
        super.init(nibName: nil, bundle: nil)
        
        manager.$articles.assign(to: \.articles, onWeak: self).store(in: &cancellables)
        
        manager.$articles.sink { [weak self] articles in
            self?.table.refreshControl?.endRefreshing()
        }
        .store(in: &cancellables)
        
        table.refreshControl = UIRefreshControl(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.manager.refresh()
        }))
        
        title = feed.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
