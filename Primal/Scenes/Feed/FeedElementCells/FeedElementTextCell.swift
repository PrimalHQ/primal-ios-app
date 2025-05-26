//
//  FeedElementTextCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit
import Nantes

// This is a helper class necessary to prevent retain cycle because delegate in Nantes isn't defined as "weak"
class FeedElementTextCellNantesDelegate {
    weak var cell: FeedElementBaseCell?
}

extension FeedElementTextCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard let cell else { return }
        cell.delegate?.postCellDidTap(cell, .url(link))
    }
}

class FeedElementTextCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementTextCell" }
    
    var useShortText: Bool { true }
    
    let nantesDelegate = FeedElementTextCellNantesDelegate()
    
    let mainLabel = NantesLabel()
    lazy var seeMoreLabel = UILabel("See more...", color: .accent2, font: .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular))
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        mainLabel.attributedText = parsedContent.attributedTextShort
        mainLabel.numberOfLines = (parsedContent.mediaResources.isEmpty && parsedContent.linkPreviews.isEmpty && parsedContent.embeddedPosts.isEmpty) ? 12 : 6
        
        seeMoreLabel.isHidden = !(mainLabel.isTruncated() || (mainLabel.attributedText?.length ?? 0) == 500)
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        seeMoreLabel.textColor = .accent2
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        
        textStack.spacing = FontSizeSelection.current.contentLineSpacing
        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
    }
}

private extension FeedElementTextCell {
    func setup() {
        contentView.addSubview(textStack)
        textStack
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .bottom)
            .pinToSuperview(edges: .top, padding: 8)
        
        textStack.axis = .vertical
        
        seeMoreLabel.textAlignment = .natural
        seeMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        nantesDelegate.cell = self
        
        mainLabel.enabledTextCheckingTypes = [.phoneNumber]
        mainLabel.numberOfLines = 0
        mainLabel.delegate = nantesDelegate
        mainLabel.labelTappedBlock = { [weak self] in
            guard let self else { return }
            self.delegate?.postCellDidTap(self, .post)
        }
        mainLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
