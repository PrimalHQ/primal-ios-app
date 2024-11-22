//
//  FollowProfileCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import FLAnimatedImage
import UIKit

protocol FollowProfileCellDelegate: AnyObject {
    func followButtonPressed(_ cell: FollowProfileCell)
}

final class FollowProfileCell: UITableViewCell {
    let profileImage = UserImageView(height: 44)
    let nameLabel = UILabel()
    let secondaryLabel = UILabel()
    let followButton = FollowButton(backgroundColor: .init(rgb: 0xE5E5E5))
    
    weak var delegate: FollowProfileCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FollowProfileCell {
    func setup() {
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        let vStack = UIStackView(arrangedSubviews: [nameLabel, secondaryLabel])
        let hStack = UIStackView(arrangedSubviews: [profileImage, vStack, followButton])
        
        addSubview(hStack)
        hStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 8)
        
        hStack.spacing = 8
        hStack.alignment = .center
        
        vStack.axis = .vertical
        vStack.spacing = 4
        
        nameLabel.textColor = .black
        nameLabel.font = .appFont(withSize: 14, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        secondaryLabel.textColor = .init(rgb: 0x666666)
        secondaryLabel.font = .appFont(withSize: 12, weight: .regular)
        
        followButton.constrainToSize(width: 80, height: 32)
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
    }
    
    @objc func followPressed() {
        followButton.isFollowing.toggle()
        delegate?.followButtonPressed(self)
    }
}
