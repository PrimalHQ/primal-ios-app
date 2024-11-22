//
//  HighlightCommentCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.7.24..
//

import UIKit

class HighlightCommentCell: PostCell {
    lazy var mainStack = UIStackView([profileImageView])
    
    // MARK: - State
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        
        mainLabel.isHidden = parsedContent.text.isEmpty
        mainImages.isHidden = parsedContent.mediaResources.isEmpty
        
        layoutSubviews()
    }
}

private extension HighlightCommentCell {
    func setup() {
        mainLabel.numberOfLines = 12
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.lineBreakStrategy = .standard
        mainLabel.setContentHuggingPriority(.required, for: .vertical)
        
        mainStack.axis = .horizontal
        mainStack.alignment = .top
        mainStack.spacing = 8
        
        profileImageView.height = 30
    
        let commentedLabel = UILabel()
        commentedLabel.font = .appFont(withSize: 15, weight: .regular)
        commentedLabel.textColor = .foreground
        commentedLabel.text = "commented:"
        
        let nameStack = UIStackView([nameLabel, checkbox, commentedLabel, UIView(), timeLabel])
        nameStack.spacing = 4
        
        let contentStack = UIStackView(axis: .vertical, [
            nameStack, mainLabel, invoiceView, mainImages, linkPresentation, postPreview
        ])
    
        mainStack.addArrangedSubview(contentStack)
        mainStack.pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .horizontal, padding: 16)
        
        nameStack.constrainToSize(height: 30)
        nameStack.alignment = .center
        
        contentStack.spacing = 8
        contentStack.setCustomSpacing(4, after: nameStack)
        
        bottomBorder.removeFromSuperview()
        
        contentView.backgroundColor = .background4
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .vertical, padding: 12).pinToSuperview(edges: .horizontal, padding: 20)
    }
}


