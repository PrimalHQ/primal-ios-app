//
//  PollVoteDetailsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

final class PollVoteDetailsCell: UITableViewCell, Themeable {
    private let countLabel = UILabel()
    private let separatorDot = UILabel()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        countLabel.font = .appFont(withSize: 12, weight: .regular)
        separatorDot.font = .appFont(withSize: 14, weight: .heavy)
        separatorDot.text = "•"
        messageLabel.font = .appFont(withSize: 12, weight: .regular)

        let stack = UIStackView([countLabel, separatorDot, messageLabel, UIView()])
        stack.spacing = 6
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 6)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(totalCount: Int, isZapPoll: Bool = false, message: String) {
        if isZapPoll {
            countLabel.text = "\(totalCount.localized()) sats"
        } else {
            countLabel.text = totalCount == 1 ? "1 vote" : "\(totalCount.localized()) votes"
        }
        messageLabel.text = message
        messageLabel.isHidden = message.isEmpty
        separatorDot.isHidden = message.isEmpty
    }

    func updateTheme() {
        contentView.backgroundColor = .background2
        countLabel.textColor = .accent2
        separatorDot.textColor = .foreground4
        messageLabel.textColor = .foreground4
    }
}
