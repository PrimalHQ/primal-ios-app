//
//  MainThreadElementReactionsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

import Combine
import UIKit

class MainThreadElementReactionsCell: ThreadElementBaseCell, RegularFeedElementCell, ElementReactionsCell {
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
    
    let timeLabel = UILabel()
    
    let repliesLabel = UILabel()
    let zapsLabel = UILabel()
    let likesLabel = UILabel()
    let repostsLabel = UILabel()
    
    lazy var infoRow = UIStackView([repliesLabel, zapsLabel, likesLabel, repostsLabel, UIView()])
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
                
        setup()
        
        contentView.addSubview(bottomBorder)
        bottomBorder.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        
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
                self?.bookmarkButton.setImage(UIImage(named: isBookmarked ? "feedBookmarksBigFilled" : "feedBookmarksBig"), for: .normal)
            }
        
        timeLabel.text = content.longDateString()
        
        let post = content.post
        
        repliesLabel.attributedText = infoString(post.replies, "Reply", "Replies")
        repliesLabel.isHidden = post.replies <= 0
        
        zapsLabel.attributedText = infoString(post.zaps, "Zap", "Zaps")
        zapsLabel.isHidden = post.zaps <= 0
        
        likesLabel.attributedText = infoString(post.likes, "Like", "Likes")
        likesLabel.isHidden = post.likes <= 0
        
        repostsLabel.attributedText = infoString(post.reposts, "Repost", "Reposts")
        repostsLabel.isHidden = post.reposts <= 0
        
        infoRow.isHidden = post.replies + post.zaps + post.likes + post.reposts <= 0
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        bookmarkButton.tintColor = .foreground5
        bottomBorder.backgroundColor = .background3
    }
}

private extension MainThreadElementReactionsCell {
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
    
    func infoString(_ count: Int, _ singleTitle: String, _ pluralTitle: String) -> NSAttributedString {
        let title = count == 1 ? singleTitle : pluralTitle
        let text = NSMutableAttributedString(string: "\(count) ", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: UIColor.foreground
        ])
        text.append(.init(string: title, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ]))
        return text
    }
    
    func setup() {
        let mainStack = UIStackView(axis: .vertical, [timeLabel, infoRow, SpacerView(height: 4), SpacerView(height: 1, color: .background3), bottomButtonStack])
        mainStack.spacing = 8

        timeLabel.font = .appFont(withSize: 16, weight: .regular)
        infoRow.spacing = 12
        
        secondRow.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 12)
        
        [replyButton, zapButton, likeButton, repostButton].forEach {
            $0.titleLabel.removeFromSuperview()
            $0.bigMode = true
        }
        
        bottomButtonStack.addArrangedSubview(bookmarkButton)
        
        bookmarkButton.constrainToSize(width: 36)
        bookmarkButton.contentHorizontalAlignment = .center
        bottomButtonStack.distribution = .fill
        bottomButtonStack.arrangedSubviews.dropFirst().dropLast().forEach { view in
            view.widthAnchor.constraint(equalTo: replyButton.widthAnchor).isActive = true
        }
        
        bookmarkButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.postCellDidTap(self, isShowingBookmarked ? .unbookmark : .bookmark)
        }), for: .touchUpInside)
        
        zapsLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
        
        repostsLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .repostDetails)
        }))
        
        likesLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .likeDetails)
        }))
        
        [zapsLabel, repostsLabel, likesLabel].forEach { $0.isUserInteractionEnabled = true }
    }
}

extension ParsedContent {
    func longDateString() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(post.created_at))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy • hh:mm a"
        return dateFormatter.string(from: date)
    }
}
