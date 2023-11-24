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
    let mainImages = ImageCollectionView()
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
        secondaryIdentifierLabel.text = user.parsedNip
        verifiedBadge.isHidden = user.nip05.isEmpty
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.kf.setImage(with: URL(string: user.picture), placeholder: UIImage(named: "Profile"), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 28, height: 28))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        imageAspectConstraint?.isActive = false
        if let first = content.mediaResources.first?.variants.first {
            let aspect = mainImages.widthAnchor.constraint(equalTo: mainImages.heightAnchor, multiplier: CGFloat(first.width) / CGFloat(first.height))
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        } else {
            let url = content.mediaResources.first?.url
            
            let multiplier: CGFloat = url?.isVideoButNotYoutube == true ? (9 / 16) : (url?.isYoutubeVideo == true ? 0.8 : 1)
            
            let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: multiplier)
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        }
        
        mainImages.resources = content.mediaResources
        mainImages.thumbnails = content.videoThumbnails
        mainImages.isHidden = content.mediaResources.isEmpty
        
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
        
        mainImages.layer.masksToBounds = true
        mainImages.layer.cornerRadius = 8
        mainImages.isHidden = true
        mainImages.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        
        let nameTimeStack = UIStackView(arrangedSubviews: [
            profileImageView, nameLabel, verifiedBadge, secondaryIdentifierLabel,
            SpacerView(width: 0), separatorLabel, SpacerView(width: 0), timeLabel, UIView()
        ])
        nameTimeStack.spacing = 4
        nameTimeStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [
            nameTimeStack, mainLabel, seeMoreLabel, SpacerView(height: 6), mainImages, linkPreview
        ])
        mainStack.axis = .vertical
        mainStack.setCustomSpacing(6, after: nameTimeStack)
        mainStack.setCustomSpacing(6, after: mainImages)
        addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 12)
        
        // USER INTERACTION DISABLED FOR SUBVIEWS
        mainStack.isUserInteractionEnabled = false
    }
}
