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
    lazy var imageStack = UIStackView(arrangedSubviews: [mainImages])
    lazy var linkStack = UIStackView(arrangedSubviews: [linkPresentation])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ post: PrimalPost, parsedContent: ParsedContent, edgeBleed: Bool) {
        super.update(post, parsedContent: parsedContent)
        
        textStack.isHidden = parsedContent.text.isEmpty
        imageStack.isHidden = parsedContent.imageUrls.isEmpty
        linkStack.isHidden = parsedContent.firstExtractedURL == nil
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
        
        if edgeBleed {
            imageStack.layoutMargins = .init(top: 14, left: 0, bottom: 0, right: 0)
            mainImages.layer.cornerRadius = 0
        } else {
            imageStack.layoutMargins = .init(top: 14, left: 16, bottom: 0, right: 16)
            mainImages.layer.cornerRadius = 8
        }
    }
}

private extension FeedCell {
    func setup() {
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, namesStack, threeDotsButton])
        let mainStack = UIStackView(arrangedSubviews: [horizontalStack, textStack, linkStack, imageStack, bottomButtonStack])
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 21)
            .pinToSuperview(edges: .bottom, padding: 2) // Action buttons have a built in padding of 14
        [mainStack, imageStack].forEach {
            $0.axis = .vertical
            $0.spacing = 16
        }
        mainStack.setCustomSpacing(2, after: imageStack) // Action buttons have a built in padding of 14
        mainStack.setCustomSpacing(2, after: textStack) // Action buttons have a built in padding of 14
        
        horizontalStack.alignment = .top
        horizontalStack.spacing = 12
    
        profileImageView.constrainToSize(40)
        profileImageView.layer.cornerRadius = 20
        
        textStack.axis = .vertical
        mainLabel.numberOfLines = 20
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        
        seeMoreLabel.text = "See more..."
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.font = .appFont(withSize: 18, weight: .regular)
        seeMoreLabel.textColor = UIColor(rgb: 0xCA079F)
        
        [horizontalStack, imageStack, bottomButtonStack, textStack, linkStack].forEach {
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.isLayoutMarginsRelativeArrangement = true
        }
    }
}
