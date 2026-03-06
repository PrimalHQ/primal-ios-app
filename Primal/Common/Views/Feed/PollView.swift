//
//  PollView.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.3.26..
//

import Combine
import UIKit

extension ParsedPoll {
    var didEnd: Bool {
        guard let endsAt else { return false }
        return endsAt < .now
    }
}

final class PollView: UIView, Themeable {
    private let optionsStack = UIStackView(axis: .vertical, [])
    private let expirationLabel = UILabel()
    private let totalVotesLabel = UILabel()
    private let separatorLabel = UILabel()

    private var poll: ParsedPoll?
    private var eventId: String?
    private var authorUser: PrimalUser?
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
        self.authorUser = content.user.data

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
                let didEnd = poll.didEnd
                let maxVotes = stats?.totalVotes
                row.configure(
                    text: option.label,
                    votes: optionVotes,
                    totalVotes: totalVotes,
                    isSelected: userVote == option.id,
                    didWin: didEnd && optionVotes == maxVotes
                )
                optionsStack.addArrangedSubview(row)
            } else {
                let row = PollVotingOptionView()
                row.configure(text: option.label)
                row.addAction(.init(handler: { [weak self] _ in
                    guard let self, let eventId = self.eventId, let authorUser = self.authorUser else { return }
                    if poll.isZapPoll {
                        self.presentZapVote(pollEventId: eventId, pollAuthor: authorUser, optionId: option.id, poll: poll)
                    } else {
                        PollManager.instance.vote(pollEventId: eventId, pollAuthorPubkey: authorUser.pubkey, optionId: option.id)
                    }
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

    func presentZapVote(pollEventId: String, pollAuthor: PrimalUser, optionId: String, poll: ParsedPoll) {
        let vc = RootViewController.instance.presentedViewController ?? RootViewController.instance

        if pollAuthor.address == nil {
            vc.showErrorMessage(title: "Can't Zap", "The poll author didn't set up their lightning wallet")
            return
        }

        let popup = PopupZapPollVoteViewController(valueMinimum: poll.valueMinimum, valueMaximum: poll.valueMaximum) { amount, message in
            let presenter = RootViewController.instance.presentedViewController ?? RootViewController.instance

            if let min = poll.valueMinimum, amount < min {
                presenter.showErrorMessage(title: "Invalid Amount", "Minimum zap for this poll is \(min) sats")
                return
            }
            if let max = poll.valueMaximum, amount > max {
                presenter.showErrorMessage(title: "Invalid Amount", "Maximum zap for this poll is \(max) sats")
                return
            }

            if WalletManager.instance.balance < amount {
                presenter.showErrorMessage("Insufficient funds for this zap. Check your wallet.")
                return
            }

            PollManager.instance.zapVote(pollEventId: pollEventId, pollAuthor: pollAuthor, optionId: optionId, sats: amount, message: message)
        }
        vc.present(popup, animated: true)
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
    private let progressParent = UIView()
    private let progressBar = UIView()
    private let label = UILabel()
    private let percentLabel = UILabel()
    private let checkIcon = UIImageView(image: .pollOptionWon)

    private var isSelected = false
    private var percentage: CGFloat = 0

    private var progressConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            progressConstraint?.priority = .defaultLow
            progressConstraint?.isActive = true
        }
    }
    
    init() {
        super.init(frame: .zero)

        progressBar.layer.cornerRadius = 6
        progressParent.addSubview(progressBar)
        progressBar.pinToSuperview(edges: .leading).pinToSuperview(edges: .vertical, padding: 2)
        progressBar.widthAnchor.constraint(greaterThanOrEqualToConstant: 6).isActive = true

        checkIcon.setContentHuggingPriority(.required, for: .horizontal)
        checkIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let labelCheckStack = UIStackView(spacing: 6, [label, checkIcon])
        labelCheckStack.alignment = .center
        
        progressParent.addSubview(labelCheckStack)
        labelCheckStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview(axis: .vertical)
        label.font = .appFont(withSize: 15, weight: .regular)

        percentLabel.font = .appFont(withSize: 15, weight: .bold)
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        percentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [progressParent, percentLabel])
        hStack.alignment = .center
        hStack.spacing = 8

        addSubview(hStack)
        hStack.pinToSuperview()
        
        constrainToSize(height: 36)
        progressParent.constrainToSize(height: 36)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, votes: Int, totalVotes: Int, isSelected: Bool, didWin: Bool) {
        self.isSelected = isSelected
        percentage = totalVotes > 0 ? Double(votes) / Double(totalVotes) : 0
        
        checkIcon.isHidden = !didWin

        label.text = text
        label.font = .appFont(withSize: 15, weight: isSelected ? .bold : .regular)

        let pct = percentage * 100
        if pct == floor(pct) {
            percentLabel.text = "\(Int(pct))%"
        } else {
            percentLabel.text = String(format: "%.1f%%", pct)
        }

        progressConstraint = progressBar.widthAnchor.constraint(equalTo: progressParent.widthAnchor, multiplier: max(percentage, 0.001))
        progressBar.layer.cornerRadius = progressParent.frame.width * percentage > 12 ? 6 : 3

        updateTheme()
    }

    func updateTheme() {
        backgroundColor = .clear
        label.textColor = .foreground
        percentLabel.textColor = .foreground
        progressBar.backgroundColor = isSelected ? .accent : UIColor.foreground.withAlphaComponent(0.15)
        checkIcon.tintColor = .foreground
    }
}
