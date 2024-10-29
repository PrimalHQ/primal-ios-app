//
//  PostPreviewPostPreviewView.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.10.24..
//

import UIKit
import Kingfisher
import Nantes
import FLAnimatedImage

final class PostPreviewPostPreviewView: UIView {
    let profileImageView = FLAnimatedImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let secondaryIdentifierLabel = UILabel()
    let verifiedBadge = VerifiedView()
    let mainLabel = NantesLabel()
    let seeMoreLabel = UILabel()
    let invoiceView = LightningInvoiceView()
    let mainImages = ImageGalleryView()
    let linkPreview = LinkPreview()
    let infoView = SimpleInfoView()

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
        
        if CheckNip05Manager.instance.isVerified(user) {
            secondaryIdentifierLabel.text = user.parsedNip
            secondaryIdentifierLabel.isHidden = false
            verifiedBadge.isHidden = false
            verifiedBadge.isExtraVerified = user.nip05.hasSuffix("@primal.net")
        } else {
            secondaryIdentifierLabel.isHidden = true
            verifiedBadge.isHidden = true
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.setUserImage(content.user, size: .init(width: 24, height: 24))
        
        imageAspectConstraint?.isActive = false
        if let first = content.mediaResources.first?.variants.first {
            let aspect = mainImages.widthAnchor.constraint(equalTo: mainImages.heightAnchor, multiplier: CGFloat(first.width) / CGFloat(first.height))
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        } else {
            let url = content.mediaResources.first?.url
            
            let multiplier: CGFloat = url?.isVideoURL == true ? 9 / 16 : 1
            
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
        
        if let invoice = content.invoice {
            invoiceView.updateForInvoice(invoice)
            invoiceView.isHidden = false
        } else {
            invoiceView.isHidden = true
        }
        
        mainLabel.attributedText = content.attributedText
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
        
        if let customEvent = content.customEvent {
            infoView.isHidden = false
            infoView.set(
                kind: .file,
                text: customEvent.post.tags.first(where: { $0.first == "alt" })?[safe: 1] ??
                        (customEvent.post.content.isEmpty ? "Unknown reference" : customEvent.post.content)
            )
        } else {
            switch content.notFound {
            case nil:
                infoView.isHidden = true
            case .note:
                infoView.isHidden = false
                infoView.set(kind: .file, text: "Mentioned note not found.")
            case .article:
                infoView.isHidden = false
                infoView.set(kind: .file, text: "Mentioned article not found.")
            }
        }
    }
}

private extension PostPreviewPostPreviewView {
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
        
        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        mainLabel.numberOfLines = 6
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
            nameTimeStack, mainLabel, seeMoreLabel, SpacerView(height: 6), invoiceView, mainImages, linkPreview, infoView
        ])
        mainStack.axis = .vertical
        mainStack.setCustomSpacing(6, after: nameTimeStack)
        mainStack.setCustomSpacing(6, after: mainImages)
        mainStack.setCustomSpacing(6, after: linkPreview)
        addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 12)
        
        // USER INTERACTION DISABLED FOR SUBVIEWS (except for images)
        for subview in mainStack.arrangedSubviews {
            subview.isUserInteractionEnabled = subview == mainImages
        }
    }
}
