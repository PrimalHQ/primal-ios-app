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
    
    override func update(_ parsedContent: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        update(parsedContent, position: .child, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
    }
    
    func update(_ parsedContent: ParsedContent, position: ThreadPosition, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        super.update(parsedContent, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
        
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
            contentSpacer.isHidden = true
            contentView.backgroundColor = .clear
            bottomBorder.backgroundColor = .background3
            topConstraint?.constant = 0
            bottomConstraint?.constant = -12
            
            parsedContent.buildContentString(enlarge: true)
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
        let contentStack = UIStackView(axis: .vertical, [nameStack, mainLabel, mainImages, linkPresentation, postPreview, SpacerView(height: 0), actionButtonStandin])
        
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

final class DefaultMainThreadCell: ThreadCell {
    let selectionTextView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent, position: ThreadCell.ThreadPosition, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        super.update(parsedContent, position: position, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
        
        selectionTextView.attributedText = parsedContent.attributedText
    }
    
    func setup() {
        parentIndicator
            .pinToSuperview(edges: .top)
            .pinToSuperview(edges: .bottom, padding: -24)
        
        threeDotsButton.constrainToSize(width: 22)
        
        profileImageView.constrainToSize(FontSizeSelection.current.avatarSize)
        profileImageView.layer.cornerRadius = FontSizeSelection.current.avatarSize / 2
        
        nameStack.removeArrangedSubview(nipLabel)
        let nameVStack = UIStackView(axis: .vertical, [nameStack, nipLabel])
        nameVStack.spacing = 0
        
        let horizontalProfileStack = UIStackView(arrangedSubviews: [profileImageView, nameVStack, threeDotsButton])
        horizontalProfileStack.alignment = .center
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(axis: .vertical, [mainLabel, mainImages, linkPresentation, postPreview, SpacerView(height: 0, priority: .defaultHigh), actionButtonStandin])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [contentSpacer, contentStack])
        
        let mainStack = UIStackView(axis: .vertical, [repostIndicator, horizontalProfileStack, horizontalContentStack])
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
        
        contentStack.spacing = 8
        
        mainStack.spacing = 6
        mainStack.setCustomSpacing(7, after: repostIndicator)
        
        contentView.addSubview(selectionTextView)
        selectionTextView
            .pin(to: mainLabel, edges: .horizontal, padding: -5)
            .pin(to: mainLabel, edges: .top, padding: 0)
            .pin(to: mainLabel, edges: .bottom, padding: -2)
        selectionTextView.backgroundColor = .background2
        selectionTextView.tintColor = .accent
        selectionTextView.isEditable = false
        selectionTextView.isScrollEnabled = false
        selectionTextView.delegate = self
    }
}


extension DefaultMainThreadCell: UITextViewDelegate {
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        guard case .link(let url) = textItem.content else { return nil }
        return .init { [weak self] _ in
            self?.delegate?.postCellDidTapURL(self!, url: url)
        }
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, menuConfigurationFor textItem: UITextItem, defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        guard case .link(let url) = textItem.content else { return .init(menu: defaultMenu) }
        
        if url.scheme == "hashtag" {
            let hashtag = url.absoluteString.replacing("hashtag://", with: "")
            return UITextItem.MenuConfiguration(preview: .view(HashtagPreviewView(hashtag: hashtag)), menu: .init(children: [
                UIAction(title: "Open \(hashtag) feed", image: UIImage(systemName: "square.stack.fill"), handler: { [weak self] _ in
                    self?.delegate?.postCellDidTapURL(self!, url: url)
                }),
                UIAction(title: "Copy hashtag", image: UIImage(named: "MenuCopyText"), handler: { _ in
                    UIPasteboard.general.string = hashtag
                    RootViewController.instance.view?.showToast("Copied!", extraPadding: 0)
                })
            ]))
        }
        
        if url.scheme == "mention" {
            let mention = url.absoluteString.replacing("mention://", with: "")
            
            return UITextItem.MenuConfiguration(preview: .view(ProfilePreviewView(pubkey: mention)), menu: .init(children: [
                UIAction(title: "Open profile", image: UIImage(systemName: "person.crop.circle.fill"), handler: { [weak self] _ in
                    self?.delegate?.postCellDidTapURL(self!, url: url)
                }),
                UIAction(title: "Copy pubkey", image: UIImage(named: "MenuCopyText"), handler: { _ in
                    UIPasteboard.general.string = mention
                    RootViewController.instance.view?.showToast("Copied!", extraPadding: 0)
                })
            ]))
        }
        
        return .init(preview: .default, menu: defaultMenu)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.postCellDidTapURL(self, url: URL)
        return false
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
        let contentStack = UIStackView(arrangedSubviews: [mainLabel, mainImages, linkPresentation, postPreview, SpacerView(height: 0), actionButtonStandin])
        
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
