//
//  PostReactionsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.6.24..
//

import Combine
import UIKit

// This is a cell that only contains the reactions bar
class PostReactionsCell: FeedElementBaseCell, RegularFeedElementCell, ElementReactionsCell {
    static var cellID: String { "FeedElementSmallZapGalleryCell" }
    
    var bookmarkUpdater: AnyCancellable?
    
    let repliesLabel = UILabel()
    let zapsLabel = UILabel()
    let likesLabel = UILabel()
    let repostsLabel = UILabel()
    
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let bookmarkButton = UIButton()
    
    lazy var infoRow = UIStackView([repliesLabel, zapsLabel, likesLabel, repostsLabel, UIView()])
    lazy var bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
                            
    let zapInfoView = SatoshiInfoView()
    let tagsView = PostTagsView()
    
    var isShowingBookmarked = false
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let descStack = UIStackView(axis: .vertical, [
            infoRow, SpacerView(height: 8),
            SpacerView(height: 1, color: .background3), SpacerView(height: 10),
            bottomButtonStack, SpacerView(height: 8)
        ])
        descStack.setCustomSpacing(16, after: infoRow)
        
        let mainStack = UIStackView(axis: .vertical, [tagsView, zapInfoView, descStack])
        mainStack.spacing = 12
        mainStack.setCustomSpacing(20, after: tagsView)
        
        infoRow.spacing = 12
        
        bottomButtonStack.distribution = .fill
        bottomButtonStack.arrangedSubviews.dropFirst().dropLast().forEach { view in
            view.widthAnchor.constraint(equalTo: replyButton.widthAnchor).isActive = true
        }
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 16)
            .pinToSuperview(edges: .horizontal, padding: 20)
        
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
        
        tagsView.tagPressed = { [weak self] tag in
            guard let self else { return }
            delegate?.postCellDidTap(self, .articleTag(tag))
        }
        
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
        
        bookmarkButton.tintColor = .foreground5
    }
    
    override func update(_ parsedContent: ParsedContent) {        
        zapInfoView.sats = parsedContent.post.satszapped
        
        tagsView.tags = parsedContent.post.tags.filter({ $0.first == "t" }).compactMap { $0[safe: 1] }
        tagsView.isHidden = tagsView.tags.isEmpty
        
        let post = parsedContent.post

        repliesLabel.attributedText = infoString(post.replies, "Reply", "Replies")
        repliesLabel.isHidden = post.replies <= 0
        
        zapsLabel.attributedText = infoString(post.zaps, "Zap", "Zaps")
        zapsLabel.isHidden = post.zaps <= 0
        
        likesLabel.attributedText = infoString(post.likes, "Like", "Likes")
        likesLabel.isHidden = post.likes <= 0
        
        repostsLabel.attributedText = infoString(post.reposts, "Repost", "Reposts")
        repostsLabel.isHidden = post.reposts <= 0
        
        infoRow.isHidden = post.replies + post.zaps + post.likes + post.reposts <= 0
        
        bookmarkUpdater = BookmarkManager.instance.isBookmarkedPublisher(parsedContent).receive(on: DispatchQueue.main)
            .sink { [weak self] isBookmarked in
                self?.isShowingBookmarked = isBookmarked
                self?.bookmarkButton.setImage(UIImage(named: isBookmarked ? "feedBookmarksBigFilled" : "feedBookmarksBig"), for: .normal)
            }
        
        let postInfo = parsedContent.postInfo
        
        replyButton.set(postInfo.isReplied ? max(1, post.replies) : post.replies, filled: postInfo.isReplied)
        zapButton.set(post.satszapped + WalletManager.instance.extraZapAmount(post.id), filled: postInfo.isZapped)
        likeButton.set(postInfo.isLiked ? max(1, post.likes) : post.likes, filled: postInfo.isLiked)
        repostButton.set(postInfo.isReposted ? max(1, post.reposts) : post.reposts, filled: postInfo.isReposted)
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

extension PostReactionsCell: ZapGalleryViewDelegate {
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration? {
        delegate?.menuConfigurationForZap(zap)
    }
    
    func mainActionForZap(_ zap: ParsedZap) {
        delegate?.mainActionForZap(zap)
    }
    
    func zapTapped(_ zap: ParsedZap) {
        delegate?.postCellDidTap(self, .zapDetails)
    }
}


class SatoshiInfoView: UIView {
    var sats: Int = 0 {
        didSet {
            updateInfo()
        }
    }
    
    private let satLabel = UILabel()
    private let dollarLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let image = UIImageView(image: UIImage(named: "zapSatInfo"))
        image.transform = .init(translationX: 0, y: -2)
        
        let stack = UIStackView([
            image,                                                  SpacerView(width: 4),
            satLabel,                                               SpacerView(width: 6),
            SpacerView(width: 1, height: 20, color: .foreground6),  SpacerView(width: 6),
            dollarLabel,                                            UIView()
        ])
        
        addSubview(stack)
        stack.pinToSuperview()
        stack.alignment = .center
        
        updateInfo()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateInfo() {
        let satString = NSMutableAttributedString(string: "\(sats.localized()) ", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground
        ])
        satString.append(.init(string: "sats", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]))
        satLabel.attributedText = satString
        
        let dollarString = NSMutableAttributedString(string: "$\(sats.satsToUsdAmountString(.twoDecimals)) ", attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ])
        dollarString.append(.init(string: "USD", attributes: [
            .font: UIFont.appFont(withSize: 12, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ]))
        dollarLabel.attributedText = dollarString
    }
}
