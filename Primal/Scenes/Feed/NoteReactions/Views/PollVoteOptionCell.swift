//
//  PollVoteOptionCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

final class PollVoteOptionCell: UITableViewCell, Themeable {
    let resultView = PollResultOptionView()
    private let seeVotesLabel = UILabel()
    private let selectionBorder = UIView()

    var onSeeVotes: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        seeVotesLabel.text = "see votes"
        seeVotesLabel.font = .appFont(withSize: 13, weight: .regular)
        seeVotesLabel.textAlignment = .right

        let rightStack = UIStackView(axis: .vertical, [resultView, seeVotesLabel])
        rightStack.spacing = 0

        contentView.addSubview(rightStack)
        rightStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 4)

        selectionBorder.layer.borderWidth = 1.5
        selectionBorder.layer.cornerRadius = 8
        selectionBorder.isUserInteractionEnabled = false
        contentView.addSubview(selectionBorder)
        selectionBorder.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 2)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(option: ParsedPoll.Option, stats: PollOptionStats, totalVotes: Int, isSelected: Bool, userVote: String?, didEnd: Bool) {
        let maxVotes = totalVotes
        resultView.configure(
            text: option.label,
            votes: stats.votes,
            totalVotes: totalVotes,
            isSelected: userVote == option.id,
            didWin: didEnd && stats.votes == maxVotes
        )
        selectionBorder.isHidden = !isSelected
        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background2
        seeVotesLabel.textColor = .accent2
        selectionBorder.layer.borderColor = UIColor.accent.cgColor
    }
}
