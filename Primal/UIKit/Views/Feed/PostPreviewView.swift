//
//  PostPreviewView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.5.23..
//

import UIKit
import Kingfisher
import Nantes

final class PostPreviewView: UIView {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let secondaryIdentifierLabel = UILabel()
    let verifiedBadge = VerifiedView()
    let mainLabel = NantesLabel()
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
        
        profileImageView.kf.setImage(with: URL(string: user.picture), placeholder: UIImage(named: "Profile"), options: [
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
        
        if let data = content.linkPreview {
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
        separatorLabel.text = "·"
        [timeLabel, separatorLabel, secondaryIdentifierLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }
        
        [nameLabel, secondaryIdentifierLabel, separatorLabel].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        secondaryIdentifierLabel.lineBreakMode = .byTruncatingTail
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        secondaryIdentifierLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        profileImageView.constrainToSize(24)
        profileImageView.layer.cornerRadius = 12
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        verifiedBadge.constrainToSize(FontSizeSelection.current.contentFontSize)
        
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        mainLabel.numberOfLines = 10
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
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
            nameTimeStack, mainLabel, seeMoreLabel, SpacerView(height: 6), imageView, linkPreview
        ])
        mainStack.axis = .vertical
        mainStack.setCustomSpacing(6, after: nameTimeStack)
        mainStack.setCustomSpacing(6, after: imageView)
        addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 12)
        
        // USER INTERACTION DISABLED FOR SUBVIEWS
        mainStack.isUserInteractionEnabled = false
    }
}
