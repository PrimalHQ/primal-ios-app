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
    
    override func update(_ parsedContent: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        super.update(parsedContent, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
        
        textStack.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.imageResources.isEmpty
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !mainLabel.isTruncated()
    }
}

private extension FeedCell {
    func setup() {
        let buttonStackStandIn = UIView()
        let nameStack = UIStackView([nameLabel, nipLabel, separatorLabel, timeLabel, UIView()])
        let contentStack = UIStackView(axis: .vertical, [
            nameStack, textStack, mainImages, linkPresentation, postPreview, buttonStackStandIn
        ])
        
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, contentStack])
        
        let mainStack = UIStackView(arrangedSubviews: [repostIndicator, horizontalStack])
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 12)
    
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .required
        bottomC.isActive = true
        
        contentView.addSubview(threeDotsButton)
        threeDotsButton.pinToSuperview(edges: [.top, .trailing]).constrainToSize(44)
        
        contentStack.spacing = 6
        
        nameStack.alignment = .top
        nameStack.spacing = 4
        
        mainStack.axis = .vertical
        mainStack.spacing = 14
        
        buttonStackStandIn.constrainToSize(height: 24)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack.pin(to: buttonStackStandIn, edges: .horizontal, padding: -8).centerToView(buttonStackStandIn)
        
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
        seeMoreLabel.font = .appFont(withSize: FontSelection.current.contentSize, weight: .regular)
        seeMoreLabel.textColor = .accent
    }
}
