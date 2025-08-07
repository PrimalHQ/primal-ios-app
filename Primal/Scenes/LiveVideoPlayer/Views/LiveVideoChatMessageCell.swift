//
//  LiveVideoChatMessageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit
import Nantes

class LiveVideoChatMessageCell: UITableViewCell {
    let userImage = UserImageView(height: 24)
    let userNameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let commentLabel = NantesLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(axis: .horizontal, [userImage, userNameLabel])
        stack.setCustomSpacing(8, after: userImage)
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 5)
        
        contentView.addSubview(commentLabel)
        commentLabel
            .pinToSuperview(edges: .leading, padding: 52)
            .pinToSuperview(edges: .trailing, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 7)
            .pinToSuperview(edges: .top, padding: 1)
        
        commentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        commentLabel.numberOfLines = 0
        commentLabel.enabledTextCheckingTypes = .link
        commentLabel.linkAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateForComment(_ comment: ParsedLiveComment) {
        contentView.backgroundColor = .background
        
        userImage.setUserImage(comment.user)
        userNameLabel.text = comment.user.data.firstIdentifier
        let text = NSMutableAttributedString(string: comment.user.data.firstIdentifier, attributes: [
            .foregroundColor: UIColor.clear,
            .font: UIFont.appFont(withSize: 16, weight: .bold)
        ])
        text.append(.init(string: "|", attributes: [  // We need this to be larger so that emojis don't change the height
            .foregroundColor: UIColor.clear,
            .font: UIFont.appFont(withSize: 22, weight: .regular)
        ]))
        text.append(.init(string: comment.text, attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular)
        ]))
        
        commentLabel.attributedText = text
    }
}
