//
//  NewFeedCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.5.24..
//

import UIKit
import Kingfisher

class NewFeedCell: PostCell {
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    let threeDotsSpacer = SpacerView(width: 20)
    lazy var mainStack = UIStackView(arrangedSubviews: [repostIndicator])
    
    override var useShortText: Bool { true }
    
    lazy var nameReplyStack = UIStackView(axis: .vertical, [nameStack, replyingToView])
    lazy var nameSuperStack = UIStackView([profileImageView, nameReplyStack])
    
    // MARK: - State
    var lastContentId: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        if parsedContent.post.id != lastContentId {
            zapGallery.zaps = []
            lastContentId = parsedContent.post.id
        }
        
        super.update(parsedContent)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !(mainLabel.isTruncated() || (mainLabel.attributedText?.length ?? 0) == 1000)
        
        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted == nil ? .identity : .init(translationX: 0, y: -6)
        
        nameSuperStack.alignment = parsedContent.replyingTo != nil ? .top : .center
        
        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -6) : (parsedContent.replyingTo == nil ? .init(translationX: 0, y: 4) : .identity)
    }
    
    override func updateMenu(_ content: ParsedContent) {
        super.updateMenu(content)
        
        if content.zaps.isEmpty {
            zapGallery.isHidden = true
            zapGallery.zaps = []
        } else {
            zapGallery.isHidden = false
            zapGallery.zaps = content.zaps
        }
    }
}

private extension NewFeedCell {
    func setup() {
        textStack.axis = .vertical
        textStack.spacing = FontSizeSelection.current.contentLineSpacing
        
        mainLabel.numberOfLines = 20
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        mainLabel.setContentHuggingPriority(.required, for: .vertical)
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        seeMoreLabel.textColor = .accent
        seeMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        zapGallery.singleLine = true
        
        contentView.addSubview(mainStack)
    
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        contentView.addSubview(threeDotsButton)
        threeDotsButton.pinToSuperview(edges: [.top, .trailing]).constrainToSize(44)
        
        nameStack.addArrangedSubview(threeDotsSpacer)
        
        mainStack.axis = .vertical
        mainStack.spacing = 14
        
        profileImageView.constrainToSize(FontSizeSelection.current.avatarSize)
        profileImageView.layer.cornerRadius = FontSizeSelection.current.avatarSize / 2
    
        let buttonStackStandIn = UIView()
        let contentStack = UIStackView(axis: .vertical, [
            nameSuperStack, textStack, invoiceView, articleView, mainImages, linkPresentation, postPreview, zapGallery, buttonStackStandIn
        ])
    
        mainStack.addArrangedSubview(contentStack)
        mainStack.pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .horizontal, padding: 16)
        
        contentStack.spacing = 8
        nameReplyStack.spacing = 4
        nameSuperStack.spacing = 8
        
        buttonStackStandIn.constrainToSize(height: 24)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .pin(to: buttonStackStandIn, edges: .leading, padding: -8)
            .pin(to: buttonStackStandIn, edges: .trailing, padding: 16)
            .centerToView(buttonStackStandIn, axis: .vertical)
        
        bottomButtonStack.distribution = .fillEqually
        
        contentView.addSubview(bookmarkButton)
        bookmarkButton
            .pin(to: buttonStackStandIn, edges: .trailing, padding: -2)
            .centerToView(buttonStackStandIn, axis: .vertical)
    }
}


