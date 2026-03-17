//
//  PollResultsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import Combine
import UIKit

class PollResultsViewController: UIViewController, Themeable {
    private let table = UITableView()
    private lazy var datasource = PollVotesDatasource(tableView: table, delegate: self)

    private let eventId: String
    private let poll: ParsedPoll
    private var pollStats: PollStats?

    private var cachedFeedManagers: [String: PollVotesFeedManager] = [:]
    private var feedManager: PollVotesFeedManager?
    private var cancellables: Set<AnyCancellable> = []
    var feedUpdate: AnyCancellable?

    private var selectedOptionIndex = 0

    init(eventId: String, poll: ParsedPoll) {
        self.eventId = eventId
        self.poll = poll

        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        view.backgroundColor = .background2
        table.backgroundColor = .background2
        navigationItem.leftBarButtonItem = customBackButton
        table.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
}

// MARK: - PollVotesDatasourceDelegate

extension PollResultsViewController: PollVotesDatasourceDelegate {
    var total: Int { poll.isZapPoll ? (pollStats?.totalSatsZapped ?? 0) : (pollStats?.totalVotes ?? 0) }
    var maxValue: Int { poll.isZapPoll ? (pollStats?.maxSatsZapped ?? 0) : (pollStats?.maxVotes ?? 0) }
    var isZapPoll: Bool { poll.isZapPoll }
    var userVote: String? { PollManager.instance.userVotes[eventId] }
    var didEnd: Bool { poll.didEnd }
}

// MARK: - Private

private extension PollResultsViewController {
    func setup() {
        title = "Votes"
        updateTheme()

        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.delegate = self
        table.separatorStyle = .none
        table.dataSource = datasource

        PollManager.instance.statsPublisher(eventId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.pollStats = stats
                self?.reloadData(stats: stats)
            }
            .store(in: &cancellables)

        selectOption(0)
    }

    func reloadData(votes: [PollResultsVote]? = nil, stats: PollStats? = nil) {
        var items: [PollVotesTableCellType] = []
        let stats = stats ?? self.pollStats

        for (index, option) in poll.options.enumerated() {
            let stats = stats?.options[option.id] ?? PollOptionStats(votes: 0, satszapped: 0)
            items.append(.option(option, stats, isSelected: index == selectedOptionIndex))
        }

        var message: String = ""
        if let endsAt = poll.endsAt {
            message = endsAt > .now ? endsAt.timeLeftDisplay() : "Final results"
        }
        items.append(.optionsDetails(totalCount: pollStats?.totalVotes ?? 0, message: message))

        if let selectedOption = poll.options[safe: selectedOptionIndex] {
            let count = pollStats?.options[selectedOption.id]?.votes ?? 0
            items.append(.voteTitle(selectedOption.label, count: count))
        }
        
        let votes = votes ?? feedManager?.votes ?? []
        for vote in votes {
            items.append(.vote(vote))
        }

        datasource.setItems(items)
    }

    func selectOption(_ index: Int) {
        guard let option = poll.options[safe: index] else { return }
        selectedOptionIndex = index

        if let cachedFeed = cachedFeedManagers[option.id] {
            feedManager = cachedFeed
        } else {
            let newFeed = PollVotesFeedManager(eventId: eventId, optionId: option.id, isZapPoll: poll.isZapPoll)
            cachedFeedManagers[option.id] = newFeed
            feedManager = newFeed
        }
        
        feedUpdate = feedManager?.$votes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] votes in self?.reloadData(votes: votes) }
    }
}

// MARK: - UITableViewDelegate

extension PollResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .option(_, _, _):
            selectOption(indexPath.row)
        case .vote(let vote):
            switch vote {
            case .user(let user), .zap(let user, _):
                show(ProfileViewController(profile: user), sender: nil)
            }
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        if case .vote = item, indexPath.row >= datasource.snapshot().numberOfItems - 5 {
            feedManager?.requestNewPage()
        }
    }
}
