//
//  PollVoteTitleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

final class PollVoteTitleCell: UITableViewCell, Themeable {
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let topBorder = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView([titleLabel, countLabel])
        stack.spacing = 8
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 14)

        topBorder.constrainToSize(height: 2)
        contentView.addSubview(topBorder)
        topBorder.pinToSuperview(edges: [.top, .horizontal])

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, count: Int, isZapPoll: Bool = false) {
        titleLabel.text = title

        let unit: String
        if isZapPoll {
            unit = " sats"
        } else {
            unit = " vote\(count == 1 ? "" : "s")"
        }

        let countText = NSMutableAttributedString(string: count.localized(), attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .semibold),
            .foregroundColor: UIColor.foreground
        ])
        countText.append(.init(string: unit, attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        countLabel.attributedText = countText

        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background
        titleLabel.textColor = .foreground
        topBorder.backgroundColor = .background3
    }
}
