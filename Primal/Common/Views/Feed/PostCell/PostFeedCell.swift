//
//  PostFeedCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.5.24..
//

import UIKit
import Kingfisher

class PostFeedCell: PostCell {
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    let threeDotsSpacer = SpacerView(width: 20)
    lazy var mainStack = UIStackView(arrangedSubviews: [repostIndicator])
    
    let repostedByOverlayButton = UIButton()
    
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
            zapGallery?.setZaps([])
            lastContentId = parsedContent.post.id
        }
        
        super.update(parsedContent)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        
        mainLabel.numberOfLines = (parsedContent.mediaResources.isEmpty && parsedContent.linkPreviews.isEmpty && parsedContent.embeddedPosts.isEmpty) ? 12 : 6
        
        seeMoreLabel.isHidden = !(mainLabel.isTruncated() || (mainLabel.attributedText?.length ?? 0) == 1000)
        
        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted == nil ? .identity : .init(translationX: 0, y: -6)
        
        nameSuperStack.alignment = parsedContent.replyingTo != nil ? .top : .center
        
        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -6) : (parsedContent.replyingTo == nil ? .init(translationX: 0, y: 4) : .identity)
        
        repostedByOverlayButton.isHidden = parsedContent.reposted == nil
    }
    
    override func updateMenu(_ content: ParsedContent) {
        super.updateMenu(content)
        
        if content.zaps.isEmpty {
            zapGallery?.superview?.isHidden = true
            zapGallery?.setZaps([])
        } else {
            zapGallery?.superview?.isHidden = false
            zapGallery?.setZaps(content.zaps)
        }
    }
}

private extension PostFeedCell {
    func setup() {
        textStack.axis = .vertical
        textStack.spacing = FontSizeSelection.current.contentLineSpacing
        
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        mainLabel.setContentHuggingPriority(.required, for: .vertical)
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        seeMoreLabel.textColor = .accent2
        seeMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        zapGallery = SmallZapGalleryView()
        zapGallery?.singleLine = true
        zapGallery?.delegate = self
        let zapGalleryParent = UIView()
        zapGalleryParent.addSubview(zapGallery!)
        zapGallery?.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 4)
        
        contentView.addSubview(mainStack)
    
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        contentView.addSubview(threeDotsButton)
        threeDotsButton
            .constrainToSize(44)
            .pinToSuperview(edges: .top, padding: 2)
            .pinToSuperview(edges: .trailing)
        
        nameStack.addArrangedSubview(threeDotsSpacer)
        
        mainStack.axis = .vertical
        mainStack.spacing = 14
            
        let buttonStackStandIn = UIView()
        let contentStack = UIStackView(axis: .vertical, [
            nameSuperStack, textStack, invoiceView, articleView, mainImages, linkPresentation, postPreview, zapPreview, infoView, zapGalleryParent, buttonStackStandIn
        ])
    
        mainStack.addArrangedSubview(contentStack)
        mainStack.setCustomSpacing(8, after: repostIndicator)
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
            .constrainToSize(width: 40)
        
        contentView.addSubview(repostedByOverlayButton)
        repostedByOverlayButton
            .constrainToSize(width: 100)
            .pin(to: repostIndicator, edges: .leading)
            .pin(to: repostIndicator, edges: .top, padding: -11)
            .pin(to: repostIndicator, edges: .bottom, padding: -5)
        repostedByOverlayButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.postCellDidTap(self, .repostedProfile)
        }), for: .touchUpInside)
    }
}


