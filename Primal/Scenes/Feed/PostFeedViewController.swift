//
//  PostFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.6.23..
//

import UIKit

class PostFeedViewController: FeedViewController {
    let feed: FeedManager
    
    init(feed: FeedManager) {
        self.feed = feed
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > posts.count - 10  {
            feed.requestNewPage()
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func postCellDidTapMute(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let pubkey = posts[indexPath.row].user.data.pubkey
        let mm = MuteManager.instance
        
        guard !mm.isMuted(pubkey) else {
            super.postCellDidTapMute(cell)
            return
        }
        
        feed.parsedPosts = feed.parsedPosts.filter { $0.user.data.pubkey != pubkey }
        super.postCellDidTapMute(cell)
    }
    
    override func updateTheme() {
        feed.updateTheme()
        
        super.updateTheme()
    }
}
