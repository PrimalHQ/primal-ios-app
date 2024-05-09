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
        }
    }
}

extension ThreadCell {
    func parentSetup() {
        contentSpacer.addSubview(parentIndicator)
        
        parentIndicator
            .centerToSuperview(axis: .horizontal)
            .constrainToSize(width: 2)
        
        parentIndicator.backgroundColor = UIColor(rgb: 0x444444)
        parentIndicator.layer.cornerRadius = 1
    }
}

// MARK: - DefaultThreadCell

final class DefaultThreadCell: ThreadCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        nameStack.addArrangedSubview(threeDotsButton)
        
        parentIndicator
            .pinToSuperview(edges: .top)
            .pinToSuperview(edges: .bottom, padding: -24)
        
        profileImageView.constrainToSize(FontSizeSelection.current.avatarSize)
        profileImageView.layer.cornerRadius = FontSizeSelection.current.avatarSize / 2
            
        let imageSpacerStack = UIStackView(axis: .vertical, [profileImageView, contentSpacer, UIView()])
        imageSpacerStack.spacing = 2
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(axis: .vertical, [nameStack, mainLabel, invoiceView, mainImages, linkPresentation, postPreview, SpacerView(height: 0), actionButtonStandin])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [imageSpacerStack, contentStack])
        
        let mainStack = UIStackView(axis: .vertical, [repostIndicator, horizontalContentStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
    
        topConstraint = mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        topConstraint?.isActive = true
        
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        bottomConstraint = bottomC
        
        actionButtonStandin.constrainToSize(height: 18)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .centerToView(actionButtonStandin)
            .pin(to: actionButtonStandin, edges: .horizontal, padding: -7)
        
        horizontalContentStack.spacing = 8
        contentStack.spacing = 8
        
        mainStack.spacing = 6
        mainStack.setCustomSpacing(7, after: repostIndicator)
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
    let viewController: RegularFeedViewController
    init(hashtag: String) {
        self.hashtag = hashtag
        viewController = RegularFeedViewController(feed: .init(search: hashtag))
        super.init(frame: .zero)
        addSubview(viewController.view)
        viewController.view.pinToSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

struct HashtagView: UIViewControllerRepresentable {
    var hashtag: String
    
    func makeUIViewController(context: Context) -> RegularFeedViewController {
        RegularFeedViewController(feed: FeedManager(search: hashtag))
    }
    
    func updateUIViewController(_ uiViewController: RegularFeedViewController, context: Context) {
        
    }
}

// MARK: - FullWidthThreadCell

final class FullWidthThreadCell: ThreadCell {
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
        
        profileImageView.constrainToSize(24)
        profileImageView.layer.cornerRadius = 12
        
        let horizontalProfileStack = UIStackView(arrangedSubviews: [profileImageView, nameStack, threeDotsButton])
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(arrangedSubviews: [mainLabel, invoiceView, mainImages, linkPresentation, postPreview, SpacerView(height: 0), actionButtonStandin])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [contentSpacer, contentStack])
        
        let mainStack = UIStackView(arrangedSubviews: [repostIndicator, horizontalProfileStack, horizontalContentStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        topConstraint = mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        topConstraint?.isActive = true
        
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultLow
        bottomC.isActive = true
        bottomConstraint = bottomC
        
        actionButtonStandin.constrainToSize(height: 18)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .centerToView(actionButtonStandin)
            .pin(to: actionButtonStandin, edges: .horizontal)//, padding: -16)
        
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
