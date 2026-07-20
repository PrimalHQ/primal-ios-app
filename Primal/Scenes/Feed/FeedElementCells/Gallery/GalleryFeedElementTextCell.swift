//
//  GalleryFeedElementTextCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.4.26..
//

import UIKit
import Nantes

private class GalleryTextCellNantesDelegate {
    weak var cell: UITableViewCell?
    weak var delegate: FeedElementCellDelegate?
}

extension GalleryTextCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard let cell else { return }
        delegate?.postCellDidTap(cell, .url(link))
    }
}

class GalleryFeedElementTextCell: UITableViewCell, RegularFeedElementCell {
    static var cellID: String { galleryCellID }
    static let galleryCellID = "GalleryFeedElementTextCell"

    weak var delegate: FeedElementCellDelegate?

    private let nantesDelegate = GalleryTextCellNantesDelegate()

    let mainLabel = NantesLabel()
    lazy var seeMoreLabel = UILabel("See more...", color: .accent2, font: .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular))
    lazy var textStack = UIStackView(arrangedSubviews: [mainLabel, seeMoreLabel])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .background2

        contentView.addSubview(textStack)
        textStack
            .pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 16)
            .pinToSuperview(edges: .bottom)
            .pinToSuperview(edges: .top, padding: 4)

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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(_ parsedContent: ParsedContent) {
        nantesDelegate.delegate = delegate

        let username = parsedContent.user.data.firstIdentifier
        let usernameAttr = NSAttributedString(string: username + " ", attributes: [
            .font: UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .bold),
            .foregroundColor: UIColor.foreground
        ])
        let combined = NSMutableAttributedString(attributedString: usernameAttr)
        combined.append(parsedContent.attributedTextShort)
        mainLabel.attributedText = combined
        mainLabel.numberOfLines = 3

        seeMoreLabel.isHidden = !(mainLabel.isTruncated() || parsedContent.attributedTextShort.length >= 500)

        updateTheme()
    }

    func updateTheme() {
        seeMoreLabel.textColor = .accent2
        seeMoreLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        textStack.spacing = FontSizeSelection.current.contentLineSpacing
        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
    }
}
