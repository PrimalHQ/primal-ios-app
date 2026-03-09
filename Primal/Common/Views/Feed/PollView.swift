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
    private let separatorLabel = UILabel()
    let totalVotesButton = UIButton()
    
    private var content: ParsedContent?
    private var showResults: Bool?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateForContent(_ content: ParsedContent, showResults: Bool? = nil) {
        guard let poll = content.poll else { return }

        self.content = content
        self.showResults = showResults

        cancellables = []

        updateExpiration(poll)

        Publishers.CombineLatest(
            PollManager.instance.statsPublisher(content.post.id),
            PollManager.instance.userVotePublisher(content.post.id)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] stats, userVote in
            self?.render(poll: poll, stats: stats, userVote: userVote, showResults: showResults)
        }
        .store(in: &cancellables)
    }

    func updateTheme() {
        expirationLabel.textColor = .foreground4
        separatorLabel.textColor = .foreground4

        guard let content, let poll = content.poll else { return }
        
        let stats = PollManager.instance.pollStats[content.post.id]
        let userVote = PollManager.instance.userVotes[content.post.id]
        render(poll: poll, stats: stats, userVote: userVote, showResults: showResults)
    }
}

// MARK: - Private

private extension PollView {
    var isExpired: Bool {
        guard let endsAt = content?.poll?.endsAt else { return false }
        return endsAt <= Date()
    }

    func render(poll: ParsedPoll, stats: PollStats?, userVote: String?, showResults: Bool?) {
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
                    guard let self, let content = self.content, let poll = content.poll else { return }
                    if poll.isZapPoll {
                        self.presentZapVote(pollEventId: content.post.id, pollAuthor: content.user.data, optionId: option.id, poll: poll)
                    } else {
                        PollManager.instance.vote(pollEventId: content.post.id, pollAuthorPubkey: content.user.data.pubkey, optionId: option.id)
                    }
                }), for: .touchUpInside)
                optionsStack.addArrangedSubview(row)
            }
        }

        if totalVotes > 0 {
            var config = UIButton.Configuration.accent(totalVotes == 1 ? "1 vote" : "\(totalVotes) votes", font: .appFont(withSize: 12, weight: .regular))
            config.contentInsets = .zero
            totalVotesButton.configuration = config
            totalVotesButton.isHidden = false
            separatorLabel.isHidden = expirationLabel.isHidden
        } else {
            totalVotesButton.isHidden = true
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
                expirationLabel.text = "Final Results"
            }
        } else {
            expirationLabel.isHidden = true
        }
    }

    func setup() {
        expirationLabel.font = .appFont(withSize: 12, weight: .regular)
        totalVotesButton.isHidden = true
        separatorLabel.font = .appFont(withSize: 14, weight: .heavy)
        separatorLabel.text = "•"
        separatorLabel.isHidden = true

        optionsStack.spacing = 10

        let bottomStack = UIStackView(arrangedSubviews: [totalVotesButton, separatorLabel, expirationLabel, UIView()])
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
    let zapIcon = UIImageView(image: .zapPollZapIcon)
    
    init() {
        super.init(frame: .zero)
        
        layer.borderWidth = 1
        layer.cornerRadius = 18
        constrainToSize(height: 36)
        updateTheme()
        
        addSubview(zapIcon)
        zapIcon.pinToSuperview(edges: .trailing, padding: 10).centerToSuperview(axis: .vertical)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, isZap: Bool) {
        self.text = text
        zapIcon.isHidden = !isZap
        updateTheme()
    }

    func updateTheme() {
        zapIcon.tintColor = .foreground6
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
        
        let labelCheckStack = UIStackView([label, checkIcon, UIView()])
        labelCheckStack.alignment = .center
        labelCheckStack.setCustomSpacing(6, after: label)
        
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
        progressBar.layer.cornerRadius = 300 * percentage > 12 ? 6 : 3

        updateTheme()
    }

    func updateTheme() {
        backgroundColor = .clear
        label.textColor = .foreground
        percentLabel.textColor = .foreground
        progressBar.backgroundColor = isSelected ? .accent : UIColor.foreground6
        progressBar.alpha = Theme.current.isLightTheme ? 0.5 : 1
        checkIcon.tintColor = .foreground
    }
}
