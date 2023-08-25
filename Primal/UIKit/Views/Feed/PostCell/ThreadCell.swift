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
    
    let gradient = GradientView(colors: UIColor.gradient)
    lazy var contentSpacer = UIView()
    lazy var parentIndicator = UIView()
    
    override func update(_ parsedContent: ParsedContent, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        update(parsedContent, position: .child, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
    }
    
    func update(_ parsedContent: ParsedContent, position: ThreadPosition, didLike: Bool, didRepost: Bool, didZap: Bool, isMuted: Bool) {
        super.update(parsedContent, didLike: didLike, didRepost: didRepost, didZap: didZap, isMuted: isMuted)
        
        mainLabel.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.imageResources.isEmpty
        
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

extension ThreadCell {
    func parentSetup() {
        profileImageView.constrainToSize(FontSizeSelection.current.avatarSize)
        profileImageView.layer.cornerRadius = FontSizeSelection.current.avatarSize / 2
        
        contentSpacer.addSubview(parentIndicator)
        parentIndicator
            .centerToSuperview(axis: .horizontal)
            .pinToSuperview(edges: .vertical, padding: 0)
            .constrainToSize(width: 2)
        
        parentIndicator.backgroundColor = UIColor(rgb: 0x444444)
        parentIndicator.layer.cornerRadius = 1
        
        backgroundColorView.addSubview(gradient)
        gradient.pinToSuperview(edges: [.leading, .vertical]).constrainToSize(width: 5)
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
        
        let imageSpacerStack = UIStackView(axis: .vertical, [profileImageView, contentSpacer, UIView()])
        imageSpacerStack.spacing = 2
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(arrangedSubviews: [nameStack, mainLabel, mainImages, linkPresentation, postPreview, SpacerView(height: 0), actionButtonStandin])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [imageSpacerStack, contentStack])
        
        let mainStack = UIStackView(arrangedSubviews: [repostIndicator, horizontalContentStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .top, padding: 12)
    
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        actionButtonStandin.constrainToSize(height: 18)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .centerToView(actionButtonStandin)
            .pin(to: actionButtonStandin, edges: .horizontal)
        
        horizontalContentStack.spacing = 8
        
        [mainStack, contentStack].forEach {
            $0.axis = .vertical
            $0.spacing = 6
        }
    }
}

final class DefaultMainThreadCell: ThreadCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        threeDotsButton.constrainToSize(width: 22)
        
        nameStack.removeArrangedSubview(nipLabel)
        let nameVStack = UIStackView(axis: .vertical, [nameStack, nipLabel])
        nameVStack.spacing = 0
        
        let horizontalProfileStack = UIStackView(arrangedSubviews: [profileImageView, nameVStack, threeDotsButton])
        horizontalProfileStack.alignment = .center
        
        let actionButtonStandin = UIView()
        let contentStack = UIStackView(arrangedSubviews: [mainLabel, mainImages, linkPresentation, postPreview, SpacerView(height: 0, priority: .defaultHigh), actionButtonStandin])
        
        let horizontalContentStack = UIStackView(arrangedSubviews: [contentSpacer, contentStack])
        
        let mainStack = UIStackView(arrangedSubviews: [repostIndicator, horizontalProfileStack, horizontalContentStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .top, padding: 12)
            
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultLow
        bottomC.isActive = true
        
        actionButtonStandin.constrainToSize(height: 18)
        contentView.addSubview(bottomButtonStack)
        bottomButtonStack
            .centerToView(actionButtonStandin)
            .pin(to: actionButtonStandin, edges: .horizontal)//, padding: -16)
        
        horizontalContentStack.spacing = 8
        horizontalProfileStack.spacing = 8
        
        [mainStack, contentStack].forEach {
            $0.axis = .vertical
            $0.spacing = 6
        }
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
            .pinToSuperview(edges: .top, padding: 12)
        
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultLow
        bottomC.isActive = true
        
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
    }
}
