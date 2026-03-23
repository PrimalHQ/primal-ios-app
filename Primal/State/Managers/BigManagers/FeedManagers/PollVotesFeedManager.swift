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
    @Published private var votesTmp: [PollResultsVote] = []
    @Published var votes: [PollResultsVote] = []

    private var cancellables: Set<AnyCancellable> = []

    init(eventId: String, optionId: String, isZapPoll: Bool) {
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

                let newUsers = result.getSortedUsers()
                
                let newVotes: [PollResultsVote]
                if isZapPoll {
                    newVotes = result.zapReceipts
                        .compactMap { (receiptId, zapRequest) -> (String, Int)? in
                            guard let pubkey = zapRequest["pubkey"]?.stringValue else { return nil }

                            // Extract amount from bolt11 invoice in the zap receipt (matching Android)
                            let receiptTags = result.zapReceiptEvents[receiptId]?["tags"]?.arrayValue
                            if let bolt11 = receiptTags?.tagValueForKey("bolt11"),
                               let invoice = bolt11.invoiceFromString(),
                               let amountMsats = invoice.amount {
                                return (pubkey, Int(amountMsats / 1000))
                            }

                            // Fallback: amount tag in zap request
                            let amountString = zapRequest["tags"]?.arrayValue?.tagValueForKey("amount") ?? ""
                            let amount = (Int(amountString) ?? 0) / 1000
                            return (pubkey, amount)
                        }
                        .map { (pubkey, amount) -> (ParsedUser, Int) in
                            (newUsers.first(where: { $0.data.pubkey == pubkey }) ?? ParsedUser(data: .init(pubkey: pubkey)), amount)
                        }
                        .map { PollResultsVote.zap($0.0, amount: $0.1) }
                } else {
                    newVotes = result.events
                        .filter({ Int($0["kind"]?.doubleValue ?? 0) == NostrKind.pollVote.rawValue })
                        .compactMap({ $0["pubkey"]?.stringValue })
                        .unique()
                        .map { pubkey in newUsers.first(where: { $0.data.pubkey == pubkey }) ?? ParsedUser(data: .init(pubkey: pubkey)) }
                        .map { .user($0) }
                }
                
                if newVotes.isEmpty {
                    didReachEnd = true
                } else {
//                    let existingPubkeys = Set(users.map { $0.data.pubkey })
//                    let filtered = votingUsers.filter { !existingPubkeys.contains($0.data.pubkey) }
                    votesTmp += newVotes
                    votes = votesTmp
                }
            }
            .store(in: &cancellables)
        
        refresh()
    }

    override func refresh() {
        votesTmp = []
        super.refresh()
    }
}
