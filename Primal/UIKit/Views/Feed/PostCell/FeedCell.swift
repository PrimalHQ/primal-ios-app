//
//  FeedCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Kingfisher

class FeedCell: PostCell {
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel])
    lazy var imageStack = UIStackView(arrangedSubviews: [mainImages])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ post: PrimalPost, text: String, imageUrls: [URL], edgeBleed: Bool) {
        super.update(post, text: text, imageUrls: imageUrls)
                
        textStack.isHidden = text.isEmpty
        imageStack.isHidden = imageUrls.isEmpty
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
        let mainStack = UIStackView(arrangedSubviews: [horizontalStack, textStack, imageStack, bottomButtonStack])
        
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
        
        [horizontalStack, imageStack, bottomButtonStack, textStack].forEach {
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.isLayoutMarginsRelativeArrangement = true
        }
    }
}
