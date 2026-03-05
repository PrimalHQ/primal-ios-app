//
//  PollView.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.3.26..
//

import Combine
import UIKit

final class PollView: UIView, Themeable {
    private let optionsStack = UIStackView(axis: .vertical, [])
    private let expirationLabel = UILabel()
    private let totalVotesLabel = UILabel()
    private let separatorLabel = UILabel()

    private var poll: ParsedPoll?
    private var eventId: String?
    private var authorPubkey: String?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateForContent(_ content: ParsedContent) {
        guard let poll = content.poll else { return }

        self.poll = poll
        self.eventId = content.post.id
        self.authorPubkey = content.post.pubkey

        cancellables = []

        updateExpiration(poll)

        Publishers.CombineLatest(
            PollManager.instance.statsPublisher(content.post.id),
            PollManager.instance.userVotePublisher(content.post.id)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] stats, userVote in
            self?.render(poll: poll, stats: stats, userVote: userVote)
        }
        .store(in: &cancellables)
    }

    func updateTheme() {
        expirationLabel.textColor = .foreground4
        separatorLabel.textColor = .foreground4
        totalVotesLabel.textColor = .accent2

        guard let poll, let eventId else { return }
        let stats = PollManager.instance.pollStats[eventId]
        let userVote = PollManager.instance.userVotes[eventId]
        render(poll: poll, stats: stats, userVote: userVote)
    }
}

// MARK: - Private

private extension PollView {
    var isExpired: Bool {
        guard let endsAt = poll?.endsAt else { return false }
        return endsAt <= Date()
    }

    func render(poll: ParsedPoll, stats: PollStats?, userVote: String?) {
        let showResults = isExpired || userVote != nil

        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let totalVotes = stats?.totalVotes ?? 0

        for option in poll.options {
            if showResults {
                let row = PollResultOptionView()
                let optionVotes = stats?.options[option.id]?.votes ?? 0
                row.configure(text: option.label, votes: optionVotes, totalVotes: totalVotes, isSelected: userVote == option.id)
                optionsStack.addArrangedSubview(row)
            } else {
                let row = PollVotingOptionView()
                row.configure(text: option.label)
                row.addAction(.init(handler: { [weak self] _ in
                    guard let self, let eventId = self.eventId, let authorPubkey = self.authorPubkey else { return }
                    PollManager.instance.vote(pollEventId: eventId, pollAuthorPubkey: authorPubkey, optionId: option.id)
                }), for: .touchUpInside)
                optionsStack.addArrangedSubview(row)
            }
        }

        if totalVotes > 0 {
            totalVotesLabel.isHidden = false
            totalVotesLabel.text = totalVotes == 1 ? "1 vote" : "\(totalVotes) votes"
            separatorLabel.isHidden = expirationLabel.isHidden
        } else {
            totalVotesLabel.isHidden = true
            separatorLabel.isHidden = true
        }
    }

    func updateExpiration(_ poll: ParsedPoll) {
        if let endsAt = poll.endsAt {
            expirationLabel.isHidden = false
            if endsAt > .now {
                expirationLabel.text = endsAt.timeLeftDisplay()
            } else {
                expirationLabel.text = "Ended \(endsAt.timeAgoDisplayLong())"
            }
        } else {
            expirationLabel.isHidden = true
        }
    }

    func setup() {
        expirationLabel.font = .appFont(withSize: 12, weight: .regular)
        totalVotesLabel.font = .appFont(withSize: 12, weight: .regular)
        totalVotesLabel.isHidden = true
        separatorLabel.font = .appFont(withSize: 14, weight: .heavy)
        separatorLabel.text = "•"
        separatorLabel.isHidden = true

        optionsStack.spacing = 10

        let bottomStack = UIStackView(arrangedSubviews: [totalVotesLabel, separatorLabel, expirationLabel, UIView()])
        bottomStack.spacing = 6

        let mainStack = UIStackView(axis: .vertical, [optionsStack, bottomStack])
        mainStack.spacing = 10

        addSubview(mainStack)
        mainStack.pinToSuperview()

        updateTheme()
    }
}

// MARK: - PollVotingOptionView

final class PollVotingOptionView: UIButton, Themeable {
    var text: String = ""
    init() {
        super.init(frame: .zero)
        
        layer.borderWidth = 1
        layer.cornerRadius = 18
        constrainToSize(height: 36)
        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String) {
        self.text = text
        updateTheme()
    }

    func updateTheme() {
        layer.borderColor = UIColor.foreground6.cgColor
        configuration = .pill(text: text, foregroundColor: .foreground, backgroundColor: .background4, font: .appFont(withSize: 15, weight: .regular))
    }
}


// MARK: - PollResultOptionView

final class PollResultOptionView: UIView, Themeable {
    private let progressBar = UIView()
    private let label = UILabel()
    private let percentLabel = UILabel()
    private var progressWidthConstraint: NSLayoutConstraint?

    private var isSelected = false
    private var percentage: Double = 0

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 8
        clipsToBounds = true

        addSubview(progressBar)
        progressBar.pinToSuperview(edges: [.leading, .vertical])

        label.font = .appFont(withSize: 15, weight: .regular)
        label.numberOfLines = 0

        percentLabel.font = .appFont(withSize: 14, weight: .semibold)
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        percentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [label, percentLabel])
        hStack.alignment = .center
        hStack.spacing = 8

        addSubview(hStack)
        hStack.pinToSuperview(padding: 12)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, votes: Int, totalVotes: Int, isSelected: Bool) {
        self.isSelected = isSelected
        percentage = totalVotes > 0 ? Double(votes) / Double(totalVotes) : 0

        label.text = text
        label.font = .appFont(withSize: 15, weight: isSelected ? .bold : .regular)
        percentLabel.text = "\(Int(round(percentage * 100)))%"

        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: max(CGFloat(percentage), 0.001))
        progressWidthConstraint?.isActive = true

        layer.borderWidth = isSelected ? 1.5 : 0

        updateTheme()
    }

    func updateTheme() {
        backgroundColor = .background2
        label.textColor = .foreground
        percentLabel.textColor = .foreground3
        progressBar.backgroundColor = isSelected ? UIColor.accent.withAlphaComponent(0.2) : UIColor.foreground.withAlphaComponent(0.08)
        layer.borderColor = isSelected ? UIColor.accent.cgColor : UIColor.clear.cgColor
    }
}
