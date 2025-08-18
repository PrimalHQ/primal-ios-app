//
//  LiveVideoChatZapCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit
import Nantes

class LiveVideoChatZapCell: UITableViewCell {
    let userImage = UserImageView(height: 24)
    let userNameLabel = UILabel("", color: .gold, font: .appFont(withSize: 16, weight: .bold))
    let zapInfoLabel = UILabel("zapped", color: .gold, font: .appFont(withSize: 16, weight: .regular))
    let zapAmountLabel = UILabel("", color: .black, font: .appFont(withSize: 16, weight: .bold))
    let zapView = UIView().constrainToSize(height: 24)
    let zapIcon = UIImageView(image: .topZapGalleryIcon)
    let commentLabel = NantesLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let goldenBackground = UIView()
        goldenBackground.backgroundColor = .pro.withAlphaComponent(0.2)
        goldenBackground.layer.borderWidth = 1
        goldenBackground.layer.borderColor = UIColor.pro.cgColor
        goldenBackground.layer.cornerRadius = 8
        
        contentView.addSubview(goldenBackground)
        goldenBackground.pinToSuperview(edges: .vertical, padding: 3).pinToSuperview(edges: .horizontal, padding: 8)
        
        zapIcon.tintColor = .black
        let zapStack = UIStackView([zapIcon, zapAmountLabel])
        zapView.addSubview(zapStack)
        zapStack.centerToSuperview(axis: .vertical).pinToSuperview(edges: .trailing, padding: 8).pinToSuperview(edges: .leading, padding: 8)
        zapStack.alignment = .center
        zapView.backgroundColor = .gold
        zapView.layer.cornerRadius = 12
        
        let stack = UIStackView(axis: .horizontal, [userImage, userNameLabel, zapInfoLabel, zapView])
        stack.setCustomSpacing(8, after: userImage)
        stack.setCustomSpacing(4, after: userNameLabel)
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 8 + 3)
        
        contentView.addSubview(commentLabel)
        commentLabel
            .pinToSuperview(edges: .leading, padding: 52)
            .pinToSuperview(edges: .trailing, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 8 + 3)
        
        commentLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0).isActive = true
        
        commentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        zapInfoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        userNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        commentLabel.numberOfLines = 0
        commentLabel.enabledTextCheckingTypes = .link
        commentLabel.linkAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateForComment(_ comment: ParsedLiveComment) {
        contentView.backgroundColor = .background
        
        userImage.setUserImage(comment.user)
        userNameLabel.text = comment.user.data.firstIdentifier
        
        if comment.text.string.isEmpty {
            commentLabel.isHidden = true
            commentLabel.text = ""
        } else {
            commentLabel.isHidden = false
            commentLabel.attributedText = comment.text
        }
        
        zapAmountLabel.text = comment.zapAmount.localized()
    }
}
