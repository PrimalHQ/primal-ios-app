//
//  LongFormContentCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.5.24..
//

import UIKit
import FLAnimatedImage

class LongFormContentCell: UITableViewCell, Themeable {
    let avatar = FLAnimatedImageView().constrainToSize(22)
    let nameLabel = UILabel()
    let dot = UIView().constrainToSize(3)
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    let durationLabel = UILabel()
    let contentImageView = UIImageView().constrainToSize(width: 100, height: 72)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUp(_ content: ParsedLongFormPost) {
        updateTheme()
        
        titleLabel.text = content.title
        
        if let words = content.words {
            durationLabel.text = "\(words / 200) min read"
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        
        if let image = content.image {
            contentImageView.kf.setImage(with: URL(string: image), placeholder: nil)
            contentImageView.isHidden = false
        } else {
            contentImageView.isHidden = true
        }
        
        timeLabel.text = Date(timeIntervalSince1970: content.event.created_at).timeAgoDisplayLong()
        avatar.setUserImage(content.user)
        nameLabel.text = content.user.data.firstIdentifier
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground2
        timeLabel.textColor = .foreground2
        dot.backgroundColor = .foreground2
        
        titleLabel.textColor = .foreground
        durationLabel.textColor = .foreground4
    }
}

private extension LongFormContentCell {
    func setup() {
        selectionStyle = .none
        
        let firstRow = UIStackView([avatar, nameLabel, dot, timeLabel])
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        firstRow.alignment = .center
        firstRow.spacing = 4
        firstRow.setCustomSpacing(8, after: avatar)
        dot.layer.cornerRadius = 1.5
        
        let titleStack = UIStackView(axis: .vertical, [titleLabel, durationLabel])
        titleStack.spacing = 8
        
        let contentStack = UIStackView([titleStack, contentImageView])
        contentStack.spacing = 12
        contentStack.alignment = .top
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, contentStack])
        mainStack.spacing = 4
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 12)
        
        avatar.layer.cornerRadius = 11
        avatar.layer.masksToBounds = true
        avatar.contentMode = .scaleAspectFill
        
        nameLabel.font = .appFont(withSize: 15, weight: .regular)
        timeLabel.font = .appFont(withSize: 15, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 17, weight: .heavy)
        durationLabel.font = .appFont(withSize: 15, weight: .regular)
        
        contentImageView.layer.cornerRadius = 4
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
    }
}
