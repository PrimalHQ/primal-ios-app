//
//  ArticleFeedView.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.7.24..
//

import UIKit
import FLAnimatedImage
import Kingfisher

class ArticleFeedView: UIView, Themeable {
    let avatar = UserImageView(height: 20)
    let nameLabel = UILabel()
    let dot = UIView().constrainToSize(3)
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    let durationLabel = UILabel()
    let commentIcon = UIImageView(image: UIImage(named: "longFormReplies"))
    let commentLabel = UILabel()
    let zapIcon = UIImageView(image: UIImage(named: "longFormZapIcon"))
    let zapView = UserGalleryView()
    let contentImageView = UIImageView().constrainToSize(width: 100, height: 72)
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUp(_ content: Article) {
        updateTheme()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        titleLabel.attributedText = NSAttributedString(string: content.title, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.appFont(withSize: 22, weight: .heavy),
            .foregroundColor: UIColor.foreground
        ])
        
        if let words = content.words {
            durationLabel.text = "\(1 + (words / 200)) min read"
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        
        let imageURL: URL? = {
            if let image = content.image { return URL(string: image) }
            return content.user.profileImage.url(for: .medium)
        }()
        
        if let imageURL {
            contentImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "longFormPlaceholderImage"), options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .processor(ResizingImageProcessor(referenceSize: .init(width: 100, height: 72)))
            ])
        } else {
            contentImageView.kf.cancelDownloadTask()
            contentImageView.image = UIImage(named: "longFormPlaceholderImage")
        }
        
        timeLabel.text = Date(timeIntervalSince1970: content.event.created_at).timeAgoDisplayLong()
        avatar.setUserImage(content.user)
        nameLabel.text = content.user.data.firstIdentifier
        if let replies = content.stats.replies {
            commentLabel.text = "\(replies) comments"
        } else {
            commentLabel.text = ""
        }
        
        if content.zaps.isEmpty {
            zapIcon.isHidden = true
            zapView.isHidden = true
        } else {
            zapIcon.isHidden = false
            zapView.isHidden = false
            zapView.users = content.zaps.map { $0.user }
        }
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground2
        timeLabel.textColor = .foreground4
        dot.backgroundColor = .foreground4
        durationLabel.textColor = .foreground2
        commentIcon.tintColor = .foreground2
        commentLabel.textColor = .foreground2
        zapIcon.tintColor = .foreground2
        
        contentImageView.layer.borderColor = UIColor.foreground6.cgColor
        
        titleLabel.textColor = .foreground
        
        backgroundColor = .background4
    }
}

private extension ArticleFeedView {
    func setup() {
        let firstRow = UIStackView([avatar, nameLabel, dot, timeLabel, UIView()])
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        firstRow.alignment = .center
        firstRow.spacing = 4
        firstRow.setCustomSpacing(8, after: avatar)
        dot.layer.cornerRadius = 1.5
        
        layer.cornerRadius = 8
        
        let contentStack = UIStackView([titleLabel, contentImageView])
        contentStack.spacing = 12
        contentStack.alignment = .top
        
        let botStack = UIStackView([durationLabel, commentIcon, commentLabel, UIView(), zapIcon, zapView])
        botStack.setCustomSpacing(16, after: durationLabel)
        botStack.setCustomSpacing(4, after: commentIcon)
        botStack.setCustomSpacing(9, after: zapIcon)
        botStack.alignment = .center
        botStack.constrainToSize(height: 22)
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, contentStack, botStack])
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 12).pinToSuperview(edges: .top, padding: 10)
        
        nameLabel.font = .appFont(withSize: 14, weight: .bold)
        timeLabel.font = .appFont(withSize: 14, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 22, weight: .heavy)
        durationLabel.font = .appFont(withSize: 15, weight: .regular)
        commentLabel.font = .appFont(withSize: 14, weight: .regular)
        
        titleLabel.numberOfLines = 5
        
        contentImageView.layer.borderWidth = 1
        contentImageView.layer.cornerRadius = 8
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
    }
}
