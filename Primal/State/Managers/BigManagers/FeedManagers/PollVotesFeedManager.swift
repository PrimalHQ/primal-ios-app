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

    init(eventId: String, optionId: String, isZapPoll: Bool) {
        let optionKey = isZapPoll ? "poll_option" : "option"
        super.init(request: FeedManagerRequest(name: "poll_votes", body: [
            "event_id": .string(eventId),
            optionKey: .string(optionId),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ]))

        requestResultEmitter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }

                PollManager.instance.processPollVotesResponse(result)

                let newUsers = result.getSortedUsers()
                
                let votingUsers: [ParsedUser]
                
                if isZapPoll {
                    votingUsers = result.zapReceipts.values
                        .compactMap { $0["pubkey"]?.stringValue }
                        .map { pubkey in newUsers.first(where: { $0.data.pubkey == pubkey }) ?? ParsedUser(data: .init(pubkey: pubkey)) }
                } else {
                    votingUsers = result.events
                        .filter({ Int($0["kind"]?.doubleValue ?? 0) == NostrKind.pollVote.rawValue })
                        .compactMap({ $0["pubkey"]?.stringValue })
                        .unique()
                        .map { pubkey in newUsers.first(where: { $0.data.pubkey == pubkey }) ?? ParsedUser(data: .init(pubkey: pubkey)) }
                }
                
                if votingUsers.isEmpty {
                    didReachEnd = true
                } else {
                    let existingPubkeys = Set(users.map { $0.data.pubkey })
                    let filtered = votingUsers.filter { !existingPubkeys.contains($0.data.pubkey) }
                    usersTmp += filtered
                    users = usersTmp
                }
            }
            .store(in: &cancellables)
        
        refresh()
    }

    override func refresh() {
        usersTmp = []
        super.refresh()
    }
}
