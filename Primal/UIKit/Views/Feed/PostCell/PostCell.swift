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
    func postCellDidTapURL(_ cell: PostCell, url: URL?)
    func postCellDidTapImages(_ cell: PostCell, resource: MediaMetadata.Resource, resources: [MediaMetadata.Resource])
    func postCellDidTapProfile(_ cell: PostCell)
    func postCellDidTapPost(_ cell: PostCell)
    func postCellDidTapLike(_ cell: PostCell)
    func postCellDidTapZap(_ cell: PostCell)
    func postCellDidTapRepost(_ cell: PostCell)
    func postCellDidTapEmbededPost(_ cell: PostCell)
    func postCellDidTapRepostedProfile(_ cell: PostCell)
}

/// Base class, not meant to be instantiated as is, use child classes like FeedCell
class PostCell: UITableViewCell {
    weak var delegate: PostCellDelegate?
    
    let backgroundColorView = UIView()
    let threeDotsButton = UIButton()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let nipLabel = UILabel()
    let mainLabel = LinkableLabel()
    let mainImages = ImageCollectionView()
    let linkPresentation = LinkPreview()
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let postPreview = PostPreviewView()
    let repostIndicator = RepostedIndicatorView()
    let separatorLabel = UILabel()
    lazy var nameTimeStack = UIStackView(arrangedSubviews: [nameLabel, separatorLabel, timeLabel])
    lazy var namesStack = UIStackView(arrangedSubviews: [nameTimeStack, nipLabel])
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
    
    func update(_ content: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool) {
        let user = content.user.data
        
        nameLabel.text = user.firstIdentifier
        
        if user.nip05.hasPrefix("_@") {
            nipLabel.text = String(user.nip05.split(separator: "@").last ?? "")
        } else {
            nipLabel.text = user.nip05
        }
        nipLabel.isHidden = user.nip05.isEmpty
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        if !content.user.profileImage.variants.isEmpty {
            profileImageView.kf.setImage(with: content.user.profileImage.url(for: .small))
        } else {
            profileImageView.kf.setImage(with: URL(string: user.picture), options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 40, height: 40))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        }
        
        if let metadata = content.parsedMetadata {
            linkPresentation.data = metadata
            linkPresentation.isHidden = false
            
            let didHaveImage = metadata.imageKey != nil
            metadataUpdater = content.$parsedMetadata.sink { [weak self] in
                var data = $0 ?? .failedToLoad(metadata.url)
                if !didHaveImage {
                    data.imageKey = nil
                }
                self?.linkPresentation.data = data
            }
        } else {
            linkPresentation.isHidden = true
        }
        
        if let embeded = content.embededPost {
            postPreview.update(embeded)
            postPreview.isHidden = false
        } else {
            postPreview.isHidden = true
        }
        
        if let reposted = content.reposted?.data {
            repostIndicator.update(user: reposted)
            repostIndicator.isHidden = false
        } else {
            repostIndicator.isHidden = true
        }
        
        mainLabel.attributedText = content.attributedText
        mainImages.imageResources = content.imageResources
        
        imageAspectConstraint?.isActive = false
        if let first = content.imageResources.first?.variants.first {
            let aspect = mainImages.widthAnchor.constraint(equalTo: mainImages.heightAnchor, multiplier: CGFloat(first.width) / CGFloat(first.height))
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        } else {
            let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: 1)
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        }
        
        updateButtons(content, didLike: didLike, didRepost: didRepost, didZap: didZap)
    }
    
    func updateButtons(_ content: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool) {
        likeButton.titleLabel.textColor = didLike ? UIColor(rgb: 0xCA079F) : UIColor(rgb: 0x757575)
        if didLike {
            likeButton.animView.play()
        } else {
            likeButton.animView.stop()
        }
        
        if didZap {
            zapButton.titleLabel.animateToColor(color: UIColor(rgb: 0xFFA02F))
            zapButton.animView.play()
        } else {
            zapButton.titleLabel.textColor = UIColor(rgb: 0x757575)
            zapButton.animView.stop()
        }
        
        let repostColor = didRepost ? UIColor(rgb: 0x52CE0A) : UIColor(rgb: 0x757575)
        repostButton.tintColor = repostColor
        repostButton.setTitleColor(repostColor, for: .normal)
        
        if content.post.replies < 1 {
            replyButton.setTitle(nil, for: .normal)
        } else {
            replyButton.setTitle("  \(content.post.replies)", for: .normal)
        }
        
        if content.post.satszapped < 1 {
            zapButton.titleLabel.isHidden = true
        } else {
            zapButton.titleLabel.text = "\(content.post.satszapped)"
            zapButton.titleLabel.isHidden = false
        }
        
        if content.post.likes < 1 && !didLike {
            likeButton.titleLabel.isHidden = true
        } else {
            likeButton.titleLabel.text = "\(content.post.likes + (didLike ? 1 : 0))"
            likeButton.titleLabel.isHidden = false
        }
        
        if content.post.reposts < 1 && !didRepost {
            repostButton.setTitle(nil, for: .normal)
        } else {
            repostButton.setTitle("  \(content.post.reposts + (didRepost ? 1 : 0))", for: .normal)
        }
    }
}

extension PostCell: ImageCollectionViewDelegate {
    func didTapImage(resource: MediaMetadata.Resource, resources: [MediaMetadata.Resource]) {
        delegate?.postCellDidTapImages(self, resource: resource, resources: resources)
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
        [timeLabel, separatorLabel, nipLabel].forEach {
            $0.font = .appFont(withSize: 16, weight: .regular)
            $0.textColor = .foreground3
            $0.adjustsFontSizeToFitWidth = true
        }
        
        namesStack.axis = .vertical
        namesStack.spacing = 3
        namesStack.alignment = .leading
        
        bottomButtonStack.distribution = .equalSpacing
        
        profileImageView.contentMode = .scaleToFill
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
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
        [height].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        imageAspectConstraint = height
        
        linkPresentation.heightAnchor.constraint(lessThanOrEqualToConstant: 600).isActive = true
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        
        backgroundColorView.backgroundColor = .background2
        backgroundColorView.layer.cornerRadius = 8
        backgroundColorView.layer.masksToBounds = true
        
        repostButton.tintColor = UIColor(rgb: 0x757575)
        
        selectionStyle = .none
        
        repostIndicator.addTarget(self, action: #selector(repostProfileTapped), for: .touchUpInside)
        linkPresentation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkPreviewTapped)))
        postPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(embedTapped)))
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        repostButton.addTarget(self, action: #selector(repostTapped), for: .touchUpInside)
        zapButton.addTarget(self, action: #selector(zapTapped), for: .touchUpInside)
        
        replyButton.isUserInteractionEnabled = false
    }
    
    @objc func zapTapped() {
        delegate?.postCellDidTapZap(self)
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
