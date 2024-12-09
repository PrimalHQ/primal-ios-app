//
//  PostFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.6.23..
//

import UIKit

class PostFeedViewController: NoteViewController {
    let feed: FeedManager
    
    init(feed: FeedManager) {
        self.feed = feed
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > posts.count - 10  {
            feed.requestNewPage()
        }
        
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func postCellDidTap(_ cell: PostCell, _ event: PostCellEvent) {
        guard case .mute = event, let indexPath = table.indexPath(for: cell) else {
            super.postCellDidTap(cell, event)
            return
        }
        
        let pubkey = posts[indexPath.row].user.data.pubkey
        guard !MuteManager.instance.isMuted(pubkey) else {
            super.postCellDidTap(cell, .mute)
            return
        }
        
        feed.parsedPosts = feed.parsedPosts.filter { $0.user.data.pubkey != pubkey }
        super.postCellDidTap(cell, .mute)
    }
    
    override func updateTheme() {
        feed.updateTheme()
        
        super.updateTheme()
    }
}
