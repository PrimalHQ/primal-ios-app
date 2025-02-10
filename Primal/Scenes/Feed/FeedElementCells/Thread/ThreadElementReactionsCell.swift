//
//  FeedElementReactionsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import Combine
import UIKit

class ThreadElementReactionsCell: ThreadElementBaseCell, RegularFeedElementCell, ElementReactionsCell {
    static var cellID: String { "FeedElementReactionsCell" }
    
    var bookmarkUpdater: AnyCancellable?
    var isShowingBookmarked = false
    
    let bottomBorder = UIView()
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let zapPreview = ZapPreviewView()
    let bookmarkButton = UIButton()
    lazy var bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        secondRow.addSubview(bottomButtonStack)
        bottomButtonStack
            .pinToSuperview(edges: .top, padding: 0)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .leading, padding: -8)
            .pinToSuperview(edges: .trailing, padding: 16)
        
        bottomButtonStack.distribution = .fillEqually
        
        contentView.addSubview(bookmarkButton)
        bookmarkButton
            .pin(to: bottomButtonStack, edges: .trailing, padding: -18)
            .centerToView(bottomButtonStack, axis: .vertical)
            .constrainToSize(width: 40)
        
        if position == .child {
            contentView.addSubview(bottomBorder)
            bottomBorder.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        }
        
        bottomButtonStack.distribution = .fillEqually
        bottomButtonStack.spacing = 12
        
        bottomBorder.backgroundColor = .background3
        
        repostButton.tintColor = UIColor(rgb: 0x757575)
        
        bookmarkButton.tintColor = .foreground5
        bookmarkButton.setImage(UIImage(named: "feedBookmark")?.scalePreservingAspectRatio(size: 18), for: .normal)
        bookmarkButton.contentHorizontalAlignment = .trailing
        bookmarkButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.postCellDidTap(self, isShowingBookmarked ? .unbookmark : .bookmark)
        }), for: .touchUpInside)
        
        if LoginManager.instance.method() == .nsec {
            likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
            repostButton.addTarget(self, action: #selector(repostTapped), for: .touchUpInside)
            replyButton.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
            
            let tap = BindableTapGestureRecognizer { [weak self] in
                guard let self else { return }
                delegate?.postCellDidTap(self, .zap)
            }
            let long = UILongPressGestureRecognizer(target: self, action: #selector(zapLongPressed))
            tap.require(toFail: long)
            zapButton.addGestureRecognizer(tap)
            zapButton.addGestureRecognizer(long)
        } else {
            ([likeButton, repostButton, replyButton, zapButton] as [UIControl]).forEach { $0.addDisabledNSecWarning(RootViewController.instance) }
        }
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
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        bookmarkButton.tintColor = .foreground5
        
        bottomBorder.backgroundColor = .background3
    }
    
    @objc func zapLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard case .began = recognizer.state else { return }
        delegate?.postCellDidTap(self, .longTapZap)
    }
    
    @objc func repostTapped() {
        delegate?.postCellDidTap(self, .repost)
    }
    
    @objc func replyTapped() {
        delegate?.postCellDidTap(self, .reply)
    }
    
    @objc func likeTapped() {
        likeButton.animView.play()
        likeButton.titleLabel.animateToColor(color: UIColor(rgb: 0xCA079F))

        delegate?.postCellDidTap(self, .like)
    }
}
