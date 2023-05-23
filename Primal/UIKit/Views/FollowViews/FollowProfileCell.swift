//
//  FollowProfileCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import UIKit

protocol FollowProfileCellDelegate: AnyObject {
    func followButtonPressed(_ cell: FollowProfileCell)
}

final class FollowProfileCell: UITableViewCell {
    let profileImage = VerifiedImageView()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let followButton = FollowButton()
    
    weak var delegate: FollowProfileCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        
    }
}

private extension FollowProfileCell {
    func setup() {
        contentView.backgroundColor = .black
        selectionStyle = .none
        
        let vStack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        let hStack = UIStackView(arrangedSubviews: [profileImage, vStack, followButton])
        
        addSubview(hStack)
        hStack
            .pinToSuperview(edges: .horizontal, padding: 28)
            .pinToSuperview(edges: .vertical, padding: 16)
        
        hStack.spacing = 8
        hStack.alignment = .center
        
        vStack.axis = .vertical
        vStack.spacing = 4
        
        profileImage.constrainToSize(48).imageView.layer.cornerRadius = 24
        
        nameLabel.textColor = .white
        nameLabel.font = .appFont(withSize: 14, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        usernameLabel.textColor = .white
        usernameLabel.font = .appFont(withSize: 12, weight: .regular)
        usernameLabel.adjustsFontSizeToFitWidth = true
        
        followButton.constrainToSize(width: 88, height: 36)
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
    }
    
    @objc func followPressed() {
        followButton.isFollowing.toggle()
        delegate?.followButtonPressed(self)
    }
}
