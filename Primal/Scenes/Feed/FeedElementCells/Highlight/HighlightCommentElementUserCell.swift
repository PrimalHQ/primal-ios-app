//
//  HighlightCommentElementUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.12.24..
//

import UIKit

class HighlightCommentElementUserCell: FeedElementBaseCell, RegularFeedElementCell {    
    static var cellID: String { "HighlightCommentElementUserCell" }
    
    let profileImageView = UserImageView(height: 30)
    let checkbox = VerifiedView().constrainToSize(FontSizeSelection.current.contentFontSize)
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let commentedLabel = UILabel()
        commentedLabel.font = .appFont(withSize: 15, weight: .regular)
        commentedLabel.textColor = .foreground
        commentedLabel.text = "commented:"
        
        let nameStack = UIStackView([profileImageView, nameLabel, checkbox, commentedLabel, UIView(), timeLabel])
        nameStack.spacing = 4
        nameStack.alignment = .center
        
        contentView.addSubview(nameStack)
        nameStack
            .pinToSuperview(edges: .top, padding: 12)
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .bottom)
        
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        profileImageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .profile)
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ parsedContent: ParsedContent) {
        let user = parsedContent.user.data
        
        nameLabel.text = user.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user) {
            checkbox.user = user
        } else {
            checkbox.isHidden = true
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(parsedContent.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.setUserImage(parsedContent.user)
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)
        
        [timeLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }
    }
}
