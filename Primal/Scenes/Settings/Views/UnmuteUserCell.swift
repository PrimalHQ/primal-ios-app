//
//  UnmuteUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.9.23..
//

import UIKit

protocol UnmuteUserCellDelegate: AnyObject {
    func unmuteButtonPressed(_ cell: UnmuteUserCell)
}

final class UnmuteUserCell: UITableViewCell, Themeable {
    let profileImage = VerifiedImageView()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let unmuteButton = UIButton(configuration: .capsule14Grey("unmute"))
    let border = SpacerView(height: 1)
    
    weak var delegate: UnmuteUserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        nameLabel.textColor = .foreground
        usernameLabel.textColor = .foreground5
        border.backgroundColor = .background3
        
        unmuteButton.configuration = .capsule14Grey("unmute")
    }
}

private extension UnmuteUserCell {
    func setup() {
        selectionStyle = .none
        
        let vStack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        let hStack = UIStackView(arrangedSubviews: [profileImage, vStack, unmuteButton])
        
        contentView.addSubview(hStack)
        hStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 12)
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom)
        
        hStack.spacing = 8
        hStack.alignment = .center
        
        vStack.axis = .vertical
        
        profileImage.constrainToSize(36).imageView.layer.cornerRadius = 18
        
        nameLabel.font = .appFont(withSize: 14, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        usernameLabel.font = .appFont(withSize: 14, weight: .regular)
        usernameLabel.adjustsFontSizeToFitWidth = true
        
        unmuteButton.constrainToSize(width: 88, height: 36)
        unmuteButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        
        updateTheme()
    }
    
    @objc func followPressed() {
        delegate?.unmuteButtonPressed(self)
    }
}
