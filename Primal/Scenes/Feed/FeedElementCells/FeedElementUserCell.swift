//
//  FeedElementUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementBaseCell: UITableViewCell {
    weak var delegate: FeedElementCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(_ parsedContent: ParsedContent) {
        
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background2
    }
}

class FeedElementUserCell: FeedElementBaseCell, RegularFeedElementCell {
    
    static var cellID: String { "FeedElementUserCell" }
    
    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: FontSizeSelection.current.avatarSize)
    let checkbox = VerifiedView().constrainToAspect(1)
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let nipLabel = UILabel()
    let repostIndicator = RepostedIndicatorView()
    let separatorLabel = UILabel()
    let replyingToView = ReplyingToView()
    lazy var nameStack = UIStackView([nameLabel, checkbox, nipLabel, separatorLabel, timeLabel])
    lazy var nameReplyStack = UIStackView(axis: .vertical, [nameStack, replyingToView])
    lazy var nameSuperStack = UIStackView([profileImageView, nameReplyStack])
    lazy var mainStack = UIStackView(axis: .vertical, [repostIndicator, nameSuperStack])
    let threeDotsSpacer = SpacerView(width: 20)
    
    let repostedByOverlayButton = UIButton()
    
    var checkboxHeightC: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .horizontal, padding: 16)
        let botC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        botC.priority = .defaultLow
        botC.isActive = true
        
        mainStack.spacing = 4
        nameReplyStack.spacing = 4
        nameSuperStack.spacing = 8
        
        contentView.addSubview(threeDotsButton)
        threeDotsButton
            .constrainToSize(44)
            .pinToSuperview(edges: .top, padding: 2)
            .pinToSuperview(edges: .trailing)
        
        nameStack.addArrangedSubview(threeDotsSpacer)
        
        contentView.addSubview(repostedByOverlayButton)
        repostedByOverlayButton
            .constrainToSize(width: 100)
            .pin(to: repostIndicator, edges: .leading)
            .pin(to: repostIndicator, edges: .top, padding: -11)
            .pin(to: repostIndicator, edges: .bottom, padding: -5)
        
        repostedByOverlayButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.postCellDidTap(self, .repostedProfile)
        }), for: .touchUpInside)
        
        separatorLabel.text = "·"
        
        [nameLabel, nipLabel, separatorLabel].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        nipLabel.lineBreakMode = .byTruncatingTail
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nipLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        threeDotsButton.setContentHuggingPriority(.required, for: .horizontal)
        
        checkboxHeightC = checkbox.heightAnchor.constraint(equalToConstant: FontSizeSelection.current.contentFontSize)
        checkboxHeightC?.isActive = true
        nameStack.alignment = .center
        nameStack.spacing = 4
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        threeDotsButton.showsMenuAsPrimaryAction = true

        let tapArea = UIView()
        contentView.addSubview(tapArea)
        tapArea
            .pin(to: profileImageView, edges: [.leading, .vertical])
            .pin(to: separatorLabel, edges: .trailing)
        tapArea.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .profile)
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ parsedContent: ParsedContent) {
        let user = parsedContent.user.data
        
        nameLabel.text = user.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user) {
            nipLabel.text = user.parsedNip
            nipLabel.isHidden = false
            checkbox.user = user
        } else {
            nipLabel.isHidden = true
            checkbox.isHidden = true
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(parsedContent.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.setUserImage(parsedContent.user)
        
        if let parent = parsedContent.replyingTo {
            replyingToView.userNameLabel.text = parent.user.data.firstIdentifier
            replyingToView.isHidden = false
            nameSuperStack.alignment = .top
        } else {
            replyingToView.isHidden = true
            nameSuperStack.alignment = .center   
        }
        
        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted == nil ? .identity : .init(translationX: 0, y: -6)
        
        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -6) : (parsedContent.replyingTo == nil ? .init(translationX: 0, y: 4) : .identity)
        
        if let reposted = parsedContent.reposted?.users {
            repostIndicator.update(users: reposted)
            repostIndicator.isHidden = false
        } else {
            repostIndicator.isHidden = true
        }
        repostedByOverlayButton.isHidden = parsedContent.reposted == nil
        
        
        let postInfo = parsedContent.postInfo
        let muteTitle = postInfo.isMuted ? "Unmute User" : "Mute User"
        
        let bookmarkAction = ("Add To Bookmarks", "MenuBookmark", PostCellEvent.bookmark, UIMenuElement.Attributes.keepsMenuPresented)
        let unbookmarkAction = ("Remove Bookmark", "MenuBookmarkFilled", PostCellEvent.unbookmark, UIMenuElement.Attributes.keepsMenuPresented)
        
        let actionsData: [(String, String, PostCellEvent, UIMenuElement.Attributes)] = [
            ("Share Note", "MenuShare", .share, []),
            ("Copy Note Link", "MenuCopyLink", .copy(.link), []),
            postInfo.isBookmarked ? unbookmarkAction : bookmarkAction,
            ("Copy Note Text", "MenuCopyText", .copy(.content), []),
            ("Copy Raw Data", "MenuCopyData", .copy(.rawData), []),
            ("Copy Note ID", "MenuCopyNoteID", .copy(.noteID), []),
            ("Copy User Public Key", "MenuCopyUserPubkey", .copy(.userPubkey), []),
            ("Broadcast", "MenuBroadcast", .broadcast, []),
            (muteTitle, "blockIcon", .mute, .destructive),
            ("Report user", "warningIcon", .report, .destructive)
        ]

        threeDotsButton.menu = .init(children: actionsData.map { (title, imageName, action, attributes) in
            UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { [weak self] _ in
                guard let self = self else { return }
                delegate?.postCellDidTap(self, action)
            }
        })
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        threeDotsButton.tintColor = .foreground3
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)
        
        checkboxHeightC?.constant = FontSizeSelection.current.contentFontSize
        
        [timeLabel, separatorLabel, nipLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }
    }
}
