//
//  CompactArticleView.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.7.24..
//

import UIKit
import FLAnimatedImage
import Kingfisher

class CompactArticleView: UIView, Themeable {
    let avatar = UserImageView(height: 20)
    let nameLabel = UILabel()
    let dot = UIView().constrainToSize(3)
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    let durationLabel = UILabel()
    
    let contentImageView = UIImageView().constrainToSize(width: 100)
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUp(_ content: Article) {
        updateTheme()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        titleLabel.attributedText = NSAttributedString(string: content.title, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.appFont(withSize: 16, weight: .heavy),
            .foregroundColor: UIColor.foreground
        ])
        
        let imageURL: URL? = {
            if let image = content.image { return URL(string: image) }
            return content.user.profileImage.url(for: .medium)
        }()
        
        if let imageURL {
            contentImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(named: "longFormPlaceholderImage"),
                options: [
                    .scaleFactor(3),
                    .processor(DownsamplingImageProcessor(size: .init(width: 88, height: 48))),
                    .cacheOriginalImage
                ]
            )
        } else {
            contentImageView.kf.cancelDownloadTask()
            contentImageView.image = UIImage(named: "longFormPlaceholderImage")
        }
        
        timeLabel.text = Date(timeIntervalSince1970: content.event.created_at).timeAgoDisplayLong()
        avatar.setUserImage(content.user)
        nameLabel.text = content.user.data.firstIdentifier
        
        if let words = content.words {
            durationLabel.text = "\(1 + (words / 200)) min read"
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground
        timeLabel.textColor = .foreground4
        dot.backgroundColor = .foreground4
        
        contentImageView.layer.borderColor = UIColor.foreground6.cgColor
        
        titleLabel.textColor = .foreground
        durationLabel.textColor = .foreground4
        
        backgroundColor = .background4
    }
}

private extension CompactArticleView {
    func setup() {
        let firstRow = UIStackView([avatar, nameLabel, dot, timeLabel, UIView()])
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        firstRow.alignment = .center
        firstRow.spacing = 4
        firstRow.setCustomSpacing(8, after: avatar)
        dot.layer.cornerRadius = 1.5
        
        layer.cornerRadius = 8
        
        let durationTitleStack = UIStackView(axis: .vertical, [titleLabel, durationLabel])
        durationTitleStack.spacing = 4
        
        let contentStack = UIStackView([durationTitleStack, contentImageView])
        contentStack.spacing = 12
        contentStack.alignment = .top
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, contentStack])
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 12).pinToSuperview(edges: .top, padding: 10)
        
        nameLabel.font = .appFont(withSize: 14, weight: .bold)
        timeLabel.font = .appFont(withSize: 14, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 16, weight: .heavy)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        
        durationLabel.font = .appFont(withSize: 14, weight: .regular)
        
        contentImageView.layer.borderWidth = 1
        contentImageView.layer.cornerRadius = 4
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        contentImageView.constrainToSize(width: 88, height: 48)
    }
}
