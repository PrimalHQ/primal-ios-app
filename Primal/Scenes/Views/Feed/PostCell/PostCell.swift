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
    func postCellDidTapURL(_ cell: PostCell, url: URL?)
    func postCellDidTapImages(_ cell: PostCell, resource: MediaMetadata.Resource)
    func postCellDidTapProfile(_ cell: PostCell)
    func postCellDidTapPost(_ cell: PostCell)
    func postCellDidTapLike(_ cell: PostCell)
    func postCellDidTapZap(_ cell: PostCell)
    func postCellDidLongTapZap(_ cell: PostCell)
    func postCellDidTapRepost(_ cell: PostCell)
    func postCellDidTapReply(_ cell: PostCell)
    func postCellDidTapEmbededPost(_ cell: PostCell)
    func postCellDidTapRepostedProfile(_ cell: PostCell)
    
    func postCellDidTapShare(_ cell: PostCell)
    func postCellDidTapCopyLink(_ cell: PostCell)
    func postCellDidTapCopyContent(_ cell: PostCell)
    func postCellDidTapReport(_ cell: PostCell)
    func postCellDidTapMute(_ cell: PostCell)
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
    let mainImages = ImageCollectionView()
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ content: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        let user = content.user.data
        
        nameLabel.text = user.firstIdentifier
        
        nipLabel.text = user.parsedNip
        nipLabel.isHidden = user.nip05.isEmpty
        checkbox.isHidden = user.nip05.isEmpty
        checkbox.isExtraVerified = user.nip05.hasSuffix("@primal.net")
        
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
        
        imageAspectConstraint?.isActive = false
        if let first = content.mediaResources.first?.variants.first {
            let aspect = mainImages.widthAnchor.constraint(equalTo: mainImages.heightAnchor, multiplier: CGFloat(first.width) / CGFloat(first.height))
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        } else {
            let url = content.mediaResources.first?.url
            
            let multiplier: CGFloat = url?.isVideoButNotYoutube == true ? (9 / 16) : (url?.isYoutubeVideo == true ? 0.8 : 1)
            
            let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: multiplier)
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        }
        
        mainLabel.attributedText = content.attributedText
        mainImages.resources = content.mediaResources
        mainImages.thumbnails = content.videoThumbnails
        
        likeButton.set(content.post.likes + (LikeManager.instance.hasLiked(content.post.id) ? 1 : 0), filled: didLike)
        zapButton.set(content.post.satszapped + WalletManager.instance.extraZapAmount(content.post.id), filled: didZap)
        repostButton.set(content.post.reposts + (PostManager.instance.hasReposted(content.post.id) ? 1 : 0), filled: didRepost)
        replyButton.set(content.post.replies + (PostManager.instance.hasReplied(content.post.id) ? 1 : 0), filled: PostManager.instance.hasReplied(content.post.id))
        
        let muteTitle = isMuted ? "Unmute User" : "Mute User"
        threeDotsButton.menu = .init(children: [
            UIAction(title: "Share note", image: UIImage(named: "MenuShare"), handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.postCellDidTapShare(self)
            }),
            UIAction(title: "Copy note link", image: UIImage(named: "MenuCopyLink"), handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.postCellDidTapCopyLink(self)
            }),
            UIAction(title: "Copy text", image: UIImage(named: "MenuCopyText"), handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.postCellDidTapCopyContent(self)
            }),
            UIAction(title: "Report user", image: UIImage(named: "warningIcon"), attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                self.delegate?.postCellDidTapReport(self)
            },
            UIAction(title: muteTitle, image: UIImage(named: "blockIcon"), attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                self.delegate?.postCellDidTapMute(self)
            }
        ])
    }
}

extension PostCell: ImageCollectionViewDelegate {
    func didTapMedia(resource: MediaMetadata.Resource) {
        delegate?.postCellDidTapImages(self, resource: resource)
    }
}

extension PostCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        delegate?.postCellDidTapURL(self, url: link)
    }
}

private extension PostCell {
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .background2
        contentView.addSubview(bottomBorder)
        bottomBorder.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        
        likeButton.isEnabled = LoginManager.instance.method() == .nsec
        zapButton.isEnabled = LoginManager.instance.method() == .nsec
        repostButton.isEnabled = LoginManager.instance.method() == .nsec
        replyButton.isEnabled = LoginManager.instance.method() == .nsec
        
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
        mainLabel.delegate = self
        mainLabel.labelTappedBlock = { [unowned self] in
            self.delegate?.postCellDidTapPost(self)
        }
        
        mainImages.layer.cornerRadius = 8
        mainImages.layer.masksToBounds = true
        mainImages.backgroundColor = .background2
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
        postPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(embedTapped)))
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        repostButton.addTarget(self, action: #selector(repostTapped), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zapTapped))
        let long = UILongPressGestureRecognizer(target: self, action: #selector(zapLongPressed))
        tap.require(toFail: long)
        zapButton.addGestureRecognizer(tap)
        zapButton.addGestureRecognizer(long)
    }
    
    @objc func zapTapped() {
        delegate?.postCellDidTapZap(self)
    }
    
    @objc func zapLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard case .began = recognizer.state else { return }
        delegate?.postCellDidLongTapZap(self)
    }
    
    @objc func linkPreviewTapped() {
        delegate?.postCellDidTapURL(self, url: nil)
    }
    
    @objc func embedTapped() {
        delegate?.postCellDidTapEmbededPost(self)
    }
    
    @objc func profileTapped() {
        delegate?.postCellDidTapProfile(self)
    }
    
    @objc func repostProfileTapped() {
        delegate?.postCellDidTapRepostedProfile(self)
    }
    
    @objc func repostTapped() {
        delegate?.postCellDidTapRepost(self)
    }
    
    @objc func replyTapped() {
        delegate?.postCellDidTapReply(self)
    }
    
    @objc func likeTapped() {
        likeButton.animView.play()
        likeButton.titleLabel.animateToColor(color: UIColor(rgb: 0xCA079F))

        delegate?.postCellDidTapLike(self)
    }
}

extension FLAnimatedImageView {
    func setUserImage(_ user: ParsedUser) {
        tag = tag + 1
        
        guard
            ContentDisplaySettings.animatedAvatars,
            user.data.picture.hasSuffix("gif"),
            let url = user.profileImage.url(for: .small)
        else {
            let size = frame.size.width < 5 ? CGSize(width: 50, height: 50) : frame.size
            
            kf.setImage(with: user.profileImage.url(for: .small), placeholder: UIImage(named: "Profile"), options: [
                .processor(DownsamplingImageProcessor(size: size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
            return
        }
        
        image = UIImage(named: "Profile")
        let oldTag = self.tag
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data else { return }
            
            let anim = FLAnimatedImage(gifData: data)
            
            DispatchQueue.main.async {
                guard self?.tag == oldTag else { return }
                self?.animatedImage = anim
            }
        }.resume()
    }
}
