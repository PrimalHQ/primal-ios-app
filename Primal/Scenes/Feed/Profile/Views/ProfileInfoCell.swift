//
//  ProfileInfoCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import Combine
import Nantes
import UIKit
import GenericJSON

protocol ProfileInfoCellDelegate: AnyObject {
    func npubPressed()
    func followPressed(in cell: ProfileInfoCell)
    func zapPressed()
    func editProfilePressed()
    func messagePressed()
    func linkPressed(_ url: URL)
    
    func didSelectTab(_ tab: Int)
}

class ProfileCellNantesDelegate {
    weak var cell: ProfileInfoCell?
    init(cell: ProfileInfoCell) {
        self.cell = cell
    }
}

class ProfileInfoCell: UITableViewCell {
    let zapButton = CircleIconButton(icon: UIImage(named: "profileZap"))
    let messageButton = CircleIconButton(icon: UIImage(named: "profileMessage"))
    let followButton = BrightSmallButton(title: "follow")
    let unfollowButton = RoundedSmallButton(text: "unfollow")
    let editProfile = RoundedSmallButton(text: "edit profile")
    
    let primaryLabel = UILabel()
    let checkboxIcon = UIImageView(image: UIImage(named: "purpleVerified")).constrainToSize(20)
    let followsYou = FollowsYouView()
    
    let secondaryLabel = UILabel()
    
    let npubView = NPubDisplayView()
    let descLabel = NantesLabel()
    let linkView = ProfileLinkDisplayView()
    
    let infoStack = ProfileTabSelectionView(tabs: ["notes", "replies", "following", "followers"])
    
    weak var delegate: ProfileInfoCellDelegate?
    
    lazy var nantesDelegate = ProfileCellNantesDelegate(cell: self)
    
    var cancellables: Set<AnyCancellable> = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func update(user: PrimalUser, parsedDescription: NSAttributedString, stats: NostrUserProfileInfo?, followsUser: Bool, selectedTab: Int, delegate: ProfileInfoCellDelegate?) {
        self.delegate = delegate
        
        primaryLabel.text = user.firstIdentifier
        primaryLabel.isHidden = primaryLabel.text == user.npub
        
        followsYou.isHidden = !followsUser
        
        if CheckNip05Manager.instance.isVerified(user) {
            checkboxIcon.isHidden = false
            checkboxIcon.tintColor = .accent
            
            secondaryLabel.isHidden = false
            secondaryLabel.text = user.parsedNip
        } else {
            checkboxIcon.isHidden = true
            secondaryLabel.isHidden = true
        }
        
        npubView.npub = user.npub
        descLabel.attributedText = parsedDescription
        linkView.link = user.website.trimmingCharacters(in: .whitespaces)
        
        zip(infoStack.buttons, [
            (stats?.note_count ?? 0).shortenedLocalized(),
            (stats?.reply_count ?? 0).shortenedLocalized(),
            (stats?.follows_count ?? 0).shortenedLocalized(),
            (stats?.followers_count ?? 0).shortenedLocalized()
        ]).forEach { button, text in
            button.text = text
        }
        
        infoStack.set(selectedTab)
        
        editProfile.isHidden = user.pubkey != IdentityManager.instance.userHexPubkey
        zapButton.isHidden = user.pubkey == IdentityManager.instance.userHexPubkey

        if user.pubkey == IdentityManager.instance.userHexPubkey {
            followButton.isHidden = true
            unfollowButton.isHidden = true
        } else {
            updateFollowButton(FollowManager.instance.isFollowing(user.pubkey))
        }
    }
    
    func updateFollowButton(_ isFollowing: Bool) {
        followButton.isHidden = isFollowing
        unfollowButton.isHidden = !isFollowing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfileCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        cell?.delegate?.linkPressed(link)
    }
}

private extension ProfileInfoCell {
    func setup() {
        let actionStack = UIStackView(arrangedSubviews: [SpacerView(width: 400, priority: .defaultLow), zapButton, messageButton, followButton, unfollowButton, editProfile])
        actionStack.spacing = 8
        actionStack.alignment = .bottom
        
        let primaryStack = UIStackView(arrangedSubviews: [primaryLabel, checkboxIcon, followsYou, UIView()])
        primaryStack.spacing = 4
        primaryStack.alignment = .center
        
        primaryLabel.font = .appFont(withSize: 20, weight: .bold)
        primaryLabel.adjustsFontSizeToFitWidth = true
        
        followsYou.isHidden = true
        
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        
        descLabel.font = .appFont(withSize: 14, weight: .regular)
        descLabel.numberOfLines = 0
        
        let mainStack = UIStackView(arrangedSubviews: [actionStack, primaryStack, secondaryLabel, npubView, descLabel, linkView, infoStack])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(14, after: actionStack)
        mainStack.setCustomSpacing(8, after: primaryStack)
        mainStack.setCustomSpacing(12, after: secondaryLabel)
        mainStack.setCustomSpacing(16, after: npubView)
        mainStack.setCustomSpacing(8, after: descLabel)
        mainStack.setCustomSpacing(16, after: infoStack)
        
        infoStack.pinToSuperview(edges: .horizontal)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 12)
        let bot = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bot.priority = .defaultHigh
        bot.isActive = true
        
        contentView.backgroundColor = .background2
        primaryLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground5
        descLabel.textColor = .foreground
        
        descLabel.enabledTextCheckingTypes = .allSystemTypes
        descLabel.linkAttributes = [
            .foregroundColor: UIColor.accent
        ]
        descLabel.delegate = nantesDelegate
        
        npubView.addTarget(self, action: #selector(npubPressed), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        unfollowButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        editProfile.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.editProfilePressed()
        }), for: .touchUpInside)
        zapButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.zapPressed()
        }), for: .touchUpInside)
        messageButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.messagePressed()
        }), for: .touchUpInside)
        
        infoStack.$selectedTab.removeDuplicates().dropFirst().sink { [weak self] tab in
            self?.delegate?.didSelectTab(tab)
        }
        .store(in: &cancellables)
    }
    
    @objc func npubPressed() {
        delegate?.npubPressed()
    }
    
    @objc func followPressed() {
        delegate?.followPressed(in: self)
    }
}

final class FollowsYouView: UIView {
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 8).centerToSuperview()
        label.font = .appFont(withSize: 14, weight: .thin)
        label.text = "follows you"
        
        constrainToSize(height: 22)
        
        layer.cornerRadius = 4
        
        label.textColor = .foreground3
        backgroundColor = .background3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
