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
    private let verifiedView = VerifiedView().constrainToSize(20)
    private let nipLabel = UILabel()
    private let topBorder = UIView()
    private let zapIcon = UIImageView(image: .feedZapBig)
    private let zapAmountLabel = UILabel()
    
    private lazy var zapStack = UIStackView(axis: .vertical, spacing: 5, [zapIcon, zapAmountLabel])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nipLabel.font = .appFont(withSize: 14, weight: .regular)
        zapAmountLabel.font = .appFont(withSize: 14, weight: .semibold)

        let nameRow = UIStackView([nameLabel, verifiedView, UIView()])
        nameRow.alignment = .center
        nameRow.spacing = 4

        let infoStack = UIStackView(axis: .vertical, [nameRow, nipLabel])
        infoStack.spacing = 2

        zapStack.alignment = .center
        zapStack.constrainToSize(width: 60)

        let mainStack = UIStackView([zapStack, avatarView, infoStack])
        mainStack.alignment = .center
        mainStack.spacing = 12

        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 10)

        contentView.addSubview(topBorder)
        topBorder.pinToSuperview(edges: [.top, .horizontal])
        topBorder.constrainToSize(height: 1)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateForUser(_ user: ParsedUser) {
        avatarView.setUserImage(user)
        nameLabel.text = user.data.firstIdentifier

        verifiedView.user = user.data

        let nip = user.data.parsedNip
        if nip.isEmpty || !CheckNip05Manager.instance.isVerified(user.data) {
            nipLabel.isHidden = true
        } else {
            nipLabel.isHidden = false
            nipLabel.text = nip
        }

        zapStack.isHidden = true

        updateTheme()
    }

    func updateForZap(user: ParsedUser, sats: Int) {
        avatarView.setUserImage(user)
        nameLabel.text = user.data.firstIdentifier

        verifiedView.user = user.data

        let nip = user.data.parsedNip
        if nip.isEmpty || !CheckNip05Manager.instance.isVerified(user.data) {
            nipLabel.isHidden = true
        } else {
            nipLabel.isHidden = false
            nipLabel.text = nip
        }

        zapStack.isHidden = false
        zapAmountLabel.text = sats.shortenedLocalized()
        zapAmountLabel.isHidden = sats <= 0

        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background2
        nameLabel.textColor = .foreground
        nipLabel.textColor = .foreground4
        topBorder.backgroundColor = .background3
        zapIcon.tintColor = .foreground3
        zapAmountLabel.textColor = .foreground
    }
}
