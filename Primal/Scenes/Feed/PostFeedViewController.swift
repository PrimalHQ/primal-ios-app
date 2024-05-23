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
        
        feed.refreshCellMenuEmitter.receive(on: DispatchQueue.main).sink { [weak self] index in
            guard
                let self, self.view.window != nil,
                table.indexPathsForVisibleRows?.contains(where: { $0.row == index && $0.section == self.postSection }) == true
            else { return }
            
            if posts[index].zaps.count > 1, let cell = table.cellForRow(at: IndexPath(row: index, section: postSection)) as? PostCell {
                cell.updateMenu(posts[index])
            } else {
                table.reloadData()
            }
        }
        .store(in: &cancellables)
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
