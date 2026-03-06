//
//  PollVotesViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import Combine
import UIKit
import GenericJSON

enum PollVotesTableCellType {
    case option(ParsedPoll.Option, PollOptionStats, isSelected: Bool)
    case optionsDetails(totalCount: Int, message: String)
    case voteTitle(String, count: Int)
    case vote(ParsedUser)
}

class PollVotesViewController: UIViewController, Themeable {
    private let table = UITableView()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
}

private extension PollVotesViewController {
    func setup() {
        title = "Votes"
        updateTheme()

        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.delegate = self
        table.separatorStyle = .none
        table.register(PollVoteUserCell.self, forCellReuseIdentifier: "vote")
        table.register(EmptyTableViewCell.self, forCellReuseIdentifier: "empty")
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
