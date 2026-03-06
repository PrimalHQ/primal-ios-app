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

        titleLabel.font = .appFont(withSize: 18, weight: .bold)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        countLabel.font = .appFont(withSize: 16, weight: .regular)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView([titleLabel, countLabel])
        stack.spacing = 8
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 14)

        topBorder.constrainToSize(height: 6)
        contentView.addSubview(topBorder)
        topBorder.pinToSuperview(edges: [.top, .horizontal])

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = count == 1 ? "1 vote" : "\(count.localized()) votes"
    }

    func updateTheme() {
        contentView.backgroundColor = .background2
        titleLabel.textColor = .foreground
        countLabel.textColor = .accent2
        topBorder.backgroundColor = .background
    }
}
