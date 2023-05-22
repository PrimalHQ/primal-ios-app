//
//  FeedCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Kingfisher

final class FeedCell: PostCell {
    lazy var seeMoreLabel = UILabel()
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ post: PrimalPost, parsedContent: ParsedContent, didLike: Bool, didRepost: Bool) {
        super.update(post, parsedContent: parsedContent, didLike: didLike, didRepost: didRepost)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.imageUrls.isEmpty
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
    }
}

private extension FeedCell {
    func setup() {
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, namesStack, threeDotsButton])
        let buttonStackStandIn = UIView()
        let mainStack = UIStackView(arrangedSubviews: [horizontalStack, textStack, mainImages, buttonStackStandIn])
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: [.horizontal, .bottom], padding: 16)
            .pinToSuperview(edges: .top, padding: 21)
        
        [mainStack].forEach {
            $0.axis = .vertical
            $0.spacing = 16
        }
        
        buttonStackStandIn.constrainToSize(height: 24)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack.pin(to: buttonStackStandIn, edges: .horizontal).centerToView(buttonStackStandIn)
        
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
    }
}
