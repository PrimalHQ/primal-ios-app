//
//  ProfileInfoCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

protocol ProfileInfoCellDelegate: AnyObject {
    func npubPressed()
    func followPressed(in cell: ProfileInfoCell)
}

class ProfileInfoCell: UITableViewCell {
    let zapButton = GradientBorderIconButton(icon: UIImage(named: "profileZap"))
    let messageButton = GradientBorderIconButton(icon: UIImage(named: "profileMessage"))
    let followButton = GradientButton(title: "follow")
    let editProfile = GradientBorderTextButton(text: "edit profile")
    
    let primaryLabel = UILabel()
    let checkboxIcon = UIImageView(image: UIImage(named: "purpleVerified"))
    
    let secondaryLabel = UILabel()
    
    let npubView = NPubDisplayView()
    let descLabel = UILabel()
    let linkView = ProfileLinkDisplayView()
    
    let following = ProfileStatDisplayView("Following")
    let followers = ProfileStatDisplayView("Followers")
    let posts = ProfileStatDisplayView("Posts")
    
    weak var delegate: ProfileInfoCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func update(user: PrimalUser, stats: NostrUserProfileInfo?, delegate: ProfileInfoCellDelegate?) {
        self.delegate = delegate
        
        primaryLabel.text = user.firstIdentifier
        
        checkboxIcon.isHidden = user.nip05.isEmpty
        secondaryLabel.isHidden = user.nip05.isEmpty
        secondaryLabel.text = user.nip05
        
        npubView.npub = user.npub
        descLabel.text = user.about
        linkView.link = user.website
        
        following.text = (stats?.follows_count ?? 0).localized()
        followers.text = (stats?.followers_count ?? 0).localized()
        posts.text = (stats?.note_count ?? 0).localized()
        
        if user.id == IdentityManager.instance.user?.id {
            followButton.isHidden = true
            editProfile.isHidden = false
        } else {
            followButton.isHidden = false
            editProfile.isHidden = true
            
            updateFollowButton(FollowManager.instance.isFollowing(user.pubkey))
        }
    }
    
    func updateFollowButton(_ isFollowing: Bool) {
        followButton.title = isFollowing ? "unfollow" : "follow"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ProfileInfoCell {
    func setup() {
        let actionStack = UIStackView(arrangedSubviews: [SpacerView(width: 200, priority: .defaultLow), zapButton, messageButton, followButton, editProfile])
        actionStack.spacing = 8
        actionStack.alignment = .bottom
        
        let primaryStack = UIStackView(arrangedSubviews: [primaryLabel, checkboxIcon, UIView()])
        primaryStack.spacing = 4
        primaryStack.alignment = .center
        
        primaryLabel.font = .appFont(withSize: 20, weight: .bold)
        primaryLabel.adjustsFontSizeToFitWidth = true
        
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        
        descLabel.font = .appFont(withSize: 14, weight: .regular)
        descLabel.numberOfLines = 0
        
        let infoStack = UIStackView(arrangedSubviews: [following, followers, posts])
        infoStack.spacing = 60
        
        let mainStack = UIStackView(arrangedSubviews: [actionStack, primaryStack, secondaryLabel, npubView, descLabel, linkView, infoStack])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(14, after: actionStack)
        mainStack.setCustomSpacing(8, after: primaryStack)
        mainStack.setCustomSpacing(12, after: secondaryLabel)
        mainStack.setCustomSpacing(16, after: npubView)
        mainStack.setCustomSpacing(8, after: descLabel)
        mainStack.setCustomSpacing(16, after: infoStack)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        
        contentView.backgroundColor = .background2
        primaryLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground5
        descLabel.textColor = .foreground
        
        npubView.addTarget(self, action: #selector(npubPressed), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
    }
    
    @objc func npubPressed() {
        delegate?.npubPressed()
    }
    
    @objc func followPressed() {
        delegate?.followPressed(in: self)
    }
}
