//
//  PollVotesViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import Combine
import UIKit
import GenericJSON

enum PollVotesTableCellType: Hashable {
    case option(ParsedPoll.Option, PollOptionStats, isSelected: Bool)
    case optionsDetails(totalCount: Int, message: String)
    case voteTitle(String, count: Int)
    case vote(ParsedUser)
}

class PollVotesViewController: UIViewController, Themeable {
    private let table = UITableView()
    private lazy var datasource = makeDatasource()

    private let eventId: String
    private let poll: ParsedPoll
    private var pollStats: PollStats?

    private var users: [ParsedUser] = []

    private var cancellables: Set<AnyCancellable> = []
    private var paginationInfo: PrimalPagination?
    private var isRequestingNewPage = false
    private var didReachEnd = false

    private var selectedOptionIndex = 0

    init(eventId: String, poll: ParsedPoll) {
        self.eventId = eventId
        self.poll = poll

        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        view.backgroundColor = .background
        table.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
}

// MARK: - Private

private extension PollVotesViewController {
    func setup() {
        title = "Votes"
        updateTheme()

        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.delegate = self
        table.separatorStyle = .none
        table.register(PollVoteOptionCell.self, forCellReuseIdentifier: "option")
        table.register(PollVoteDetailsCell.self, forCellReuseIdentifier: "details")
        table.register(PollVoteTitleCell.self, forCellReuseIdentifier: "title")
        table.register(PollVoteUserCell.self, forCellReuseIdentifier: "vote")

        table.dataSource = datasource

        PollManager.instance.$pollStats
            .compactMap { [eventId] in $0[eventId] }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.pollStats = stats
                self?.reloadData()
            }
            .store(in: &cancellables)

        PollManager.instance.statsPublisher(eventId)
            .sink { _ in }
            .store(in: &cancellables)

        refresh()
    }

    func makeDatasource() -> UITableViewDiffableDataSource<SingleSection, PollVotesTableCellType> {
        UITableViewDiffableDataSource(tableView: table) { [weak self] tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            switch item {
            case let .option(option, stats, isSelected):
                let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath)
                if let cell = cell as? PollVoteOptionCell {
                    let totalVotes = self.pollStats?.totalVotes ?? 0
                    let maxVotes = self.pollStats?.maxVotes ?? 0
                    let userVote = PollManager.instance.userVotes[self.eventId]
                    cell.configure(
                        option: option,
                        stats: stats,
                        totalVotes: totalVotes,
                        maxVotes: maxVotes,
                        isSelected: isSelected,
                        userVote: userVote,
                        didEnd: self.poll.didEnd
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
    }

    func reloadData() {
        var items: [PollVotesTableCellType] = []

        // Option rows
        for (index, option) in poll.options.enumerated() {
            let stats = pollStats?.options[option.id] ?? PollOptionStats(votes: 0, satszapped: 0)
            items.append(.option(option, stats, isSelected: index == selectedOptionIndex))
        }

        // Details row
        let totalVotes = pollStats?.totalVotes ?? 0
        let message: String
        if let endsAt = poll.endsAt {
            message = endsAt > .now ? endsAt.timeLeftDisplay() : "Final results"
        } else {
            message = ""
        }
        items.append(.optionsDetails(totalCount: totalVotes, message: message))

        // Vote title
        if let selectedOption = poll.options[safe: selectedOptionIndex] {
            let optionVotes = pollStats?.options[selectedOption.id]?.votes ?? 0
            items.append(.voteTitle(selectedOption.label, count: optionVotes))
        }

        // Vote user rows
        for user in users {
            items.append(.vote(user))
        }

        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, PollVotesTableCellType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        datasource.apply(snapshot, animatingDifferences: false)
    }

    func selectOption(_ index: Int) {
        guard index != selectedOptionIndex else { return }
        selectedOptionIndex = index
        refresh()
    }

    func refresh() {
        users = []
        paginationInfo = nil
        isRequestingNewPage = false
        didReachEnd = false
        reloadData()
        requestNewPage()
    }

    func requestNewPage() {
        guard !isRequestingNewPage, !didReachEnd else { return }
        guard let optionId = poll.options[safe: selectedOptionIndex]?.id else { return }

        isRequestingNewPage = true

        var payload: [String: JSON] = [
            "event_id": .string(eventId),
            "option": .string(optionId),
            "limit": .number(20),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ]

        if let until = paginationInfo?.since {
            payload["until"] = .number(until.rounded())
            payload["offset"] = .number(1)
        }

        SocketRequest(name: "poll_votes", payload: .object(payload)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                isRequestingNewPage = false

                PollManager.instance.processPollVotesResponse(result)

                let newUsers = result.getSortedUsers()

                if newUsers.isEmpty {
                    didReachEnd = true
                } else {
                    let existingPubkeys = Set(users.map { $0.data.pubkey })
                    let filtered = newUsers.filter { !existingPubkeys.contains($0.data.pubkey) }
                    users += filtered
                }

                if let pagination = result.pagination {
                    if var oldInfo = paginationInfo {
                        oldInfo.since = pagination.since
                        paginationInfo = oldInfo
                    } else {
                        paginationInfo = pagination
                    }
                } else {
                    didReachEnd = true
                }

                reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate

extension PollVotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .option(_, _, _):
            selectOption(indexPath.row)
        case .vote(let user):
            show(ProfileViewController(profile: user), sender: nil)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        if case .vote = item, indexPath.row >= datasource.snapshot().numberOfItems - 5 {
            requestNewPage()
        }
    }
}
