//
//  PostPreviewView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.5.23..
//

import UIKit
import Kingfisher

final class PostPreviewView: UIView {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let secondaryIdentifierLabel = UILabel()
    let verifiedBadge = UIImageView(image: UIImage(named: "feedVerifiedBadge"))
    let mainLabel = LinkableLabel()
    let seeMoreLabel = UILabel()
    let imageView = UIImageView()
    let linkPreview = LinkPreview()

    weak var imageAspectConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ content: ParsedContent) {
        let user = content.user.data
        
        nameLabel.text = user.firstIdentifier
        secondaryIdentifierLabel.text = user.nip05
        verifiedBadge.isHidden = user.nip05.isEmpty
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.kf.setImage(with: URL(string: user.picture), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 28, height: 28))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        if let image = content.imageResources.first {
            let aspectMultiplier: CGFloat = {
                guard let first = image.variants.first else { return 1 }
                return CGFloat(first.width) / CGFloat(first.height)
            }()
            
            imageAspectConstraint?.isActive = false
            let aspect = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectMultiplier)
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
            
            if imageView.frame.size.width > 10 {
                imageView.kf.setImage(with: image.url(for: .large), options: [
                    .processor(DownsamplingImageProcessor(size: .init(width: imageView.frame.width, height: imageView.frame.width / aspectMultiplier))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
            } else {
                imageView.kf.setImage(with: image.url(for: .large), options: [
                    .processor(DownsamplingImageProcessor(size: .init(width: 300, height: 300 / aspectMultiplier))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
            }
            
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
        
        if let data = content.parsedMetadata {
            linkPreview.data = data
            linkPreview.isHidden = false
        } else {
            linkPreview.isHidden = true
        }
        
        mainLabel.attributedText = content.attributedText
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
    }
}

private extension PostPreviewView {
    func setup() {
        backgroundColor = .background4
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.background3.cgColor
        
        let separatorLabel = UILabel()
        separatorLabel.text = "|"
        [timeLabel, separatorLabel, secondaryIdentifierLabel].forEach {
            $0.font = .appFont(withSize: 16, weight: .regular)
            $0.textColor = .foreground3
            $0.adjustsFontSizeToFitWidth = true
        }
        
        profileImageView.constrainToSize(28)
        profileImageView.layer.cornerRadius = 14
        profileImageView.layer.masksToBounds = true
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont.appFont(withSize: 16, weight: .regular)
        mainLabel.numberOfLines = 10
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: 16, weight: .regular)
        seeMoreLabel.textColor = .accent
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isHidden = true
        
        let nameTimeStack = UIStackView(arrangedSubviews: [
            profileImageView, nameLabel, verifiedBadge, secondaryIdentifierLabel,
            SpacerView(width: 0), separatorLabel, SpacerView(width: 0), timeLabel, UIView()
        ])
        nameTimeStack.spacing = 4
        nameTimeStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [
            nameTimeStack, mainLabel, seeMoreLabel, SpacerView(height: 12), imageView, linkPreview
        ])
        mainStack.axis = .vertical
        mainStack.setCustomSpacing(12, after: nameTimeStack)
        mainStack.setCustomSpacing(12, after: imageView)
        addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .vertical, padding: 16)
        
        // USER INTERACTION DISABLED FOR SUBVIEWS
        mainStack.isUserInteractionEnabled = false
    }
}
