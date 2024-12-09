//
//  ChatTableCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.9.23..
//

import UIKit
import Kingfisher
import FLAnimatedImage

final class ChatTableCell: UITableViewCell, Themeable {
    let profileImageView = UserImageView(height: 52)
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let separator = UIView().constrainToSize(width: 1)
    let newIndicator = UIView().constrainToSize(12)
    let messageLabel = UILabel()
    let borderView = UIView().constrainToSize(height: 1)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background2
        
        newIndicator.backgroundColor = .accent
        
        nameLabel.textColor = .foreground
        timeLabel.textColor = .foreground5
        separator.backgroundColor = .foreground5
        messageLabel.textColor = .foreground3
        
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize + 1, weight: .bold)
        timeLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize + 1, weight: .regular)
        messageLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize - 1, weight: .regular)
        
        borderView.backgroundColor = .background3
    }
    
    func setup(chat: Chat) {
        nameLabel.text = chat.user.data.firstIdentifier
        timeLabel.text = chat.latest.date.timeAgoDisplay()
        newIndicator.isHidden = chat.newMessagesCount == 0
        
        if chat.latest.user.data.id != chat.user.data.id {
            messageLabel.text = "You: \(chat.latest.message.text)"
        } else {
            messageLabel.text = chat.latest.message.text
        }
        
        profileImageView.setUserImage(chat.user)
    }
}

private extension ChatTableCell {
    func setup() {
        let nameStack = UIStackView([nameLabel, separator, timeLabel, newIndicator])
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        separator.pin(to: nameLabel, edges: .vertical)
        
        nameStack.spacing = 6
        nameStack.alignment = .center
        
        let vStack = UIStackView(axis: .vertical, [nameStack, messageLabel])
        let hStack = UIStackView([profileImageView, vStack])
        
        contentView.addSubview(hStack)
        hStack.pinToSuperview(edges: .vertical, padding: 12).pinToSuperview(edges: .horizontal, padding: 24)
        
        contentView.addSubview(borderView)
        borderView.pinToSuperview(edges: [.horizontal, .bottom])
        
        vStack.spacing = 4
        hStack.alignment = .center
        hStack.spacing = 12
        hStack.alignment = .top
    
        newIndicator.layer.cornerRadius = 6
        
        messageLabel.numberOfLines = 2
    }
}
