//
//  RepostUserTableViewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.4.24..
//

import UIKit
import FLAnimatedImage

final class RepostUserTableViewCell: UITableViewCell, Themeable {
    private let icon = UIImageView(image: UIImage(named: "feedRepostBig"))
    private let avatarView = UserImageView(height: 42)
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let mainStack = UIStackView([icon, avatarView, nameLabel])
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        mainStack.alignment = .center
        mainStack.spacing = 12
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateForUser(_ user: ParsedUser) {
        avatarView.setUserImage(user)
        nameLabel.text = user.data.firstIdentifier
        
        updateTheme()
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background2
        
        icon.tintColor = .foreground3
        nameLabel.textColor = .foreground
    }
}
