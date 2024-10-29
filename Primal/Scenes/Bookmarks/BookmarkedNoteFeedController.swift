//
//  BookmarkedNoteFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 22.10.24..
//

import Combine
import UIKit

final class BookmarkedNoteFeedController: NoteFeedViewController {
    let emptyView = EmptyTableView(title: "Your bookmarks will appear here")
    
    init() {
        let feed = FeedManager(newFeed: .init(
            name: "Bookmarks",
            spec: "{\"id\":\"feed\",\"kind\":\"notes\",\"notes\":\"bookmarks\",\"pubkey\":\"\(IdentityManager.instance.userHexPubkey)\"}"
        ))
        super.init(feed: feed)
        
        feed.$parsedPosts.receive(on: DispatchQueue.main).assign(to: \.posts, onWeak: self).store(in: &cancellables)
        
        feed.$parsedPosts.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.refreshControl.endRefreshing()
                
                self?.emptyView.isHidden = !posts.isEmpty
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(emptyView)
        emptyView.pinToSuperview()
        emptyView.isHidden = true
        
        emptyView.refresh.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .touchUpInside)
    }
}
