//
//  PollVoteOptionCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

final class PollVoteOptionCell: UITableViewCell, Themeable {
    private let progressParent = UIView()
    private let progressBar = UIView()
    private let label = UILabel()
    private let checkIcon = UIImageView(image: .pollOptionWon)
    private let percentLabel = UILabel()
    private let seeVotesLabel = UILabel()
    private let selectionBorder = UIView()

    private var isVotedOption = false
    private var percentage: CGFloat = 0

    private var progressConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            progressConstraint?.priority = .defaultLow
            progressConstraint?.isActive = true
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        // Progress bar inside parent
        progressBar.layer.cornerRadius = 6
        progressParent.addSubview(progressBar)
        progressBar.pinToSuperview(edges: .leading).pinToSuperview(edges: .vertical, padding: 2)
        progressBar.widthAnchor.constraint(greaterThanOrEqualToConstant: 6).isActive = true

        // Label + check icon inside progress parent
        checkIcon.setContentHuggingPriority(.required, for: .horizontal)
        checkIcon.setContentCompressionResistancePriority(.required, for: .horizontal)

        let labelCheckStack = UIStackView([label, checkIcon, UIView()])
        labelCheckStack.alignment = .center
        labelCheckStack.setCustomSpacing(6, after: label)

        progressParent.addSubview(labelCheckStack)
        labelCheckStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview(axis: .vertical)
        label.font = .appFont(withSize: 15, weight: .regular)

        // Right side: percentage + "see votes"
        percentLabel.font = .appFont(withSize: 15, weight: .semibold)

        seeVotesLabel.text = "see votes"
        seeVotesLabel.font = .appFont(withSize: 14, weight: .regular)

        let rightStack = UIStackView(axis: .vertical, [percentLabel, seeVotesLabel])
        rightStack.alignment = .trailing
        rightStack.spacing = 0

        // Main horizontal: progressParent + right column
        let hStack = UIStackView([progressParent, rightStack])
        hStack.alignment = .center
        hStack.spacing = 8

        contentView.addSubview(hStack)
        hStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 5)

        progressParent.constrainToSize(height: 36)

        // Selection border
        selectionBorder.layer.borderWidth = 1
        selectionBorder.layer.cornerRadius = 8
        selectionBorder.isUserInteractionEnabled = false
        contentView.insertSubview(selectionBorder, at: 0)
        selectionBorder.pinToSuperview(edges: .horizontal, padding: 8).pinToSuperview(edges: .vertical)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(option: ParsedPoll.Option, stats: PollOptionStats, totalVotes: Int, maxVotes: Int, isSelected: Bool, userVote: String?, didEnd: Bool) {
        isVotedOption = userVote == option.id
        percentage = totalVotes > 0 ? Double(stats.votes) / Double(totalVotes) : 0

        checkIcon.isHidden = !(didEnd && stats.votes == maxVotes && stats.votes > 0)

        label.text = option.label
        label.font = .appFont(withSize: 15, weight: isVotedOption ? .bold : .regular)

        let pct = percentage * 100
        if pct == floor(pct) {
            percentLabel.text = "\(Int(pct))%"
        } else {
            percentLabel.text = String(format: "%.1f%%", pct)
        }

        progressConstraint = progressBar.widthAnchor.constraint(equalTo: progressParent.widthAnchor, multiplier: max(percentage, 0.001))
        progressBar.layer.cornerRadius = 300 * percentage > 12 ? 6 : 3

        selectionBorder.isHidden = !isSelected
        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background2
        label.textColor = .foreground
        percentLabel.textColor = .foreground3
        seeVotesLabel.textColor = .accent2
        progressBar.backgroundColor = isVotedOption ? .accent : UIColor.foreground6
        progressBar.alpha = Theme.current.isLightTheme ? 0.5 : 1
        checkIcon.tintColor = .foreground
        selectionBorder.layer.borderColor = UIColor.accent.cgColor
        selectionBorder.backgroundColor = .background5
    }
}
