//
//  PollVoteUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

final class PollVoteUserCell: UITableViewCell, Themeable {
    private let avatarView = UserImageView(height: 42, showLegendGlow: false)
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let mainStack = UIStackView([avatarView, nameLabel])
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        mainStack.alignment = .center
        mainStack.spacing = 12

        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateForUser(_ user: ParsedUser) {
        avatarView.setUserImage(user)
        nameLabel.text = user.data.firstIdentifier
        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background2
        nameLabel.textColor = .foreground
    }
}
