//
//  ProfileFollowCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.11.23..
//

import FLAnimatedImage
import UIKit

protocol ProfileFollowCellDelegate: AnyObject {
    func followButtonPressedInCell(_ cell: UITableViewCell)
}

final class ProfileFollowCell: UITableViewCell, Themeable {
    let avatar = FLAnimatedImageView()
    
    let name = UILabel()
    let subname = UILabel()

    let followCount = UILabel()
    let followDesc = UILabel()
    
    let action = ProfileFollowCellButton()
    
    let border = UIView()
    
    weak var delegate: ProfileFollowCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForUser(_ user: ParsedUser) {
        name.text = user.data.firstIdentifier
        subname.text = user.data.secondIdentifier
        followCount.text = (user.followers ?? 0).localized()
        
        action.isFollowing = FollowManager.instance.isFollowing(user.data.pubkey)
        
        action.alpha = user.isCurrentUser ? 0.01 : 1
        action.isEnabled = !user.isCurrentUser
        
        avatar.setUserImage(user)
        
        updateTheme()
    }
    
    func updateTheme() {
        name.textColor = .foreground
        followCount.textColor = .foreground
        subname.textColor = .foreground5
        followDesc.textColor = .foreground5
        
        border.backgroundColor = .background3
        
        action.updateTheme()
    }
}

private extension ProfileFollowCell {
    func setup() {
        selectionStyle = .none
        
        let firstRow = UIStackView([name, UIView(), followCount])
        let secondRow = UIStackView([subname, UIView(), followDesc])
        let vStack = UIStackView(axis: .vertical, [firstRow, secondRow])
        
        let main = UIStackView([avatar, vStack, action])
        main.spacing = 8
        main.alignment = .center
        
        contentView.addSubview(main)
        main.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .bottom).constrainToSize(height: 1)
        
        avatar.constrainToSize(36)
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 18
        avatar.layer.masksToBounds = true
        
        name.font = .appFont(withSize: 16, weight: .bold)
        subname.font = .appFont(withSize: 14, weight: .regular)
        followCount.font = .appFont(withSize: 14, weight: .bold)
        followDesc.font = .appFont(withSize: 14, weight: .regular)
        
        followDesc.text = "followers"
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.action.isFollowing.toggle()
            self.delegate?.followButtonPressedInCell(self)
        }), for: .touchUpInside)
        
        updateTheme()
    }
}

final class ProfileFollowCellButton: UIButton, Themeable {
    var isFollowing = true {
        didSet {
            updateTheme()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        constrainToSize(width: 72, height: 32)
        
        titleLabel?.font = .appFont(withSize: 14, weight: .semibold)
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        setTitle(isFollowing ? "unfollow" : "follow", for: .normal)
        setTitleColor(isFollowing ? .foreground : .background, for: .normal)
        setTitleColor((isFollowing ? UIColor.foreground : .background).withAlphaComponent(0.5), for: .highlighted)
        
        backgroundColor = isFollowing ? .background3 : .foreground
    }
}
