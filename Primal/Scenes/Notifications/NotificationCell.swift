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

final class NotificationCell: PostCell, ElementReactionsCell {
    let iconView = UIImageView()
    let iconLabel = UILabel()
    let avatarStack = AvatarView()
    let titleLabel = UILabel()
    let border = SpacerView(height: 1)
    let newIndicator = UIView().constrainToSize(8)
    
    let mainParent = UIView()
    let auxParent = UIView()
    
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
    
    func updateForNotification(_ notification: GroupedNotification, isNew: Bool, delegate: NotificationCellDelegate?) {
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
        
        titleLabel.attributedText = notification.fullTitleText
        
        if notification.users.count <= 1 {
            auxParent.isHidden = false
            mainParent.isHidden = true
            if titleLabel.superview != auxParent {
                titleLabel.removeFromSuperview()
                auxParent.addSubview(titleLabel)
                titleLabel.pinToSuperview()//edges: .horizontal).centerToSuperview(axis: .vertical)
            }
        } else {
            auxParent.isHidden = true
            mainParent.isHidden = false
            if titleLabel.superview != mainParent {
                titleLabel.removeFromSuperview()
                mainParent.addSubview(titleLabel)
                titleLabel.pinToSuperview()
            }
        }
        
        timeLabel.text = notification.mainNotification.date.timeAgoDisplay()
        
        notificationCellDelegate = delegate
        
        newIndicator.isHidden = !isNew
    }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        mainLabel.numberOfLines = parsedContent.user.isCurrentUser ? 6 : 12
        
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
        
        let firstRow = UIStackView([avatarStack, auxParent, UIView(), timeLabel])
        
        let contentStack = UIStackView(arrangedSubviews: [firstRow, mainParent, postContentStack])
        let mainStack = UIStackView(arrangedSubviews: [iconStack, contentStack])
        
        iconView.centerToView(avatarStack, axis: .vertical)
        iconView.setContentHuggingPriority(.required, for: .vertical)
        
        avatarStack.constrainToSize(height: 32)
        
        iconView.tintColor = .init(rgb: 0x52CE0A)
        
        titleLabel.numberOfLines = 0
        iconLabel.textAlignment = .center
        
        timeLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize - 1, weight: .regular)
        timeLabel.textColor = .foreground4
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        firstRow.spacing = 8
        firstRow.alignment = .center
        
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
        mainLabel.numberOfLines = 12
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        seeMoreLabel.textColor = .accent2
        
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
    var fullTitleText: NSAttributedString {
        let string = NSMutableAttributedString(attributedString: userNameText)
        if users.count > 1 {
            string.append(andOthersText)
        }
        string.append(titleText)
        return string
    }
    
    var userNameText: NSAttributedString {
        NSAttributedString(string: (users.first?.data.firstIdentifier ?? "") + " ", attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .bold)
        ])
    }
    
    var andOthersText: NSAttributedString {
        NSAttributedString(string: "and \(users.count - 1) other" + (users.count == 2 ? " " : "s "), attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        ])
    }
    
    var titleText: NSAttributedString {
        NSAttributedString(string: notificationTypeText, attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        ])
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
            return "zapped your note"
        case .YOUR_POST_WAS_LIKED, .YOUR_POST_WAS_HIGHLIGHTED, .YOUR_POST_WAS_BOOKMARKED:
            return "reacted to your note"
        case .YOUR_POST_WAS_REPOSTED:
            return "reposted your note"
        case .YOUR_POST_WAS_REPLIED_TO:
            return "replied to your note"
        case .YOU_WERE_MENTIONED_IN_POST:
            return "mentioned you in a note"
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            return "mentioned your note"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            return "zapped a note you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            return "liked a note you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            return "reposted a note you were mentioned in"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to a note you were mentioned in"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            return "zapped a note your note was mentioned in"
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
        case .YOUR_POST_WAS_HIGHLIGHTED:
            return "notifHighlight"
        case .YOUR_POST_WAS_BOOKMARKED:
            return "notifBookmark"
        }
    }
}
