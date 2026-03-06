//
//  PollVotesDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import UIKit

enum PollVotesTableCellType: Hashable {
    case option(ParsedPoll.Option, PollOptionStats, isSelected: Bool)
    case optionsDetails(totalCount: Int, message: String)
    case voteTitle(String, count: Int)
    case vote(ParsedUser)
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
                    cell.configure(
                        option: option,
                        stats: stats,
                        totalVotes: delegate.totalVotes,
                        maxVotes: delegate.maxVotes,
                        isSelected: isSelected,
                        userVote: delegate.userVote,
                        didEnd: delegate.didEnd
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
            case let .vote(user):
                let cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath)
                (cell as? PollVoteUserCell)?.updateForUser(user)
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
    var totalVotes: Int { get }
    var maxVotes: Int { get }
    var userVote: String? { get }
    var didEnd: Bool { get }
}
