//
//  UserInfoTableCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import UIKit
import Kingfisher

final class UserInfoTableCell: UITableViewCell {
    let nameLabel = UILabel()
    let secondaryLabel = UILabel()
    let profileIcon = UIImageView(image: UIImage(named: "profile"))
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
        nameLabel.text = user.data.atIdentifierWithoutAt
        secondaryLabel.text = user.data.nip05
        secondaryLabel.isHidden = user.data.nip05.isEmpty
        
        profileIcon.kf.setImage(with: user.profileImage.url(for: .small), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 36, height: 36))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        if let count = user.likes {
            followersLabel.text = count.shortened()
            followStack.isHidden = false
        } else {
            followStack.isHidden = true
        }
    }
}

private extension UserInfoTableCell {
    func setup() {
        profileIcon.constrainToSize(36)
        profileIcon.layer.cornerRadius = 18
        profileIcon.layer.masksToBounds = true
        
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, secondaryLabel])
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
        
        contentView.backgroundColor = .background
        nameLabel.textColor = .foreground
        followersLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground5
        followTitleLabel.textColor = .foreground5
    }
}
