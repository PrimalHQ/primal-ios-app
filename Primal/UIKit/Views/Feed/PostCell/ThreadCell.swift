//
//  ThreadCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.5.23..
//

import UIKit
import Kingfisher

class ThreadCell: PostCell {
    enum ThreadPosition {
        case parent, main, child
    }
    
    let gradient = GradientView(colors: [.init(rgb: 0xDD3A55), .init(rgb: 0x5B12A4)])
    lazy var contentSpacer = UIView()
    lazy var parentIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ post: PrimalPost, parsedContent: ParsedContent) {
        update(post, parsedContent: parsedContent, position: .child)
    }
    
    func update(_ post: PrimalPost, parsedContent: ParsedContent, position: ThreadPosition) {
        super.update(post, parsedContent: parsedContent)
        
        mainLabel.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.imageUrls.isEmpty
        
        switch position {
        case .parent:
            gradient.isHidden = true
            contentSpacer.isHidden = false
            parentIndicator.isHidden = false
        case .main:
            gradient.isHidden = false
            contentSpacer.isHidden = true
        case .child:
            gradient.isHidden = true
            contentSpacer.isHidden = false
            parentIndicator.isHidden = true
        }
    }
}

private extension ThreadCell {
    func setup() {
        let horizontalProfileStack = UIStackView(arrangedSubviews: [profileImageView, namesStack, threeDotsButton])
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(arrangedSubviews: [mainLabel, mainImages, actionButtonStandin])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [contentSpacer, contentStack])
        
        let mainStack = UIStackView(arrangedSubviews: [horizontalProfileStack, horizontalContentStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .leading, padding: 18)
            .pinToSuperview(edges: .trailing, padding: 14)
            .pinToSuperview(edges: .vertical, padding: 21)
        
        actionButtonStandin.constrainToSize(height: 18)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .centerToView(actionButtonStandin)
            .pin(to: actionButtonStandin, edges: .horizontal)//, padding: -16)
        
        horizontalContentStack.spacing = 12
        horizontalProfileStack.spacing = 12
        
        [mainStack, contentStack].forEach {
            $0.axis = .vertical
            $0.spacing = 16
        }
        
        profileImageView.constrainToSize(40)
        profileImageView.layer.cornerRadius = 20
        
        contentSpacer.constrainToSize(width: 40)
        contentSpacer.addSubview(parentIndicator)
        parentIndicator
            .centerToSuperview()
            .pinToSuperview(edges: .vertical, padding: 0)
            .constrainToSize(width: 2)
        
        parentIndicator.backgroundColor = UIColor(rgb: 0x444444)
        parentIndicator.layer.cornerRadius = 1
        
        backgroundColorView.addSubview(gradient)
        gradient.pinToSuperview(edges: [.leading, .vertical]).constrainToSize(width: 5)
    }
}
