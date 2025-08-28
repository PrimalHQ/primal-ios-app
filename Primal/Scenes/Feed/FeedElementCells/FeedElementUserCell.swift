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
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(_ parsedContent: ParsedContent) {
        
    }
    
    func updateTheme() {
    }
}

class FeedElementUserCell: FeedElementBaseCell, RegularFeedElementCell {
    
    static var cellID: String { "FeedElementUserCell" }
    
    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: FontSizeSelection.current.avatarSize)
    let checkbox = VerifiedView().constrainToAspect(1, priority: .required)
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
    let threeDotsSpacer = SpacerView(width: 20, priority: .required)
    
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
        
        threeDotsButton.menu = .init(children: parsedContent.actionsData().map { (title, image, action, attributes) in
            UIAction(title: title, image: image, attributes: attributes) { [weak self] _ in
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

extension ParsedContent {
    func actionsData() -> [(String, UIImage, PostCellEvent, UIMenuElement.Attributes)] {
        let postInfo = postInfo
        let userMuteTitle = postInfo.isUserMuted ? "Unmute User" : "Mute User"
        
        let bookmarkAction = ("Add Bookmark", UIImage.menuBookmark, PostCellEvent.bookmark, UIMenuElement.Attributes.keepsMenuPresented)
        let unbookmarkAction = ("Remove Bookmark", UIImage.menuBookmarkFilled, PostCellEvent.unbookmark, UIMenuElement.Attributes.keepsMenuPresented)
        
        var actionsData: [(String, UIImage, PostCellEvent, UIMenuElement.Attributes)] = []
        
        if postInfo.isPostMuted {
            actionsData.append(("Unmute Thread", .menuMuteThread, .toggleMutePost, .destructive))
        }
        
        let mainData: [(String, UIImage, PostCellEvent, UIMenuElement.Attributes)] = [
            ("Share Note", .menuShare, .share, []),
            postInfo.isBookmarked ? unbookmarkAction : bookmarkAction,
            ("Share as Image", .menuShareAs, .shareAsImage, []),
            ("Copy Note Link", .menuCopyLink, .copy(.link), []),
            ("Copy Note Text", .menuCopyText, .copy(.content), []),
            ("Copy Note ID", .menuCopyNoteID, .copy(.noteID), []),
            ("Copy Raw Data", .menuCopyData, .copy(.rawData), []),
        ]
        actionsData.append(contentsOf: mainData)
        
        if user.data.pubkey != IdentityManager.instance.userHexPubkey {
            actionsData.append((userMuteTitle, .blockIcon, .muteUser, .destructive))
        }
        
        if user.data.pubkey != IdentityManager.instance.userHexPubkey {
            if !postInfo.isPostMuted {
                actionsData.append(("Mute Thread", .menuMuteThread, .toggleMutePost, .destructive))
            }
            actionsData.append(("Report Content", .warningIcon, .report, .destructive))
        } else {
            actionsData.append(("Request Delete", .menuTrash, .requestDelete, .destructive))
        }
            
        return actionsData
    }
}
