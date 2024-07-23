//
//  FeedCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Kingfisher

class FeedCell: PostCell {
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    let threeDotsSpacer = SpacerView(width: 20)
    lazy var mainStack = UIStackView(arrangedSubviews: [repostIndicator])
    
    override var useShortText: Bool { true }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !(mainLabel.isTruncated() || (mainLabel.attributedText?.length ?? 0) == 1000)
        
        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted == nil ? .identity : .init(translationX: 0, y: -6)
    }
    
    func parentSetup() {        
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
    }
}

// MARK: - DefaultFeedCell

final class DefaultFeedCell: FeedCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DefaultFeedCell {
    func setup() {
        let buttonStackStandIn = UIView()
        let contentStack = UIStackView(axis: .vertical, [
            nameStack, replyingToView, textStack, invoiceView, articleView, mainImages, linkPresentation, postPreview, SpacerView(height: 0), buttonStackStandIn
        ])
        
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, contentStack])
        
        mainStack.addArrangedSubview(horizontalStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 12)
        mainStack.setCustomSpacing(7, after: repostIndicator)
        
        contentStack.spacing = 8
        
        buttonStackStandIn.constrainToSize(height: 24)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack.pin(to: buttonStackStandIn, edges: .horizontal, padding: -8).centerToView(buttonStackStandIn)
        
        horizontalStack.alignment = .top
        horizontalStack.spacing = 12
    }
}

// MARK: - FullWidthFeedCell

final class FullWidthFeedCell: FeedCell {
    lazy var nameReplyStack = UIStackView(axis: .vertical, [nameStack, replyingToView])
    lazy var nameSuperStack = UIStackView([profileImageView, nameReplyStack])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        
        nameSuperStack.alignment = parsedContent.replyingTo != nil ? .top : .center
        
        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -6) : (parsedContent.replyingTo == nil ? .init(translationX: 0, y: 4) : .identity)
    }
}

private extension FullWidthFeedCell {
    func setup() {
        let buttonStackStandIn = UIView()
        let contentStack = UIStackView(axis: .vertical, [
            nameSuperStack, textStack, invoiceView, mainImages, linkPresentation, postPreview, buttonStackStandIn
        ])
    
        mainStack.addArrangedSubview(contentStack)
        mainStack.pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .horizontal, padding: 16)
        
        contentStack.spacing = 8
        nameReplyStack.spacing = 4
        nameSuperStack.spacing = 8
        
        buttonStackStandIn.constrainToSize(height: 24)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack.pin(to: buttonStackStandIn, edges: .horizontal, padding: -8).centerToView(buttonStackStandIn)
    }
}

