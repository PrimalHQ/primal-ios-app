//
//  PostCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.5.23..
//

import Combine
import UIKit
import Kingfisher
import LinkPresentation
import FLAnimatedImage
import Nantes

protocol PostCellDelegate: AnyObject {
    func postCellDidTap(_ cell: PostCell, _ event: PostCellEvent)
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration?
    func mainActionForZap(_ zap: ParsedZap)
}

/// Base class, not meant to be instantiated as is, use child classes like FeedCell
class PostCell: UITableViewCell {
    class var cellID: String { "PostCell" }
    
    weak var delegate: PostCellDelegate?
    
    let bottomBorder = UIView()
    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: FontSizeSelection.current.avatarSize)
    let checkbox = VerifiedView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let nipLabel = UILabel()
    let replyingToView = ReplyingToView()
    let mainLabel = NantesLabel()
    let invoiceView = LightningInvoiceView()
    let mainImages = ImageGalleryView()
    let articleView = ArticleFeedView()
    let linkPresentation = SmallLinkPreview()
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let zapPreview = ZapPreviewView()
    let postPreview = PostPreviewView()
    let infoView = SimpleInfoView()
    let repostIndicator = RepostedIndicatorView()
    let separatorLabel = UILabel()
    lazy var nameStack = UIStackView([nameLabel, checkbox, nipLabel, separatorLabel, timeLabel])
    lazy var bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
    let bookmarkButton = UIButton()
    
    var zapGallery: ZapGallery?
    
    weak var imageAspectConstraint: NSLayoutConstraint?
    var bookmarkUpdater: AnyCancellable?
    
    let nantesDelegate = PostCellNantesDelegate()
    
    // MARK: - State
    var isShowingBookmarked = false
    
    var useShortText: Bool { false }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        nantesDelegate.cell = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ content: ParsedContent) {
        let user = content.user.data
        
        nameLabel.text = user.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user) {
            nipLabel.text = user.parsedNip
            nipLabel.isHidden = false
            checkbox.user = user
        } else {
            nipLabel.isHidden = true
            checkbox.isHidden = true
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.setUserImage(content.user)
        
        if let metadata = content.linkPreviews.first {
            linkPresentation.data = metadata
            linkPresentation.isHidden = false
        } else {
            linkPresentation.isHidden = true
        }
        
        if let parent = content.replyingTo {
            replyingToView.userNameLabel.text = parent.user.data.firstIdentifier
            replyingToView.isHidden = false
        } else {
            replyingToView.isHidden = true
        }
        
        if let embeded = content.embeddedPost, embeded.post.kind == content.post.kind {
            postPreview.update(embeded)
            postPreview.isHidden = false
        } else {
            postPreview.isHidden = true
        }
        
        if let zap = content.embeddedZap {
            zapPreview.updateForZap(zap)
            zapPreview.isHidden = false
        } else {
            zapPreview.isHidden = true
        }
        
        if let reposted = content.reposted?.users {
            repostIndicator.update(users: reposted)
            repostIndicator.isHidden = false
        } else {
            repostIndicator.isHidden = true
        }
        
        if let article = content.article {
            articleView.setUp(article)
            articleView.isHidden = false
        } else {
            articleView.isHidden = true
        }
        
        if let invoice = content.invoice {
            invoiceView.updateForInvoice(invoice)
            invoiceView.isHidden = false
        } else {
            invoiceView.isHidden = true
        }
        
        if let customEvent = content.customEvent {
            infoView.isHidden = false
            infoView.set(
                kind: .file,
                text: customEvent.post.tags.first(where: { $0.first == "alt" })?[safe: 1] ??
                        (customEvent.post.content.isEmpty ? "Unknown reference" : customEvent.post.content)
            )
        } else {
            switch content.notFound {
            case nil:
                infoView.isHidden = true
            case .note:
                infoView.isHidden = false
                infoView.set(kind: .file, text: "Mentioned note not found.")
            case .article:
                infoView.isHidden = false
                infoView.set(kind: .file, text: "Mentioned article not found.")
            }
        }
        
        imageAspectConstraint?.isActive = false
        imageAspectConstraint = nil
    
        if let first = content.mediaResources.first?.variants.first {
            let constant: CGFloat = content.mediaResources.count > 1 ? 16 : 0
            let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: CGFloat(first.height) / CGFloat(first.width), constant: constant)
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        } else {
            let url = content.mediaResources.first?.url
            
            if let url = content.mediaResources.first?.url { // We first check memory in case the image was already loaded
                var options = KingfisherParsedOptionsInfo(nil)
                options.cacheMemoryOnly = true
                ImageCache.default.retrieveImage(forKey: url, options: options) { [weak self] res in
                    guard let self, imageAspectConstraint == nil, case .success(let re) = res, let image = re.image else { return }
                    
                    let constant: CGFloat = content.mediaResources.count > 1 ? 16 : 0
                    let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: CGFloat(image.size.height) / CGFloat(image.size.width), constant: constant)
                    aspect.priority = .defaultHigh
                    aspect.isActive = true
                    imageAspectConstraint = aspect
                }
            }
            
            if imageAspectConstraint == nil { // In case the image was not in memory we use placeholder sizes
                let multiplier: CGFloat = url?.isVideoURL == true ? 9 / 16 : 1
                
                let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: multiplier)
                aspect.priority = .defaultHigh
                aspect.isActive = true
                imageAspectConstraint = aspect
            }
        }
        
        mainLabel.attributedText = useShortText ? content.attributedTextShort : content.attributedText
        mainImages.resources = content.mediaResources
        mainImages.thumbnails = content.videoThumbnails
        
        let postInfo = content.postInfo
        
        replyButton.set(postInfo.isReplied ? max(1, content.post.replies) : content.post.replies, filled: postInfo.isReplied)
        zapButton.set(content.post.satszapped + WalletManager.instance.extraZapAmount(content.post.id), filled: postInfo.isZapped)
        likeButton.set(postInfo.isLiked ? max(1, content.post.likes) : content.post.likes, filled: postInfo.isLiked)
        repostButton.set(postInfo.isReposted ? max(1, content.post.reposts) : content.post.reposts, filled: postInfo.isReposted)
        
        updateMenu(content)
    }
    
    func updateMenu(_ content: ParsedContent) {
        let postInfo = content.postInfo
        let muteTitle = postInfo.isUserMuted ? "Unmute User" : "Mute User"
        
        let bookmarkAction = ("Add To Bookmarks", "MenuBookmark", PostCellEvent.bookmark, UIMenuElement.Attributes.keepsMenuPresented)
        let unbookmarkAction = ("Remove Bookmark", "MenuBookmarkFilled", PostCellEvent.unbookmark, UIMenuElement.Attributes.keepsMenuPresented)
        
        let actionsData: [(String, String, PostCellEvent, UIMenuElement.Attributes)] = [
            ("Share Note", "MenuShare", .share, []),
            ("Copy Note Link", "MenuCopyLink", .copy(.link), []),
            postInfo.isBookmarked ? unbookmarkAction : bookmarkAction,
            ("Copy Note Text", "MenuCopyText", .copy(.content), []),
            ("Copy Raw Data", "MenuCopyData", .copy(.rawData), []),
            ("Copy Note ID", "MenuCopyNoteID", .copy(.noteID), []),
            ("Copy User Public Key", "MenuCopyUserPubkey", .copy(.userPubkey), []),
            (muteTitle, "blockIcon", .muteUser, .destructive),
            ("Report user", "warningIcon", .report, .destructive)
        ]

        threeDotsButton.menu = .init(children: actionsData.map { (title, imageName, action, attributes) in
            UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { [weak self] _ in
                guard let self = self else { return }
                delegate?.postCellDidTap(self, action)
            }
        })
        
        bookmarkUpdater = BookmarkManager.instance.isBookmarkedPublisher(content).receive(on: DispatchQueue.main)
            .sink { [weak self] isBookmarked in
                self?.isShowingBookmarked = isBookmarked
                self?.bookmarkButton.setImage(UIImage(named: isBookmarked ? "feedBookmarkFilled" : "feedBookmark"), for: .normal)
            }
    }
}

extension PostCell: ImageCollectionViewDelegate {
    func didTapMediaInCollection(_ collection: ImageGalleryView, resource: MediaMetadata.Resource) {
        if collection == mainImages {
            delegate?.postCellDidTap(self, .images(resource))
        }
        if collection == postPreview.mainImages {
            delegate?.postCellDidTap(self, .embeddedImages(resource))
        }
    }
}

private extension PostCell {
    func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .background2
        
        separatorLabel.text = "·"
        [timeLabel, separatorLabel, nipLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }
        
        [nameLabel, nipLabel, separatorLabel].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        nipLabel.lineBreakMode = .byTruncatingTail
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nipLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        threeDotsButton.setContentHuggingPriority(.required, for: .horizontal)
        
        checkbox.constrainToSize(FontSizeSelection.current.contentFontSize)
        
        nameStack.alignment = .center
        nameStack.spacing = 4
        
        bottomButtonStack.distribution = .fillEqually
        bottomButtonStack.spacing = 12
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)
        
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        mainLabel.delegate = nantesDelegate
        mainLabel.labelTappedBlock = { [weak self] in
            guard let self else { return }
            self.delegate?.postCellDidTap(self, .post)
        }
        mainLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        mainImages.imageDelegate = self
        
        let height = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: 1)
        [height].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        imageAspectConstraint = height
        
        linkPresentation.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        mainImages.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        threeDotsButton.tintColor = .foreground3
        threeDotsButton.showsMenuAsPrimaryAction = true
        
        bottomBorder.backgroundColor = .background3
        
        repostButton.tintColor = UIColor(rgb: 0x757575)
        
        repostIndicator.addTarget(self, action: #selector(repostProfileTapped), for: .touchUpInside)
        linkPresentation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkPreviewTapped)))
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        
        let previewTap = UITapGestureRecognizer(target: self, action: #selector(embedTapped))
        let previewImageTap = UITapGestureRecognizer(target: self, action: #selector(embedImageTapped))
        previewTap.require(toFail: previewImageTap)
        postPreview.addGestureRecognizer(previewTap)
        postPreview.mainImages.addGestureRecognizer(previewImageTap)
        postPreview.mainImages.imageDelegate = self
        
        invoiceView.copyButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.postCellDidTap(self, .copy(.invoice))
        }), for: .touchUpInside)
        
        invoiceView.payButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.postCellDidTap(self, .payInvoice)
        }), for: .touchUpInside)
        
        zapGallery?.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
        
        articleView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .article)
        }))
        
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
    
    @objc func zapLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard case .began = recognizer.state else { return }
        delegate?.postCellDidTap(self, .longTapZap)
    }
    
    @objc func linkPreviewTapped() {
        delegate?.postCellDidTap(self, .url(nil))
    }
    
    @objc func embedTapped() {
        delegate?.postCellDidTap(self, .embeddedPost)
    }
    
    @objc func embedImageTapped() {
        guard let index = postPreview.mainImages.collection.indexPathsForVisibleItems.first?.row else { return }
        delegate?.postCellDidTap(self, .embeddedImages(postPreview.mainImages.resources[index]))
    }
    
    @objc func profileTapped() {
        delegate?.postCellDidTap(self, .profile)
    }
    
    @objc func repostProfileTapped() {
        delegate?.postCellDidTap(self, .repostedProfile)
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

extension PostCell: ZapGalleryViewDelegate {
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
