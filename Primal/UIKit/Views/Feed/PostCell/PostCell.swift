//
//  PostCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.5.23..
//

import UIKit
import Kingfisher

protocol PostCellDelegate: AnyObject {
    func postCellDidTapURL(_ cell: PostCell, url: URL)
    func postCellDidTapImages(_ cell: PostCell, image: URL, images: [URL])
    func postCellDidTapPost(_ cell: PostCell)
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
    let replyButton = FeedReplyButton()
    let zapButton = FeedZapButton()
    let likeButton = FeedLikeButton()
    let repostButton = FeedRepostButton()
    let separatorLabel = UILabel()
    lazy var nameTimeStack = UIStackView(arrangedSubviews: [nameLabel, separatorLabel, timeLabel])
    lazy var usernameStack = UIStackView(arrangedSubviews: [usernameLabel, verifiedBadge, verifiedServerLabel])
    lazy var namesStack = UIStackView(arrangedSubviews: [nameTimeStack, usernameStack])
    lazy var bottomButtonStack = UIStackView(arrangedSubviews: [replyButton, zapButton, likeButton, repostButton])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ post: PrimalPost, text: String, imageUrls: [URL]) {
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
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        mainLabel.attributedText = NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.appFont(withSize: 18, weight: .regular),
            .paragraphStyle: style
        ])
        mainLabel.delegate = self
        mainImages.imageURLs = imageUrls
        
        replyButton.setTitle("  \(post.post.replies)", for: .normal)
        zapButton.titleLabel.text = "\(post.post.zaps)"
        likeButton.titleLabel.text = "\(post.post.likes)"
        repostButton.setTitle("  \(post.post.mentions)", for: .normal)
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
        contentView.addSubview(backgroundColorView)
        backgroundColorView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 5)
        
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
        
        bottomButtonStack.distribution = .equalSpacing
        
        profileImageView.layer.masksToBounds = true
        
        nameLabel.textColor = .white
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        mainLabel.numberOfLines = 0
        
        let height = mainImages.heightAnchor.constraint(equalToConstant: 224)
        height.priority = .defaultHigh
        height.isActive = true
        mainImages.layer.masksToBounds = true
        mainImages.imageDelegate = self
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        
        backgroundColorView.backgroundColor = UIColor(rgb: 0x181818)
        backgroundColorView.layer.cornerRadius = 8
        backgroundColorView.layer.masksToBounds = true
        
        selectionStyle = .none
    }
}