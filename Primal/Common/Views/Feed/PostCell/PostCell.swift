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

enum PostCellEvent {
    case url(URL?)
    case images(MediaMetadata.Resource)
    case embeddedImages(MediaMetadata.Resource)
    case profile
    case post
    case like
    case zap
    case longTapZap
    case repost
    case reply
    case embeddedPost
    case repostedProfile
    
    case payInvoice
    
    case zapDetails
    case likeDetails
    case repostDetails
    
    case share
    case copy(NoteCopiableProperty)
    case broadcast
    case report
    case mute
    case bookmark
    case unbookmark
}

enum NoteCopiableProperty {
    case link
    case content
    case rawData
    case noteID
    case userPubkey
    case invoice
}

protocol PostCellDelegate: AnyObject {
    func postCellDidTap(_ cell: PostCell, _ event: PostCellEvent)
}

class PostCellNantesDelegate {
    weak var cell: PostCell?
}

struct PostInfo {
    var isBookmarked: Bool
    var isLiked: Bool
    var isMuted: Bool
    var isReplied: Bool
    var isReposted: Bool
    var isZapped: Bool
}

extension ParsedContent {
    var postInfo: PostInfo {
        .init(
            isBookmarked: BookmarkManager.instance.isBookmarked(post.id),
            isLiked: LikeManager.instance.hasLiked(post.id),
            isMuted: MuteManager.instance.isMuted(user.data.pubkey),
            isReplied: PostManager.instance.hasReplied(post.id),
            isReposted: PostManager.instance.hasReposted(post.id),
            isZapped: WalletManager.instance.hasZapped(post.id)
        )
    }
}

/// Base class, not meant to be instantiated as is, use child classes like FeedCell
class PostCell: UITableViewCell {
    weak var delegate: PostCellDelegate?
    
    let bottomBorder = UIView()
    let threeDotsButton = UIButton()
    let profileImageView = FLAnimatedImageView()
    let checkbox = VerifiedView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let nipLabel = UILabel()
    let replyingToView = ReplyingToView()
    let mainLabel = NantesLabel()
    let invoiceView = LightningInvoiceView()
    let mainImages = ImageGalleryView()
    let linkPresentation = LinkPreview()
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let postPreview = PostPreviewView()
    let repostIndicator = RepostedIndicatorView()
    let separatorLabel = UILabel()
    lazy var nameStack = UIStackView([nameLabel, checkbox, nipLabel, separatorLabel, timeLabel])
    lazy var bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
    
    weak var imageAspectConstraint: NSLayoutConstraint?
    var metadataUpdater: AnyCancellable?
    
    let nantesDelegate = PostCellNantesDelegate()
    
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
            checkbox.isHidden = false
            checkbox.isExtraVerified = user.nip05.hasSuffix("@primal.net")
        } else {
            nipLabel.isHidden = true
            checkbox.isHidden = true
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.setUserImage(content.user)
        
        if let metadata = content.linkPreview {
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
        
        if let embeded = content.embededPost {
            postPreview.update(embeded)
            postPreview.isHidden = false
        } else {
            postPreview.isHidden = true
        }
        
        if let reposted = content.reposted?.users {
            repostIndicator.update(users: reposted)
            repostIndicator.isHidden = false
        } else {
            repostIndicator.isHidden = true
        }
        
        if let invoice = content.invoice {
            invoiceView.updateForInvoice(invoice)
            invoiceView.isHidden = false
        } else {
            invoiceView.isHidden = true
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
                let multiplier: CGFloat = url?.isVideoURL == true ? (url?.isYoutubeVideoURL == true ? 0.8 : (9 / 16)) : 1
                
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
        let muteTitle = postInfo.isMuted ? "Unmute User" : "Mute User"
        
        threeDotsButton.menu = .init(children: [
            UIAction(title: "Share Note", image: UIImage(named: "MenuShare"), handler: { [unowned self] _ in
                delegate?.postCellDidTap(self, .share)
            }),
            UIAction(title: "Copy Note Link", image: UIImage(named: "MenuCopyLink"), handler: { [unowned self] _ in
                delegate?.postCellDidTap(self, .copy(.link))
            }),
            postInfo.isBookmarked ?
                UIAction(title: "Remove From Bookmarks", image: UIImage(named: "MenuBookmarkFilled"), handler: { [unowned self] _ in
                    delegate?.postCellDidTap(self, .unbookmark)
                }) :
                UIAction(title: "Add To Bookmarks", image: UIImage(named: "MenuBookmark"), handler: { [unowned self] _ in
                    delegate?.postCellDidTap(self, .unbookmark)
                }),
            UIAction(title: "Copy Note Text", image: UIImage(named: "MenuCopyText"), handler: { [unowned self] _ in
                delegate?.postCellDidTap(self, .copy(.content))
            }),
            UIAction(title: "Copy Raw Data", image: UIImage(named: "MenuCopyData"), handler: { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, .copy(.rawData))
            }),
            UIAction(title: "Copy Note ID", image: UIImage(named: "MenuCopyNoteID"), handler: { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, .copy(.noteID))
            }),
            UIAction(title: "Copy User Public Key", image: UIImage(named: "MenuCopyUserPubkey"), handler: { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, .copy(.userPubkey))
            }),
            UIAction(title: "Broadcast", image: UIImage(named: "MenuBroadcast"), handler: { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, .broadcast)
            }),
            UIAction(title: muteTitle, image: UIImage(named: "blockIcon"), attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, .mute)
            },
            UIAction(title: "Report user", image: UIImage(named: "warningIcon"), attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, .report)
            }
        ])
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

extension PostCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard let cell else { return }
        cell.delegate?.postCellDidTap(cell, .url(link))
    }
}

private extension PostCell {
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .background2
        contentView.addSubview(bottomBorder)
        bottomBorder.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        
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
        
        bottomButtonStack.distribution = .equalSpacing
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)
        
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        mainLabel.delegate = nantesDelegate
        mainLabel.labelTappedBlock = { [weak self] in
            guard let self else { return }
            self.delegate?.postCellDidTap(self, .post)
        }
        
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
        
        selectionStyle = .none
        
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
        
        if LoginManager.instance.method() == .nsec {
            likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
            repostButton.addTarget(self, action: #selector(repostTapped), for: .touchUpInside)
            replyButton.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(zapTapped))
            let long = UILongPressGestureRecognizer(target: self, action: #selector(zapLongPressed))
            tap.require(toFail: long)
            zapButton.addGestureRecognizer(tap)
            zapButton.addGestureRecognizer(long)
        } else {
            ([likeButton, repostButton, replyButton, zapButton] as [UIControl]).forEach { $0.addDisabledNSecWarning(RootViewController.instance) }
        }
    }
    
    @objc func zapTapped() {
        delegate?.postCellDidTap(self, .zap)
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

extension FLAnimatedImageView {
    func setUserImage(_ user: ParsedUser, feed: Bool = true, size: CGSize? = nil) {
        tag = tag + 1
        
        guard
            !feed || ContentDisplaySettings.animatedAvatars,
            user.data.picture.hasSuffix("gif"),
            let url = user.profileImage.url(for: .small)
        else {
            let size = size ?? (frame.size.width < 5 ? CGSize(width: 50, height: 50) : frame.size)
            
            kf.setImage(with: user.profileImage.url(for: size.width < 100 ? .small : .medium), placeholder: UIImage(named: "Profile"), options: [
                .processor(DownsamplingImageProcessor(size: size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
            return
        }
        
        kf.cancelDownloadTask()
        image = UIImage(named: "Profile")
        let oldTag = tag

        CachingManager.instance.fetchAnimatedImage(url) { [weak self] result in
            switch result {
            case .success(let image):
                guard self?.tag == oldTag else { return }
                self?.animatedImage = image
            case .failure(let error):
                print(error)
            }
        }
    }
}
