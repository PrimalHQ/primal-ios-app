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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row > dataSource.cellCount - 30, dataSource.cellCount > 2 else { return }
        feed.requestNewPage()
    }
    
    override func postCellDidTap(_ cell: PostCell, _ event: PostCellEvent) {
        guard case .mute = event, let indexPath = table.indexPath(for: cell), let post = postForIndexPath(indexPath) else {
            super.postCellDidTap(cell, event)
            return
        }
        
        let pubkey = post.user.data.pubkey
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
