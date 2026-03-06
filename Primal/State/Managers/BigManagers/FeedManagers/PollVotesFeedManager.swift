//
//  PollVotesFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.3.26..
//

import Combine
import Foundation
import GenericJSON

class PollVotesFeedManager: BaseFeedManager {
    @Published private var usersTmp: [ParsedUser] = []
    @Published var users: [ParsedUser] = []

    private var cancellables: Set<AnyCancellable> = []

    init(eventId: String, optionId: String) {
        super.init(request: FeedManagerRequest(name: "poll_votes", body: [
            "event_id": .string(eventId),
            "option": .string(optionId),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ]))

        requestResultEmitter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }

                PollManager.instance.processPollVotesResponse(result)

                var newUsers = result.getSortedUsers()
                
                let missingUsers = result.events
                    .filter({ Int($0["kind"]?.doubleValue ?? 0) == NostrKind.pollVote.rawValue })
                    .compactMap({ $0["pubkey"]?.stringValue })
                    .unique()
                    .filter({ pubkey in !newUsers.contains(where: { $0.data.pubkey == pubkey }) })
                    .map { ParsedUser(data: .init(pubkey: $0)) }
                
                if !missingUsers.isEmpty {
                    newUsers.append(contentsOf: missingUsers)
                }

                if newUsers.isEmpty {
                    didReachEnd = true
                } else {
                    let existingPubkeys = Set(users.map { $0.data.pubkey })
                    let filtered = newUsers.filter { !existingPubkeys.contains($0.data.pubkey) }
                    usersTmp += filtered
                    users = usersTmp
                }
            }
            .store(in: &cancellables)
    }

    override func refresh() {
        usersTmp = []
        super.refresh()
    }
}
