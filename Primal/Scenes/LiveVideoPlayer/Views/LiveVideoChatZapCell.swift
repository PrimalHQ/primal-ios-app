//
//  LiveVideoChatZapCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit
import Nantes

class LiveVideoChatZapCell: UITableViewCell {
    
    let view = LiveVideoChatZapView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(view)
        view.pinToSuperview(edges: .vertical, padding: 3).pinToSuperview(edges: .horizontal, padding: 8)
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
 
    func updateForComment(_ comment: ParsedLiveComment, delegate: NantesLabelDelegate?) {
        contentView.backgroundColor = .background
        
        view.updateForComment(comment)
        view.commentLabel.delegate = delegate
    }
}


class LiveVideoChatZapView: UIView {
    let userImage = UserImageView(height: 24)
    let userNameLabel = UILabel("", color: .gold, font: .appFont(withSize: 16, weight: .bold))
    let zapInfoLabel = UILabel("zapped", color: .gold, font: .appFont(withSize: 16, weight: .regular))
    let zapAmountLabel = UILabel("", color: .black, font: .appFont(withSize: 16, weight: .bold))
    let zapView = UIView().constrainToSize(height: 24)
    let zapIcon = UIImageView(image: .topZapGalleryIcon)
    let commentLabel = NantesLabel()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .pro.withAlphaComponent(0.2)
        layer.borderWidth = 1
        layer.borderColor = UIColor.pro.cgColor
        layer.cornerRadius = 8
        
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
        
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .top, padding: 8)
        
        addSubview(commentLabel)
        commentLabel
            .pinToSuperview(edges: .leading, padding: 44)
            .pinToSuperview(edges: .trailing, padding: 12)
            .pinToSuperview(edges: .bottom, padding: 8)
        
        commentLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0).isActive = true
        
        commentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        zapInfoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        userNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        commentLabel.numberOfLines = 0
        commentLabel.enabledTextCheckingTypes = .link
        commentLabel.linkAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForComment(_ comment: ParsedLiveComment) {
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
