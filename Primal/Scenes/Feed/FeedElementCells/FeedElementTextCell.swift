//
//  FeedElementTextCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementTextCell: PostCell {
    override class var cellID: String { "FeedElementTextCell" }
    
    override var useShortText: Bool { true }
    
    lazy var seeMoreLabel = UILabel("See more...", color: .accent2, font: .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular))
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textStack)
        textStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .bottom)
            .pinToSuperview(edges: .top, padding: 8)
        
        textStack.axis = .vertical
        textStack.spacing = FontSizeSelection.current.contentLineSpacing
        
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        mainLabel.attributedText = parsedContent.attributedTextShort
        mainLabel.numberOfLines = (parsedContent.mediaResources.isEmpty && parsedContent.linkPreview == nil && parsedContent.embededPost == nil) ? 12 : 6
        
        layoutSubviews()
        
        seeMoreLabel.isHidden = !(mainLabel.isTruncated() || (mainLabel.attributedText?.length ?? 0) == 1000)
    }
    
    override func updateMenu(_ content: ParsedContent) { }
}
