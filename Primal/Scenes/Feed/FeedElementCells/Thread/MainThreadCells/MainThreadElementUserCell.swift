//
//  MainThreadElementUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

import UIKit

class MainThreadElementUserCell: ThreadElementBaseCell, RegularFeedElementCell {
    weak var delegate: FeedElementCellDelegate?
    
    static var cellID: String { "FeedElementUserCell" }
    
    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: 42)
    let checkbox = VerifiedView()
    let nameLabel = UILabel()
    let nipLabel = UILabel()
    lazy var nameCheckStack = UIStackView([nameLabel, checkbox])
    lazy var nameSuperStack = UIStackView(axis: .vertical, [nameCheckStack, nipLabel])
    lazy var mainStack = UIStackView([profileImageView, nameSuperStack])
    let threeDotsSpacer = SpacerView(width: 20)
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
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
        
        profileImageView.setUserImage(parsedContent.user)
        
        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted == nil ? .identity : .init(translationX: 0, y: -6)
        
        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -6) : (parsedContent.replyingTo == nil ? .init(translationX: 0, y: 4) : .identity)
        
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
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)
        
        nipLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
        nipLabel.textColor = .foreground3
    }
}

private extension MainThreadElementUserCell {
    private func setup() {
        secondRow.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 12)
            .pinToSuperview(edges: .bottom, padding: 2)
            .pinToSuperview(edges: .horizontal)
        
        contentView.addSubview(threeDotsButton)
        threeDotsButton
            .constrainToSize(44)
            .pinToSuperview(edges: .trailing)
            .centerToSuperview(axis: .vertical)
        
        nameSuperStack.alignment = .leading
        nameSuperStack.spacing = 4
        
        nameCheckStack.spacing = 4
        
        mainStack.addArrangedSubview(threeDotsSpacer)
        
        [nameLabel, nipLabel].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        nipLabel.lineBreakMode = .byTruncatingTail
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nipLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        threeDotsButton.setContentHuggingPriority(.required, for: .horizontal)
        
        checkbox.constrainToSize(FontSizeSelection.current.contentFontSize)
        
        mainStack.alignment = .center
        mainStack.spacing = 8
        
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        threeDotsButton.showsMenuAsPrimaryAction = true

        profileImageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .profile)
        }))
    }
}