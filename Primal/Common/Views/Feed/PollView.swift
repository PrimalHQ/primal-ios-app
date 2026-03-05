//
//  PollView.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.3.26..
//

import UIKit

final class PollView: UIView, Themeable {
    private let optionsStack = UIStackView(axis: .vertical, [])
    private let expirationLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateForPoll(_ poll: ParsedPoll) {
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for option in poll.options {
            let row = createOptionRow(option.label)
            optionsStack.addArrangedSubview(row)
        }

        if let endsAt = poll.endsAt {
            expirationLabel.isHidden = false
            if endsAt > Date() {
                expirationLabel.text = "Ends: \(endsAt.timeInFutureDisplayLong())"
            } else {
                expirationLabel.text = "Ended: \(endsAt.timeAgoDisplayLong())"
            }
        } else {
            expirationLabel.isHidden = true
        }
    }

    func updateTheme() {
        expirationLabel.textColor = .foreground3
        backgroundColor = .background3

        for view in optionsStack.arrangedSubviews {
            view.backgroundColor = .background2
            view.layer.borderColor = UIColor.foreground6.cgColor
            if let label = view.subviews.first as? UILabel {
                label.textColor = .foreground
            }
        }
    }
}

private extension PollView {
    func createOptionRow(_ text: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.foreground6.cgColor
        container.backgroundColor = .background2

        let label = UILabel()
        label.text = text
        label.font = .appFont(withSize: 15, weight: .regular)
        label.textColor = .foreground
        label.numberOfLines = 0

        container.addSubview(label)
        label.pinToSuperview(padding: 12)

        return container
    }

    func setup() {
        expirationLabel.font = .appFont(withSize: 13, weight: .regular)

        optionsStack.spacing = 8

        let mainStack = UIStackView(axis: .vertical, [optionsStack, expirationLabel])
        mainStack.spacing = 8

        addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)

        layer.cornerRadius = 8

        updateTheme()
    }
}
