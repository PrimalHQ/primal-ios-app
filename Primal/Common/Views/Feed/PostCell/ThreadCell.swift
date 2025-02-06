//
//  ThreadCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.5.23..
//

import UIKit
import Kingfisher
import SwiftUI

class ThreadCell: PostCell {
    enum ThreadPosition {
        case parent, main, child
    }
    
    var topConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    lazy var contentSpacer = UIView()
    lazy var parentIndicator = UIView()
    
    let smallGallery = SmallZapGalleryView()
    
    override func update(_ parsedContent: ParsedContent) {
        update(parsedContent, position: .child)
    }
    
    func update(_ parsedContent: ParsedContent, position: ThreadPosition) {
        super.update(parsedContent)
        
        mainLabel.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        
        switch position {
        case .parent:
            contentSpacer.isHidden = false
            parentIndicator.isHidden = false
            contentView.backgroundColor = .clear
            bottomBorder.backgroundColor = .clear
            topConstraint?.constant = 0
            bottomConstraint?.constant = -24
            
            mainLabel.attributedText = parsedContent.attributedText
        case .main:
            contentView.backgroundColor = .clear
            bottomBorder.backgroundColor = .background3
            topConstraint?.constant = 0
            bottomConstraint?.constant = -12
            
            parsedContent.buildContentString(style: .enlarged)
            mainLabel.attributedText = parsedContent.attributedText
        case .child:
            contentSpacer.isHidden = false
            parentIndicator.isHidden = true
            contentView.backgroundColor = .background2
            bottomBorder.backgroundColor = .background3
            topConstraint?.constant = 12
            bottomConstraint?.constant = -12
            
            mainLabel.attributedText = parsedContent.attributedText
        }
    }
    
    override func updateMenu(_ content: ParsedContent) {
        super.updateMenu(content)
        
        if content.zaps.isEmpty {
            zapGallery?.isHidden = true
        } else {
            zapGallery?.isHidden = false
            zapGallery?.setZaps(content.zaps)
        }
    }
}

extension ThreadCell {
    func parentSetup() {
        zapGallery = smallGallery
        zapGallery?.delegate = self
        
        contentSpacer.addSubview(parentIndicator)
        
        parentIndicator
            .centerToSuperview(axis: .horizontal)
            .constrainToSize(width: 2)
        
        parentIndicator.backgroundColor = .foreground6
        parentIndicator.layer.cornerRadius = 1
    }
}

class ProfilePreviewView: UIView {
    let pubkey: String
    let viewController: ProfileViewController
    init(pubkey: String) {
        self.pubkey = pubkey
        viewController = ProfileViewController(profile: .init(data: .init(pubkey: pubkey)))
        super.init(frame: .zero)
        addSubview(viewController.view)
        viewController.view.pinToSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class HashtagPreviewView: UIView {
    let hashtag: String
    let viewController: SearchNoteFeedController
    init(hashtag: String) {
        self.hashtag = hashtag
        let advancedSearchManager = AdvancedSearchManager()
        advancedSearchManager.includeWordsText = hashtag
        viewController = SearchNoteFeedController(feed: .init(newFeed: advancedSearchManager.feed))
        super.init(frame: .zero)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.viewController.table.contentInset = .zero
        }
        addSubview(viewController.view)
        viewController.view.pinToSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - PostThreadCell

final class PostThreadCell: ThreadCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        parentIndicator
            .pinToSuperview(edges: .top, padding: -2)
            .pinToSuperview(edges: .bottom, padding: -20)
        
        contentSpacer.constrainToSize(width: 24)
        
        profileImageView.height = 24
        
        smallGallery.singleLine = true
        
        let horizontalProfileStack = UIStackView(arrangedSubviews: [profileImageView, nameStack, threeDotsButton])
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(arrangedSubviews: [
            mainLabel, invoiceView, articleView, mainImages, linkPresentation, postPreview, zapPreview, infoView, smallGallery, SpacerView(height: 0), actionButtonStandin
        ])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [contentSpacer, contentStack])
        
        let mainStack = UIStackView(arrangedSubviews: [repostIndicator, horizontalProfileStack, horizontalContentStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .trailing, padding: 16)
            .pinToSuperview(edges: .leading, padding: 21)
        
        topConstraint = mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        topConstraint?.isActive = true
        
        bottomConstraint = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomConstraint?.isActive = true
        
        actionButtonStandin.constrainToSize(height: 18)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .centerToView(actionButtonStandin)
            .pin(to: actionButtonStandin, edges: .horizontal)//, padding: -16)
        
        contentView.addSubview(bookmarkButton)
        bookmarkButton
            .pin(to: bottomButtonStack, edges: .trailing)
            .centerToView(bottomButtonStack, axis: .vertical)
        
        horizontalContentStack.spacing = 8
        horizontalProfileStack.spacing = 8
        horizontalProfileStack.alignment = .center
        
        [mainStack, contentStack].forEach {
            $0.axis = .vertical
            $0.spacing = 6
        }
        mainStack.setCustomSpacing(7, after: repostIndicator)
    }
}
