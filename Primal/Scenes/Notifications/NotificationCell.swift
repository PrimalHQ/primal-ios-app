//
//  NotificationCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 28.6.23..
//

import UIKit

protocol NotificationCellDelegate: PostCellDelegate {
    func avatarListTappedInCell(_ cell: NotificationCell, index: Int)
}

final class NotificationCell: PostCell {
    let iconView = UIImageView()
    let iconLabel = UILabel()
    let avatarStack = AvatarView()
    let titleLabel = UILabel()
    let border = SpacerView(height: 1)
    
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    lazy var postContentStack = UIStackView(arrangedSubviews: [textStack, mainImages, linkPresentation, postPreview, SpacerView(height: 0), bottomButtonStack])
    
    var notificationCellDelegate: NotificationCellDelegate? {
        get { delegate as? NotificationCellDelegate }
        set { delegate = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForNotification(_ notification: GroupedNotification, delegate: NotificationCellDelegate, didLike: Bool, didRepost: Bool, didZap: Bool) {
        if let post = notification.post {
            update(post, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: false)
            postContentStack.isHidden = false
            bottomButtonStack.isHidden = post.user.data.npub == IdentityManager.instance.user?.npub
        } else {
            postContentStack.isHidden = true
        }
        
        iconView.image = notification.icon
        iconLabel.attributedText = notification.iconText
        
        avatarStack.setImages(notification.users.compactMap { $0.profileImage.url(for: .small) })
        
        titleLabel.attributedText = notification.titleText
        
        notificationCellDelegate = delegate
    }
    
    override func update(_ parsedContent: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        super.update(parsedContent, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
    }
}

private extension NotificationCell {
    func setup() {
//        backgroundColorView.removeFromSuperview()
        
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
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        seeMoreLabel.textColor = .accent
        
        mainStack.alignment = .top
        mainStack.spacing = 4
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
        border.backgroundColor = .foreground6
        
        for (index, imageView) in avatarStack.avatarViews.enumerated() {
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
                notificationCellDelegate?.avatarListTappedInCell(self, index: index)
            }))
        }
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
            
            if CheckNip05Manager.instance.isVerified(first.data) {
                let attachment = NSTextAttachment()
                attachment.image = Theme.current.isPurpleTheme ? UIImage(named: "verifiedBadge") : UIImage(named: "verifiedBadgeBlue")
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
        case .YOUR_POST_WAS_ZAPPED:
            guard let sats = post?.post.satszapped.shortened() else { return "zapped your post" }
            return "zapped your note for a total of \(sats) sats"
        case .YOUR_POST_WAS_LIKED:
            return "liked your note"
        case .YOUR_POST_WAS_REPOSTED:
            return "reposted your note"
        case .YOUR_POST_WAS_REPLIED_TO:
            return "replied to your note"
        case .YOU_WERE_MENTIONED_IN_POST:
            return "mentioned you in a note"
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            return "mentioned your note"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            guard let sats = post?.post.satszapped.shortened() else {
                return "zapped a note you were mentioned in"
            }
            return "zapped a note you were mentioned in for a total of \(sats) sats"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            return "liked a note you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            return "reposted a note you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to a note you were mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            guard let sats = post?.post.satszapped.shortened() else {
                return "zapped a note your note was mentioned in"
            }
            return "zapped a note your note was mentioned in for a total of \(sats) sats"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            return "liked a note your note was mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            return "reposted a note your note was mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to a note your note was mentioned in"
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
