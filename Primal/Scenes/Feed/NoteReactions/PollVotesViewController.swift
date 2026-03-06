//
//  PollVotesViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import Combine
import UIKit
import GenericJSON

class PollVotesViewController: UIViewController, Themeable {
    private let table = UITableView()
    private let emptyView = EmptyTableView(title: "There are no votes for this option yet")
    private let tabSelectionView: TabSelectionView

    private let eventId: String
    private let poll: ParsedPoll
    private let pollStats: PollStats?

    private var users: [ParsedUser] = [] {
        didSet {
            table.reloadData()
            emptyView.isHidden = !users.isEmpty
        }
    }

    private var cancellables: Set<AnyCancellable> = []
    private var paginationInfo: PrimalPagination?
    private var isRequestingNewPage = false
    private var didReachEnd = false

    private var selectedOptionIndex = 0

    init(eventId: String, poll: ParsedPoll, pollStats: PollStats?) {
        self.eventId = eventId
        self.poll = poll
        self.pollStats = pollStats

        let tabTitles = poll.options.map { option in
            let votes = pollStats?.options[option.id]?.votes ?? 0
            return "\(option.label) (\(votes))"
        }
        tabSelectionView = TabSelectionView(tabs: tabTitles, spacing: 8)

        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        view.backgroundColor = .background
        table.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
}

private extension PollVotesViewController {
    func setup() {
        title = "Poll Votes"
        updateTheme()

        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(PollVoteUserCell.self, forCellReuseIdentifier: "cell")

        let header = UIView()
        header.addSubview(tabSelectionView)
        tabSelectionView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical)
        header.layoutIfNeeded()
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        header.frame.size = CGSize(width: table.bounds.width, height: size.height)
        table.tableHeaderView = header

        view.addSubview(emptyView)
        emptyView.centerToSuperview()
        emptyView.isHidden = true
        emptyView.refresh.addAction(.init(handler: { [unowned self] _ in
            refresh()
        }), for: .touchUpInside)

        tabSelectionView.$selectedTab
            .removeDuplicates()
            .sink { [weak self] tab in
                guard let self else { return }
                selectedOptionIndex = tab
                refresh()
            }
            .store(in: &cancellables)
    }

    func refresh() {
        users = []
        paginationInfo = nil
        isRequestingNewPage = false
        didReachEnd = false
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
                    // Filter duplicates
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
            }
            .store(in: &cancellables)
    }
}

extension PollVotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? PollVoteUserCell)?.updateForUser(users[indexPath.row])
        return cell
    }
}

extension PollVotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[safe: indexPath.row] else { return }
        show(ProfileViewController(profile: user), sender: nil)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= users.count - 5 {
            requestNewPage()
        }
    }
}
