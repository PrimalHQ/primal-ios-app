//
//  UserInfoTableCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import UIKit
import Kingfisher

final class UserInfoTableCell: UITableViewCell, Themeable {
    let nameLabel = UILabel()
    let secondaryLabel = UILabel()
    let profileIcon = UserImageView(height: 36)
    let followersLabel = UILabel()
    let followTitleLabel = UILabel()
    lazy var followStack = UIStackView(arrangedSubviews: [followersLabel, followTitleLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(user: ParsedUser) {
        updateTheme()
        
        nameLabel.text = user.data.atIdentifierWithoutAt
        
        if CheckNip05Manager.instance.isVerified(user.data) {
            secondaryLabel.text = user.data.parsedNip
            secondaryLabel.isHidden = false
        } else {
            secondaryLabel.isHidden = true
        }
        
        profileIcon.setUserImage(user)
        
        if let count = user.followers {
            followersLabel.text = Int32(count).shortened()
            followStack.isHidden = false
        } else {
            followStack.isHidden = true
        }
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        nameLabel.textColor = .foreground
        followersLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground5
        followTitleLabel.textColor = .foreground5
    }
}

private extension UserInfoTableCell {
    func setup() {
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, secondaryLabel])
        nameStack.alignment = .leading
        nameStack.axis = .vertical
        nameStack.spacing = 4
        
        followStack.axis = .vertical
        followStack.spacing = 2
        followStack.alignment = .trailing
        
        let mainStack = UIStackView(arrangedSubviews: [profileIcon, nameStack, UIView(), followStack])
        mainStack.alignment = .center
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 10)
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        followTitleLabel.font = .appFont(withSize: 14, weight: .regular)
        followersLabel.font = .appFont(withSize: 14, weight: .bold)
        
        followTitleLabel.text = "followers"
    }
}
