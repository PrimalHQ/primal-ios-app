//
//  FeedElementReactionsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementReactionsCell: PostCell {
    override class var cellID: String { "FeedElementReactionsCell" }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .pinToSuperview(edges: .top, padding: 0)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .leading, padding: 8)
            .pinToSuperview(edges: .trailing, padding: 32)
        
        bottomButtonStack.distribution = .fillEqually
        
        contentView.addSubview(bookmarkButton)
        bookmarkButton
            .pin(to: bottomButtonStack, edges: .trailing, padding: -18)
            .centerToView(bottomButtonStack, axis: .vertical)
            .constrainToSize(width: 40)
        
        contentView.addSubview(bottomBorder)
        bottomBorder.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        let postInfo = content.postInfo
        
        replyButton.set(postInfo.isReplied ? max(1, content.post.replies) : content.post.replies, filled: postInfo.isReplied)
        zapButton.set(content.post.satszapped + WalletManager.instance.extraZapAmount(content.post.id), filled: postInfo.isZapped)
        likeButton.set(postInfo.isLiked ? max(1, content.post.likes) : content.post.likes, filled: postInfo.isLiked)
        repostButton.set(postInfo.isReposted ? max(1, content.post.reposts) : content.post.reposts, filled: postInfo.isReposted)
        
        bookmarkUpdater = BookmarkManager.instance.isBookmarkedPublisher(content).receive(on: DispatchQueue.main)
            .sink { [weak self] isBookmarked in
                self?.isShowingBookmarked = isBookmarked
                self?.bookmarkButton.setImage(UIImage(named: isBookmarked ? "feedBookmarkFilled" : "feedBookmark"), for: .normal)
            }
    }
    
    override func updateMenu(_ content: ParsedContent) { }
}
