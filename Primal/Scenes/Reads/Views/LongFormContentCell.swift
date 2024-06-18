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
    let commentIcon = UIImageView(image: UIImage(named: "longFormReplies"))
    let commentLabel = UILabel()
    let zapIcon = UIImageView(image: UIImage(named: "longFormZapIcon"))
    let zapView = UserGalleryView()
    let contentImageView = UIImageView().constrainToSize(width: 100)
    let border = UIView().constrainToSize(height: 1)
    
    let threeDotsButton = UIButton(configuration: .simpleImage(UIImage(named: "threeDots")))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUp(_ content: ParsedLongFormPost) {
        updateTheme()
        
        titleLabel.text = content.title
        
        if let words = content.words {
            durationLabel.text = "\(1 + (words / 200)) min read"
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        
        NSLayoutConstraint.deactivate(contentImageView.constraints)
        let height = contentImageView.heightAnchor.constraint(equalToConstant: 72)
        height.priority = .defaultLow
        NSLayoutConstraint.activate([
            contentImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 144),
            contentImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            contentImageView.widthAnchor.constraint(equalToConstant: 100),
            height
        ])
        if let image = content.image {
            contentImageView.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "longFormPlaceholderImage")) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let value):
                    let image = value.image
                    
                    let imageAspectRatio = image.size.width / image.size.height
                                        
                    let aspectC = contentImageView.widthAnchor.constraint(equalTo: contentImageView.heightAnchor, multiplier: imageAspectRatio)
                    aspectC.priority = .defaultHigh
                    aspectC.isActive = true
                case .failure(let error):
                    print(error) // Handle the error if needed
                }
            }
        } else {
            contentImageView.kf.cancelDownloadTask()
            contentImageView.image = UIImage(named: "longFormPlaceholderImage")
        }
        
        timeLabel.text = Date(timeIntervalSince1970: content.event.created_at).timeAgoDisplayLong()
        avatar.setUserImage(content.user)
        nameLabel.text = content.user.data.firstIdentifier
        commentLabel.text = "\(content.stats.replies) comments"
        
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
        timeLabel.textColor = .foreground2
        dot.backgroundColor = .foreground2
        threeDotsButton.tintColor = .foreground2
        durationLabel.textColor = .foreground2
        commentIcon.tintColor = .foreground2
        commentLabel.textColor = .foreground2
        zapIcon.tintColor = .foreground2
        
        border.backgroundColor = .background3
        
        contentImageView.layer.borderColor = UIColor.background3.cgColor
        
        titleLabel.textColor = .foreground
    }
}

private extension LongFormContentCell {
    func setup() {
        selectionStyle = .none
        
        let firstRow = UIStackView([avatar, nameLabel, dot, timeLabel, UIView(), threeDotsButton])
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        firstRow.alignment = .center
        firstRow.spacing = 4
        firstRow.setCustomSpacing(8, after: avatar)
        dot.layer.cornerRadius = 1.5
        
        let contentStack = UIStackView([titleLabel, contentImageView])
        contentStack.spacing = 12
        contentStack.alignment = .top
        
        let botStack = UIStackView([durationLabel, commentIcon, commentLabel, UIView(), zapIcon, zapView])
        botStack.setCustomSpacing(16, after: durationLabel)
        botStack.setCustomSpacing(4, after: commentIcon)
        botStack.setCustomSpacing(9, after: zapIcon)
        botStack.alignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, contentStack, botStack])
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 12)
        
        avatar.layer.cornerRadius = 11
        avatar.layer.masksToBounds = true
        avatar.contentMode = .scaleAspectFill
        
        nameLabel.font = .appFont(withSize: 15, weight: .regular)
        timeLabel.font = .appFont(withSize: 15, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 20, weight: .heavy)
        durationLabel.font = .appFont(withSize: 15, weight: .regular)
        commentLabel.font = .appFont(withSize: 15, weight: .regular)
        
        titleLabel.numberOfLines = 5
        
        contentImageView.layer.borderWidth = 1
        contentImageView.layer.cornerRadius = 4
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
    }
}
