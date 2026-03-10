//
//  PollVotesDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

enum PollResultsVote: Hashable {
    case user(ParsedUser)
    case zap(ParsedUser, amount: Int)
}

enum PollVotesTableCellType: Hashable {
    case option(ParsedPoll.Option, PollOptionStats, isSelected: Bool)
    case optionsDetails(totalCount: Int, message: String)
    case voteTitle(String, count: Int)
    case vote(PollResultsVote)
}

class PollVotesDatasource: UITableViewDiffableDataSource<SingleSection, PollVotesTableCellType> {
    weak var delegate: PollVotesDatasourceDelegate?

    init(tableView: UITableView, delegate: PollVotesDatasourceDelegate) {
        self.delegate = delegate

        tableView.register(PollVoteOptionCell.self, forCellReuseIdentifier: "option")
        tableView.register(PollVoteDetailsCell.self, forCellReuseIdentifier: "details")
        tableView.register(PollVoteTitleCell.self, forCellReuseIdentifier: "title")
        tableView.register(PollVoteUserCell.self, forCellReuseIdentifier: "vote")

        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            switch item {
            case let .option(option, stats, isSelected):
                let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath)
                if let cell = cell as? PollVoteOptionCell, let delegate {
                    let optionValue = delegate.isZapPoll ? stats.satszapped : stats.votes
                    let didWin = optionValue == delegate.maxValue
                    let didEnd = delegate.didEnd
                    let valueLabel: NSAttributedString
                    if delegate.isZapPoll {
                        valueLabel = .satsString(optionValue, fontSize: 15)
                    } else {
                        let pct = delegate.total > 0 ? Double(stats.votes) / Double(delegate.total) * 100 : 0
                        let pctText = pct == floor(pct) ? "\(Int(pct))%" : String(format: "%.1f%%", pct)
                        valueLabel = .init(string: pctText, attributes: [
                            .font: UIFont.appFont(withSize: 15, weight: .semibold),
                            .foregroundColor: didEnd && !didWin ? UIColor.foreground3 : UIColor.foreground
                        ])
                    }
                    cell.configure(
                        option: option,
                        optionValue: optionValue,
                        total: delegate.total,
                        maxValue: delegate.maxValue,
                        valueLabel: valueLabel,
                        isSelected: isSelected,
                        userVote: delegate.userVote,
                        didEnd: didEnd
                    )
                }
                return cell
            case let .optionsDetails(totalCount, message):
                let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath)
                (cell as? PollVoteDetailsCell)?.configure(totalCount: totalCount, message: message)
                return cell
            case let .voteTitle(title, count):
                let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
                (cell as? PollVoteTitleCell)?.configure(title: title, count: count)
                return cell
            case let .vote(vote):
                let cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath)
                switch vote {
                case let .user(user):
                    (cell as? PollVoteUserCell)?.updateForUser(user)
                case let .zap(user, amount):
                    (cell as? PollVoteUserCell)?.updateForUser(user)
                }
                return cell
            }
        }

        defaultRowAnimation = .none
    }

    func setItems(_ items: [PollVotesTableCellType]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, PollVotesTableCellType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        apply(snapshot, animatingDifferences: false)
    }
}

protocol PollVotesDatasourceDelegate: AnyObject {
    var total: Int { get }
    var maxValue: Int { get }
    var isZapPoll: Bool { get }
    var userVote: String? { get }
    var didEnd: Bool { get }
}
