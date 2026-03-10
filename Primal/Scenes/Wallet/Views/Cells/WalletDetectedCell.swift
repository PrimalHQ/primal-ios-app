//
//  WalletDetectedCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 3. 2026..
//

import UIKit

protocol WalletDetectedCellDelegate: AnyObject {
    func restoreWalletPressed()
    func createNewWalletPressed()
}

final class WalletDetectedCell: UITableViewCell, Themeable {
    let descLabel = UILabel()
    let restoreButton = LargeRoundedButton(title: "Restore Existing Wallet")
    let createButton = UIButton(configuration: .accent18("Create New Wallet"))
    
    weak var delegate: WalletDetectedCellDelegate?

    private var isDiscontinued = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let stack = UIStackView(axis: .vertical, [descLabel, SpacerView(height: 50), restoreButton, createButton])
        stack.spacing = 14

        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .vertical, padding: 0)

        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        restoreButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.restoreWalletPressed()
        }), for: .touchUpInside)

        createButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.createNewWalletPressed()
        }), for: .touchUpInside)

        updateTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isDiscontinued: Bool) {
        self.isDiscontinued = isDiscontinued
        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 6

        let title = isDiscontinued ? "Wallet Discontinued" : "Wallet Detected"
        let description = isDiscontinued
            ? "Your custodial Primal wallet has been discontinued. To continue using the Primal wallet, please restore your self-custodial wallet via the recovery phrase, or create a new wallet."
            : "We detected that you already have a self-custodial Primal wallet associated with this Nostr account. To use it on this device, please restore it via the recovery phrase. Alternatively, you can create a new wallet which will be associated with your account."

        let descText = NSMutableAttributedString(string: "\(title)\n", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground,
            .paragraphStyle: paragraphStyle
        ])
        descText.append(.init(string: description, attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraphStyle
        ]))

        descLabel.attributedText = descText

        restoreButton.updateTheme()
    }
}
