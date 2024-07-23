//
//  CompactArticleView.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.7.24..
//

import UIKit
import FLAnimatedImage

class CompactArticleView: UIView, Themeable {
    let avatar = FLAnimatedImageView().constrainToSize(20)
    let nameLabel = UILabel()
    let dot = UIView().constrainToSize(3)
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    
    let contentImageView = UIImageView().constrainToSize(width: 100)
    
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
        
        
        NSLayoutConstraint.deactivate(contentImageView.constraints)
        let height = contentImageView.heightAnchor.constraint(equalToConstant: 72)
        height.priority = .defaultLow
        NSLayoutConstraint.activate([
            contentImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 144),
            contentImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            contentImageView.widthAnchor.constraint(equalToConstant: 100),
            height
        ])
        
        let imageURL: URL? = {
            if let image = content.image { return URL(string: image) }
            return content.user.profileImage.url(for: .medium)
        }()
        
        if let imageURL {
            contentImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "longFormPlaceholderImage")) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let value):
                    let image = value.image
                    
                    let imageAspectRatio = image.size.width / image.size.height
                                        
                    let aspectC = contentImageView.widthAnchor.constraint(equalTo: contentImageView.heightAnchor, multiplier: imageAspectRatio)
                    aspectC.priority = .defaultLow
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
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground2
        timeLabel.textColor = .foreground4
        dot.backgroundColor = .foreground4
        
        contentImageView.layer.borderColor = UIColor.foreground6.cgColor
        
        titleLabel.textColor = .foreground
        
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
        
        let contentStack = UIStackView([titleLabel, contentImageView])
        contentStack.spacing = 12
        contentStack.alignment = .top
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, contentStack])
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 12).pinToSuperview(edges: .top, padding: 10)
        
        avatar.layer.cornerRadius = 10
        avatar.layer.masksToBounds = true
        avatar.contentMode = .scaleAspectFill
        
        nameLabel.font = .appFont(withSize: 14, weight: .bold)
        timeLabel.font = .appFont(withSize: 14, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 22, weight: .heavy)
        
        titleLabel.numberOfLines = 5
        
        contentImageView.layer.borderWidth = 1
        contentImageView.layer.cornerRadius = 4
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
    }
}
