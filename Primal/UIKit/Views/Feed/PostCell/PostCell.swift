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

protocol PostCellDelegate: AnyObject {
    func postCellDidTapURL(_ cell: PostCell, url: URL)
    func postCellDidTapImages(_ cell: PostCell, image: URL, images: [URL])
    func postCellDidTapPost(_ cell: PostCell)
    func postCellDidTapLike(_ cell: PostCell)
    func postCellDidTapRepost(_ cell: PostCell)
    func postCellDidTapEmbededPost(_ cell: PostCell)
}

/// Base class, not meant to be instantiated as is, use child classes like FeedCell
class PostCell: UITableViewCell {
    weak var delegate: PostCellDelegate?
    
    let backgroundColorView = UIView()
    let threeDotsButton = UIButton()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let usernameLabel = UILabel()
    let verifiedBadge = UIImageView(image: UIImage(named: "feedVerifiedBadge"))
    let verifiedServerLabel = UILabel()
    let mainLabel = LinkableLabel()
    let mainImages = ImageCollectionView()
    let linkPresentation = LPLinkView()
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let postPreview = PostPreviewView()
    let repostIndicator = RepostedIndicatorView()
    let separatorLabel = UILabel()
    lazy var nameTimeStack = UIStackView(arrangedSubviews: [nameLabel, separatorLabel, timeLabel])
    lazy var usernameStack = UIStackView(arrangedSubviews: [usernameLabel, verifiedBadge, verifiedServerLabel])
    lazy var namesStack = UIStackView(arrangedSubviews: [nameTimeStack, usernameStack])
    lazy var bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
    
    var metadataUpdater: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ content: ParsedContent, didLike: Bool, didRepost: Bool) {
        nameLabel.text = content.user.displayName
        usernameLabel.text = content.user.name
        
        verifiedBadge.isHidden = content.user.nip05.isEmpty
        verifiedServerLabel.text = content.user.getDomainNip05()
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.kf.setImage(with: URL(string: content.user.picture), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 40, height: 40))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        if let metadata = content.extractedMetadata {
            linkPresentation.metadata = metadata
            linkPresentation.isHidden = false
            
            metadataUpdater = content.$extractedMetadata.sink(receiveValue: { [weak self] in self?.linkPresentation.metadata = $0 ?? .init() })
        } else {
            linkPresentation.isHidden = true
        }
        
        if let embeded = content.embededPost {
            postPreview.update(embeded)
            postPreview.isHidden = false
        } else {
            postPreview.isHidden = true
        }
        
        if let reposted = content.reposted {
            repostIndicator.update(user: reposted)
            repostIndicator.isHidden = false
        } else {
            repostIndicator.isHidden = true
        }
        
        mainLabel.attributedText = content.attributedText
        mainImages.imageURLs = content.imageUrls
        
        updateButtons(content, didLike: didLike, didRepost: didRepost)
    }
    
    func updateButtons(_ content: ParsedContent, didLike: Bool, didRepost: Bool) {
        likeButton.titleLabel.textColor = didLike ? UIColor(rgb: 0xCA079F) : UIColor(rgb: 0x757575)
        if didLike {
            likeButton.animView.play()
        } else {
            likeButton.animView.stop()
        }
        
        let repostColor = didRepost ? UIColor(rgb: 0x52CE0A) : UIColor(rgb: 0x757575)
        repostButton.tintColor = repostColor
        repostButton.setTitleColor(repostColor, for: .normal)
        
        replyButton.setTitle("  \(content.post.replies)", for: .normal)
        zapButton.titleLabel.text = "\(content.post.satszapped)"
        likeButton.titleLabel.text = "\(content.post.likes + (didLike ? 1 : 0))"
        repostButton.setTitle("  \(content.post.reposts + (didRepost ? 1 : 0))", for: .normal)
    }
}

extension PostCell: ImageCollectionViewDelegate {
    func didTapImage(url: URL, urls: [URL]) {
        delegate?.postCellDidTapImages(self, image: url, images: urls)
    }
}

extension PostCell: LinkableLabelDelegate {
    func didTapURL(_ url: URL) {
        delegate?.postCellDidTapURL(self, url: url)
    }
    
    func didTapOutsideURL() {
        delegate?.postCellDidTapPost(self)
    }
}

private extension PostCell {
    func setup() {
        contentView.backgroundColor = .background
        contentView.addSubview(backgroundColorView)
        backgroundColorView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 5)
        
        nameTimeStack.spacing = 6
        separatorLabel.text = "|"
        [timeLabel, separatorLabel, usernameLabel, verifiedServerLabel].forEach {
            $0.font = .appFont(withSize: 16, weight: .regular)
            $0.textColor = .foreground3
            $0.adjustsFontSizeToFitWidth = true
        }
        
        usernameStack.alignment = .center
        usernameStack.spacing = 1
        
        namesStack.axis = .vertical
        namesStack.spacing = 3
        namesStack.alignment = .leading
        
        bottomButtonStack.distribution = .equalSpacing
        
        profileImageView.layer.masksToBounds = true
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont.appFont(withSize: 16, weight: .regular)
        mainLabel.delegate = self
        
        mainImages.layer.cornerRadius = 8
        mainImages.layer.masksToBounds = true
        mainImages.imageDelegate = self
        
        let height = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: 1)
        let height2 = linkPresentation.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        [height, height2].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
        linkPresentation.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        
        backgroundColorView.backgroundColor = .background2
        backgroundColorView.layer.cornerRadius = 8
        backgroundColorView.layer.masksToBounds = true
        
        repostButton.tintColor = UIColor(rgb: 0x757575)
        
        selectionStyle = .none
        
        postPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(embedTapped)))
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        repostButton.addTarget(self, action: #selector(repostTapped), for: .touchUpInside)
        replyButton.isUserInteractionEnabled = false
    }
    
    @objc func embedTapped() {
        delegate?.postCellDidTapEmbededPost(self)
    }
    
    @objc func repostTapped() {
        repostButton.tintColor = UIColor(rgb: 0x52CE0A)
        repostButton.setTitleColor(UIColor(rgb: 0x52CE0A), for: .normal)
        
        if let number = Int(repostButton.title(for: .normal)?.trimmingCharacters(in: .whitespaces) ?? "") {
            repostButton.setTitle("  \(number + 1)", for: .normal)
        }
        
        delegate?.postCellDidTapRepost(self)
    }
    
    @objc func likeTapped() {
        likeButton.animView.play()
        likeButton.titleLabel.animateToColor(color: UIColor(rgb: 0xCA079F))
        
        delegate?.postCellDidTapLike(self)
    }
}
