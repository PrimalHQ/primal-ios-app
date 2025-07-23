//
//  LiveVideoChatMessageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit

class LiveVideoChatMessageCell: UITableViewCell {
    let userImage = UserImageView(height: 24)
    let userNameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let verified = VerifiedView().constrainToSize(13)
    let commentLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.backgroundColor = .background
        contentView.addSubview(commentLabel)
        
        let stack = UIStackView(axis: .horizontal, [userImage, userNameLabel, verified, UIView()])
        stack.setCustomSpacing(8, after: userImage)
        stack.setCustomSpacing(4, after: userNameLabel)
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 5)
        
        commentLabel.numberOfLines = 0
        commentLabel
            .pinToSuperview(edges: .leading, padding: 52)
            .pinToSuperview(edges: .trailing, padding: 20)
            .pinToSuperview(edges: .vertical, padding: 7)
        
        commentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateForComment(_ comment: ParsedLiveComment) {
        userImage.setUserImage(comment.user)
        userNameLabel.text = comment.user.data.firstIdentifier
        verified.user = comment.user.data
        
        let text = NSMutableAttributedString(string: "\(comment.user.data.firstIdentifier) \(verified.isHidden ? "" : " iii ")", attributes: [
            .foregroundColor: UIColor.background,
            .font: UIFont.appFont(withSize: 16, weight: .bold)
        ])
        text.append(.init(string: comment.text, attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular)
        ]))
        
        commentLabel.attributedText = text
    }
}
