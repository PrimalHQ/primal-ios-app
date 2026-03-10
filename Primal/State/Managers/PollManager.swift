//
//  PollManager.swift
//  Primal
//
//  Created on 5.3.26..
//

import Combine
import Foundation
import GenericJSON

struct PollOptionStats: Codable, Hashable {
    let votes: Int
    let satszapped: Int
}

struct PollStats: Equatable {
    let eventId: String
    let options: [String: PollOptionStats]

    var maxVotes: Int { options.values.map({ $0.votes }).max() ?? -1 }
    var totalVotes: Int { options.values.reduce(0) { $0 + $1.votes } }
    var maxSatsZapped: Int { options.values.map({ $0.satszapped }).max() ?? -1 }
    var totalSatsZapped: Int { options.values.reduce(0) { $0 + $1.satszapped } }
}

final class PollManager {
    static let instance = PollManager()

    /// Poll event ID -> vote counts per option
    @Published var pollStats: [String: PollStats] = [:]

    /// Poll event ID -> option ID the current user voted for
    @Published var userVotes: [String: String] = [:]

    /// Tracks last fetch time per poll to throttle remote requests
    private var lastFetchTime: [String: Date] = [:]
    private let fetchCooldown: TimeInterval = 120 // 2 minutes

    var cancellables: Set<AnyCancellable> = []

    private init() {
        IdentityManager.instance.$user.map { $0?.pubkey }.removeDuplicates().receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.userVotes = [:]
                self?.lastFetchTime = [:]
            }
            .store(in: &cancellables)
    }

    func hasVoted(_ pollEventId: String) -> Bool {
        userVotes[pollEventId] != nil
    }

    func userVotePublisher(_ pollEventId: String) -> AnyPublisher<String?, Never> {
        $userVotes.map { $0[pollEventId] }.removeDuplicates().eraseToAnyPublisher()
    }

    /// Returns a publisher that emits cached stats immediately (if available),
    /// then fetches fresh stats from the server if the 2-minute cooldown has elapsed.
    func statsPublisher(_ pollEventId: String) -> AnyPublisher<PollStats?, Never> {
        let now = Date()
        if let last = lastFetchTime[pollEventId], now.timeIntervalSince(last) < fetchCooldown {
            // Cooldown active — just return cached value
        } else {
            lastFetchTime[pollEventId] = now
            fetchPollVotes(pollEventId)
        }

        return $pollStats.map { $0[pollEventId] }.removeDuplicates().eraseToAnyPublisher()
    }

    // MARK: - Fetch poll votes (returns poll stats + individual votes with paging)

    func fetchPollVotes(_ pollEventId: String, limit: Int = 20, until: Int? = nil) {
        var payload: [String: JSON] = [
            "event_id": .string(pollEventId),
            "limit": .number(Double(limit))
        ]

        if let until {
            payload["until"] = .number(Double(until))
        }

        SocketRequest(name: "poll_votes", payload: .object(payload)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.processPollVotesResponse(result)
            }
            .store(in: &cancellables)
    }

    // MARK: - Vote (regular poll)

    func vote(pollEventId: String, pollAuthorPubkey: String, optionId: String) {
        guard LoginManager.instance.method() == .nsec else { return }
        guard !hasVoted(pollEventId) else { return }

        userVotes[pollEventId] = optionId

        // Optimistic update: increment the local stats
        if var stats = pollStats[pollEventId] {
            var options = stats.options
            var optionStats = options[optionId] ?? PollOptionStats(votes: 0, satszapped: 0)
            optionStats = PollOptionStats(votes: optionStats.votes + 1, satszapped: optionStats.satszapped)
            options[optionId] = optionStats
            pollStats[pollEventId] = PollStats(eventId: stats.eventId, options: options)
        }

        guard let ev = NostrObject.pollVote(pollEventId: pollEventId, pollAuthorPubkey: pollAuthorPubkey, optionId: optionId) else {
            userVotes[pollEventId] = nil
            return
        }

        RelaysPostbox.instance.request(ev, successHandler: { [weak self] _ in
            self?.fetchPollVotes(pollEventId)
        }, errorHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.userVotes[pollEventId] = nil
                self?.fetchPollVotes(pollEventId)
            }
        })
    }

    // MARK: - Zap Vote (zap poll)

    func zapVote(pollEventId: String, pollAuthor: PrimalUser, optionId: String, sats: Int, message: String) {
        guard !hasVoted(pollEventId) else { return }

        guard let zap = NostrObject.zapPollVote(
            note: message,
            sats: sats,
            pollEventId: pollEventId,
            pollAuthorPubkey: pollAuthor.pubkey,
            optionId: optionId
        ) else {
            fetchPollVotes(pollEventId)
            return
        }
        
        userVotes[pollEventId] = optionId

        // Optimistic update: increment votes and sats
        var options = pollStats[pollEventId]?.options ?? [:]
        var optionStats = options[optionId] ?? PollOptionStats(votes: 0, satszapped: 0)
        optionStats = PollOptionStats(votes: optionStats.votes + 1, satszapped: optionStats.satszapped + sats)
        options[optionId] = optionStats
        pollStats[pollEventId] = PollStats(eventId: pollEventId, options: options)

        Task { @MainActor in
            do {
                try await WalletManager.instance.zapUser(pollAuthor, sats: sats, note: message, zap: zap)
            } catch {
                userVotes[pollEventId] = nil
                fetchPollVotes(pollEventId)
            }
        }
    }

    // MARK: - Process responses

    func processPollVotesResponse(_ result: PostRequestResult) {
        for response in result.events {
            guard
                let kind = NostrKind.fromGenericJSON(.object(response)), kind == .pollStats,
                let contentString = response["content"]?.stringValue
            else { continue }

            parsePollStatsContent(contentString)
        }
    }

    func parsePollStatsContent(_ contentString: String) {
        // Content format: {"<event_id>": {"option0": {"votes": N, "satszapped": N}, ...}}
        guard let dict: [String: [String: PollOptionStats]] = contentString.decode() else {
            print("Error decoding PollStats")
            return
        }

        for (eventId, options) in dict {
            pollStats[eventId] = PollStats(eventId: eventId, options: options)
        }
    }
}
