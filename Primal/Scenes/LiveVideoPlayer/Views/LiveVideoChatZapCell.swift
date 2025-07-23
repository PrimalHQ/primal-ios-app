//
//  LiveVideoChatZapCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit

class LiveVideoChatZapCell: UITableViewCell {
    let userImage = UserImageView(height: 24)
    let userNameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let verified = VerifiedView().constrainToSize(13)
    let zapInfoLabel = UILabel()
    let commentLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.backgroundColor = .background
        
        let goldenBackground = UIView()
        goldenBackground.backgroundColor = .pro.withAlphaComponent(0.2)
        goldenBackground.layer.borderWidth = 1
        goldenBackground.layer.borderColor = UIColor.pro.cgColor
        goldenBackground.layer.cornerRadius = 8
        
        contentView.addSubview(goldenBackground)
        goldenBackground.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 8)
        
        let stack = UIStackView(axis: .horizontal, [userImage, userNameLabel, verified, zapInfoLabel])
        stack.setCustomSpacing(8, after: userImage)
        stack.setCustomSpacing(4, after: userNameLabel)
        stack.setCustomSpacing(4, after: verified)
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 5)
        
        contentView.addSubview(commentLabel)
        commentLabel
            .pinToSuperview(edges: .leading, padding: 52)
            .pinToSuperview(edges: .trailing, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 5)
        
        commentLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0).isActive = true
        
        commentLabel.numberOfLines = 0
        commentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        zapInfoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        userNameLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateForComment(_ comment: ParsedLiveComment) {
        userImage.setUserImage(comment.user)
        userNameLabel.text = comment.user.data.firstIdentifier
        verified.user = comment.user.data
        
        if comment.text.isEmpty {
            commentLabel.isHidden = true
        } else {
            commentLabel.isHidden = false
            commentLabel.attributedText = .init(string: comment.text, attributes: [
                .foregroundColor: UIColor.foreground3,
                .font: UIFont.appFont(withSize: 15, weight: .regular)
            ])
        }
        
        let zapText = NSMutableAttributedString(string: "zapped ", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground
        ])
        zapText.append(.init(string: "\(comment.zapAmount.localized()) sats", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .bold),
            .foregroundColor: UIColor.foreground
        ]))
        zapInfoLabel.attributedText = zapText
    }
}
