//
//  NotificationsCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 28.6.23..
//

import UIKit

final class NotificationsCell: PostCell {
    let iconView = UIImageView()
    let iconLabel = UILabel()
    let avatarStack = AvatarView()
    let titleLabel = UILabel()
    let border = SpacerView(height: 1)
    
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    lazy var postContentStack = UIStackView(arrangedSubviews: [textStack, mainImages, linkPresentation, postPreview, SpacerView(height: 0), bottomButtonStack])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForNotification(_ notification: GroupedNotification, delegate: PostCellDelegate, didLike: Bool, didRepost: Bool, didZap: Bool) {
        if let post = notification.post {
            update(post, didLike: didLike, didRepost: didRepost, didZap: didZap)
            postContentStack.isHidden = false
        } else {
            postContentStack.isHidden = true
        }
        
        iconView.image = notification.icon
        iconLabel.attributedText = notification.iconText
        
        avatarStack.setImages(notification.users.compactMap { $0.profileImage.url(for: .small) })
        
        titleLabel.attributedText = notification.titleText
        
        self.delegate = delegate
    }
    
    override func update(_ parsedContent: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool) {
        super.update(parsedContent, didLike: didLike, didRepost: didRepost, didZap: didZap)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.imageResources.isEmpty
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
    }
}

private extension NotificationsCell {
    func setup() {
        backgroundColorView.removeFromSuperview()
        
        let iconStack = UIStackView(arrangedSubviews: [SpacerView(height: 4), iconView, iconLabel])
        let contentStack = UIStackView(arrangedSubviews: [avatarStack, titleLabel, postContentStack])
        let mainStack = UIStackView(arrangedSubviews: [iconStack, contentStack])
        
        avatarStack.constrainToSize(height: 32)
        
        iconView.tintColor = .init(rgb: 0x52CE0A)
        
        titleLabel.numberOfLines = 0
        iconLabel.textAlignment = .center
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading, padding: 8)
            .pinToSuperview(edges: .trailing, padding: 20)
            .pinToSuperview(edges: .top, padding: 16)
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        [contentStack, postContentStack, iconStack].forEach {
            $0.axis = .vertical
            $0.spacing = 8
        }
        
        iconStack.alignment = .center
        iconStack.spacing = 4
        iconStack.axis = .vertical
        iconStack.constrainToSize(width: 38)
        
        textStack.axis = .vertical
        mainLabel.numberOfLines = 20
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: 16, weight: .regular)
        seeMoreLabel.textColor = .accent
        
        mainStack.alignment = .top
        mainStack.spacing = 4
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
        border.backgroundColor = .foreground6
    }
}

extension GroupedNotification {
    var titleText: NSAttributedString {
        let string = NSMutableAttributedString()
        if let first = users.first {
            string.append(NSAttributedString(string: first.data.firstIdentifier, attributes: [
                .foregroundColor: UIColor.foreground2,
                .font: UIFont.appFont(withSize: 18, weight: .heavy)
            ]))
            
            if !first.data.nip05.isEmpty {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "verifiedBadge")
                string.append(NSAttributedString(attachment: attachment))
            }
            
            string.append(.init(string: " "))
        }
        
        if users.count > 1 {
            let text = "and \(users.count) other" + (users.count == 2 ? " " : "s ")
            string.append(NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.foreground2,
                .font: UIFont.appFont(withSize: 18, weight: .regular)
            ]))
        }
        
        string.append(NSAttributedString(string: notificationTypeText, attributes: [
            .foregroundColor: UIColor.foreground2,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ]))
        
        return string
    }
    
    var iconText: NSAttributedString? {
        guard let post else { return nil }
        switch mainNotification.type {
        case .YOUR_POST_WAS_LIKED:
            return .init(string: post.post.likes.shortened(), attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .medium),
                .foregroundColor: UIColor(rgb: 0xBC1870)
            ])
        case .YOUR_POST_WAS_REPOSTED:
            return .init(string: post.post.reposts.shortened(), attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .medium),
                .foregroundColor: UIColor(rgb: 0x52CE0A)
            ])
        case .YOUR_POST_WAS_REPLIED_TO:
            return .init(string: post.post.replies.shortened(), attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .medium),
                .foregroundColor: UIColor.brandText
            ])
        case .YOUR_POST_WAS_ZAPPED:
            return .init(string: post.post.satszapped.shortened(), attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .medium),
                .foregroundColor: UIColor(rgb: 0xFFA02F)
            ])
        default:
            return nil
        }
    }
    
    var notificationTypeText: String {
        switch mainNotification.type {
        case .NEW_USER_FOLLOWED_YOU:
            return "followed you"
        case .USER_UNFOLLOWED_YOU:
            return "unfollowed you"
        case .YOUR_POST_WAS_ZAPPED:
            guard let sats = post?.post.satszapped.shortened() else { return "zapped your post" }
            return "zapped your post for a total of \(sats) sats"
        case .YOUR_POST_WAS_LIKED:
            return "liked your post"
        case .YOUR_POST_WAS_REPOSTED:
            return "reposted your post"
        case .YOUR_POST_WAS_REPLIED_TO:
            return "replied to your post"
        case .YOU_WERE_MENTIONED_IN_POST:
            return "mentioned you in a post"
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            return "mentioned your post"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            guard let sats = post?.post.satszapped.shortened() else {
                return "zapped a post you were mentioned in"
            }
            return "zapped a post you were mentioned in for a total of \(sats) sats"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            return "liked a post you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            return "reposted a post you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to a post you were mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            guard let sats = post?.post.satszapped.shortened() else {
                return "zapped a post your post was mentioned in"
            }
            return "zapped a post your post was mentioned in for a total of \(sats) sats"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            return "liked a post your post was mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            return "reposted a post your post was mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to a post your post was mentioned in"
        }
    }
    
    var icon: UIImage? { mainNotification.type.icon }
}

extension NotificationType {
    var icon: UIImage? { UIImage(named: iconName) }
    
    var iconName: String {
        switch self {
        case .NEW_USER_FOLLOWED_YOU:
            return "notifFollow"
        case .USER_UNFOLLOWED_YOU:
            return "notifUnfollow"
        case .YOUR_POST_WAS_ZAPPED:
            return "feedZapFilled"
        case .YOUR_POST_WAS_LIKED:
            return "feedHeartFilled"
        case .YOUR_POST_WAS_REPOSTED:
            return "feedRepost"
        case .YOUR_POST_WAS_REPLIED_TO:
            return "feedCommentFilled"
        case .YOU_WERE_MENTIONED_IN_POST:
            return "notifUserMention"
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            return "notifPostMention"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            return "notifUserZap"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            return "notifUserLike"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            return "notifUserRepost"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            return "notifUserReply"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            return "notifPostZap"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            return "notifPostLike"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            return "notifPostRepost"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            return "notifPostReply"
        }
    }
}
