//
//  FeedCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Kingfisher

protocol FeedCellDelegate: AnyObject {
    func feedCellDidTapURL(_ cell: FeedCell, url: URL)
    func feedCellDidTapImages(_ cell: FeedCell, image: URL, images: [URL])
    func feedCellDidTapPost(_ cell: FeedCell)
}

class FeedCell: UITableViewCell {
    weak var delegate: FeedCellDelegate?
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let usernameLabel = UILabel()
    let verifiedBadge = UIImageView(image: UIImage(named: "feedVerifiedBadge"))
    let verifiedServerLabel = UILabel()
    let mainLabel = LinkableLabel()
    let mainImages = ImageCollectionView()
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel])
    lazy var imageStack = UIStackView(arrangedSubviews: [mainImages])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ post: PrimalPost, text: String, imageUrls: [URL], edgeBleed: Bool) {
        nameLabel.text = post.user.displayName
        usernameLabel.text = post.user.name
        
        verifiedBadge.isHidden = post.user.nip05.isEmpty
        verifiedServerLabel.text = post.user.getDomainNip05()
        
        let date = Date(timeIntervalSince1970: TimeInterval(post.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.kf.setImage(with: URL(string: post.user.picture), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 40, height: 40))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        mainLabel.text = text
        mainLabel.delegate = self
        mainImages.imageURLs = imageUrls
        
        textStack.isHidden = text.isEmpty
        imageStack.isHidden = imageUrls.isEmpty
        
        replyButton.setTitle("  \(post.post.replies)", for: .normal)
        zapButton.titleLabel.text = "\(post.post.zaps)"
        likeButton.titleLabel.text = "\(post.post.likes)"
        repostButton.setTitle("  \(post.post.mentions)", for: .normal)
        
        if edgeBleed {
            imageStack.layoutMargins = .init(top: 14, left: 0, bottom: 0, right: 0)
            mainImages.layer.cornerRadius = 0
        } else {
            imageStack.layoutMargins = .init(top: 14, left: 16, bottom: 0, right: 16)
            mainImages.layer.cornerRadius = 8
        }
    }
}

extension FeedCell: ImageCollectionViewDelegate {
    func didTapImage(url: URL, urls: [URL]) {
        delegate?.feedCellDidTapImages(self, image: url, images: urls)
    }    
}

extension FeedCell: LinkableLabelDelegate {
    func didTapURL(_ url: URL) {
        delegate?.feedCellDidTapURL(self, url: url)
    }
    
    func didTapOutsideURL() {
        delegate?.feedCellDidTapPost(self)
    }
}

private extension FeedCell {
    func setup() {
        let threeDotsButton = UIButton()
        let separatorLabel = UILabel()
        let nameTimeStack = UIStackView(arrangedSubviews: [nameLabel, separatorLabel, timeLabel])
        let usernameStack = UIStackView(arrangedSubviews: [usernameLabel, verifiedBadge, verifiedServerLabel])
        let namesStack = UIStackView(arrangedSubviews: [nameTimeStack, usernameStack])
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, namesStack, threeDotsButton])
        let bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
        let mainStack = UIStackView(arrangedSubviews: [horizontalStack, textStack, imageStack, bottomButtonStack])
        
        let backgroundView = UIView()
        contentView.addSubview(backgroundView)
        backgroundView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 5)
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .bottom, padding: 2) // Action buttons have a built in padding of 14
        [mainStack, imageStack].forEach {
            $0.axis = .vertical
            $0.spacing = 16
        }
        mainStack.setCustomSpacing(2, after: imageStack) // Action buttons have a built in padding of 14
        mainStack.setCustomSpacing(2, after: textStack) // Action buttons have a built in padding of 14
        
        nameTimeStack.spacing = 6
        separatorLabel.text = "|"
        [timeLabel, separatorLabel, usernameLabel, verifiedServerLabel].forEach {
            $0.font = .appFont(withSize: 16, weight: .regular)
            $0.textColor = UIColor(rgb: 0x666666)
            $0.adjustsFontSizeToFitWidth = true
        }
        
        usernameStack.alignment = .center
        usernameStack.spacing = 1
        
        namesStack.axis = .vertical
        namesStack.spacing = 3
        namesStack.alignment = .leading
        
        horizontalStack.alignment = .top
        horizontalStack.spacing = 12
        
        bottomButtonStack.distribution = .equalSpacing
        
        profileImageView.constrainToSize(40)
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        nameLabel.textColor = .white
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        mainLabel.textColor = .white
        mainLabel.font = .appFont(withSize: 18, weight: .regular)
        mainLabel.numberOfLines = 0
        
        let height = mainImages.heightAnchor.constraint(equalToConstant: 224)
        height.priority = .defaultHigh
        height.isActive = true
        mainImages.layer.masksToBounds = true
        mainImages.imageDelegate = self
        
        [horizontalStack, imageStack, bottomButtonStack, textStack].forEach {
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.isLayoutMarginsRelativeArrangement = true
        }
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        
        backgroundView.backgroundColor = UIColor(rgb: 0x181818)
        backgroundView.layer.cornerRadius = 8
        
        selectionStyle = .none
    }
}
