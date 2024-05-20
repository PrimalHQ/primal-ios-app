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
    let auxTitleLabel = UILabel()
    let border = SpacerView(height: 1)
    let newIndicator = UIView().constrainToSize(8)
    
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    lazy var bottomBarStandIn = UIView()
    lazy var postContentStack = UIStackView(arrangedSubviews: [textStack, mainImages, linkPresentation, postPreview, bottomBarStandIn])
    
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
    
    func updateForNotification(_ notification: GroupedNotification, isNew: Bool, delegate: NotificationCellDelegate) {
        if let post = notification.post {
            update(post)
            postContentStack.isHidden = false
            bottomBarStandIn.isHidden = post.user.data.npub == IdentityManager.instance.user?.npub
        } else {
            postContentStack.isHidden = true
        }
        
        iconView.image = notification.icon
        iconLabel.attributedText = notification.iconText
        
        avatarStack.setImages(notification.users.compactMap { $0.profileImage.url(for: .small) }, userCount: notification.users.count)
        
        titleLabel.attributedText = notification.titleText
        auxTitleLabel.attributedText = notification.titleText
        
        titleLabel.isHidden = notification.users.count == 1
        auxTitleLabel.isHidden = notification.users.count != 1
        
        timeLabel.text = notification.mainNotification.date.timeAgoDisplay()
        
        notificationCellDelegate = delegate
        
        newIndicator.isHidden = !isNew
    }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        mainLabel.numberOfLines = parsedContent.user.isCurrentUser ? 6 : 20
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
    }
}

private extension NotificationCell {
    func setup() {
        bottomBarStandIn.addSubview(bottomButtonStack)
        bottomButtonStack
            .pinToSuperview(edges: .horizontal, padding: -8)
            .pinToSuperview(edges: .top, padding: -6)
            .pinToSuperview(edges: .bottom, padding: -12)
        
        let iconStack = UIStackView(arrangedSubviews: [SpacerView(height: 4), iconView, iconLabel])
        
        let auxParent = UIView()
        auxParent.addSubview(auxTitleLabel)
        auxTitleLabel.pinToSuperview(edges: .horizontal)
        auxTitleLabel.centerToSuperview(axis: .vertical)
        
        let firstRow = UIStackView([avatarStack, auxParent, timeLabel])
        
        let contentStack = UIStackView(arrangedSubviews: [firstRow, titleLabel, postContentStack])
        let mainStack = UIStackView(arrangedSubviews: [iconStack, contentStack])
        
        avatarStack.constrainToSize(height: 32)
        
        iconView.tintColor = .init(rgb: 0x52CE0A)
        
        titleLabel.numberOfLines = 0
        iconLabel.textAlignment = .center
        
        timeLabel.font = .appFont(withSize: 14, weight: .regular)
        timeLabel.textColor = .foreground4
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        auxTitleLabel.adjustsFontSizeToFitWidth = true
        auxTitleLabel.numberOfLines = 2
        
        firstRow.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading, padding: 12)
            .pinToSuperview(edges: .trailing, padding: 22)
            .pinToSuperview(edges: .top, padding: 12)
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        contentView.addSubview(newIndicator)
        newIndicator.pinToSuperview(edges: [.top, .trailing], padding: 10)
        newIndicator.layer.cornerRadius = 4
        newIndicator.backgroundColor = .accent
        
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
        border.backgroundColor = .background3
        
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
                .foregroundColor: UIColor.foreground,
                .font: UIFont.appFont(withSize: 18, weight: .bold)
            ]))
            
            string.append(.init(string: " "))
            
            if CheckNip05Manager.instance.isVerified(first.data) {
                let attachment = NSTextAttachment()
                attachment.image = Theme.current.isPurpleTheme ? UIImage(named: "verifiedBadgeNotifications") : UIImage(named: "verifiedBadgeNotificationsBlue")
                string.append(NSAttributedString(attachment: attachment))
                string.append(.init(string: " "))
            }            
        }
        
        if users.count > 1 {
            let text = "and \(users.count - 1) other" + (users.count == 2 ? "" : "s")
            string.append(NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.foreground,
                .font: UIFont.appFont(withSize: 18, weight: .regular)
            ]))
        }
        
//        string.append(NSAttributedString(string: notificationTypeText, attributes: [
//            .foregroundColor: UIColor.foreground,
//            .font: UIFont.appFont(withSize: 18, weight: .regular)
//        ]))
        
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
            return nil
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
            return "notifPostZap1"
        case .YOUR_POST_WAS_LIKED:
            return "notifPostLike1"
        case .YOUR_POST_WAS_REPOSTED:
            return "notifPostRepost1"
        case .YOUR_POST_WAS_REPLIED_TO:
            return "notifPostReply1"
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
