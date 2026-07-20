//
//  AdvancedSearchManager+Populate.swift
//  Primal
//
//  Reverse-mapping from a saved advanced-search feed spec back into
//  AdvancedSearchManager state. Mirrors Android's parseEditingFeedSpec /
//  applyParsedQuery (AdvancedSearchViewModel.kt).
//

import Combine
import Foundation
import GenericJSON

extension AdvancedSearchManager {
    /// Issues `parse_advanced_search_query` against the cache server,
    /// then maps the response onto the manager's @Published state.
    /// Returns a publisher that completes once population is done.
    func loadAdvancedSearch(for feed: PrimalFeed) -> AnyPublisher<Void, Never> {
        guard
            let specJSON: JSON = feed.spec.decode(),
            let query = specJSON.objectValue?["query"]?.stringValue,
            !query.isEmpty
        else {
            return Just(()).eraseToAnyPublisher()
        }

        isLoadingEdit = true

        return SocketRequest(
            name: "parse_advanced_search_query",
            payload: ["query": .string(query)]
        )
        .publisher()
        .receive(on: DispatchQueue.main)
        .flatMap { [weak self] result -> AnyPublisher<Void, Never> in
            guard let self, let parsed = result.advancedSearchQuery else {
                self?.isLoadingEdit = false
                return Just(()).eraseToAnyPublisher()
            }
            return self.apply(parsed: parsed)
        }
        .handleEvents(receiveOutput: { [weak self] in
            self?.isLoadingEdit = false
        })
        .eraseToAnyPublisher()
    }

    /// Applies parsed fields onto the manager. The user-list fields
    /// (postedBy / replyingTo / zappedBy) involve an async profile fetch;
    /// the returned publisher fires once those resolve (or immediately if
    /// none were requested).
    func apply(parsed: AdvancedSearchQueryResponse) -> AnyPublisher<Void, Never> {
        includeWordsText = Self.composeIncludeText(words: parsed.includes, hashtags: parsed.hashtags)
        excludeWordsText = parsed.excludes
        searchType = Self.searchType(from: parsed.kind)
        searchScope = Self.searchScope(from: parsed.scope)
        searchOrder = Self.searchOrder(from: parsed.sortBy)
        timePosted = Self.timePosted(from: parsed)
        filters = Self.filters(from: parsed)
        isFromAdvancedSearchScreen = true

        let postedByPublisher = Self.fetchUsers(pubkeys: parsed.postedBy)
        let replyingToPublisher = Self.fetchUsers(pubkeys: parsed.replyingTo)
        let zappedByPublisher = Self.fetchUsers(pubkeys: parsed.zappedBy)

        return Publishers.Zip3(postedByPublisher, replyingToPublisher, zappedByPublisher)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] postedBy, replyingTo, zappedBy in
                guard let self else { return }
                self.postedBy = postedBy
                self.replyingTo = replyingTo
                self.zappedBy = zappedBy
            })
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

private extension AdvancedSearchManager {
    static func composeIncludeText(words: String, hashtags: String) -> String {
        let trimmedWords = words.trimmingCharacters(in: .whitespacesAndNewlines)
        let tagTokens = hashtags
            .split(whereSeparator: { $0.isWhitespace })
            .map { "#\($0)" }
            .joined(separator: " ")

        switch (trimmedWords.isEmpty, tagTokens.isEmpty) {
        case (true, true):    return ""
        case (false, true):   return trimmedWords
        case (true, false):   return tagTokens
        case (false, false):  return "\(trimmedWords) \(tagTokens)"
        }
    }

    static func searchType(from raw: String) -> SearchType {
        switch raw {
        case "Notes":           return .notes
        case "Reads":           return .reads
        case "Note Replies":    return .noteReplies
        case "Reads Comments":  return .readsComments
        case "Images":          return .images
        case "Video":           return .videos     // Android wire spelling
        case "Audio":           return .sound
        default:                return .notes
        }
    }

    static func searchScope(from raw: String) -> SearchScope {
        switch raw {
        case "Global":                   return .global
        case "My Follows":               return .myFollows
        case "My Network":               return .myNetwork
        case "My Notifications":         return .myNotifications
        case "My Follows Interactions":  return .myFollowsInteractions
        case "My Network Interactions":  return .myNetworkInteractions
        case "Not My Follows":           return .notMyFollows
        default:                         return .global
        }
    }

    static func searchOrder(from raw: String) -> SearchOrder {
        switch raw {
        case "Time":                    return .time
        case "Content Score":           return .contentScore
        case "Number of Replies":       return .numberOfReplies
        case "Sats Zapped":             return .satsZapped
        case "Number of Interactions":  return .numberOfInteractions
        default:                        return .time
        }
    }

    static func timePosted(from parsed: AdvancedSearchQueryResponse) -> TimePickerOption {
        let since = parsed.customTimeframe.since
        let until = parsed.customTimeframe.until
        if !since.isEmpty, !until.isEmpty,
           let start = Self.parseDate(since),
           let end = Self.parseDate(until) {
            return .custom(start, end)
        }

        switch parsed.timeframe {
        case "Anytime":     return .anytime
        case "Today":       return .today
        case "This Week":   return .thisWeek
        case "This Month":  return .thisMonth
        case "This Year":   return .thisYear
        default:            return .anytime
        }
    }

    static func parseDate(_ string: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: string) { return d }

        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: string) { return d }

        // Fallback to the format the iOS client emits in queries
        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd_HH:mm"
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        return fallback.date(from: string)
    }

    static func filters(from parsed: AdvancedSearchQueryResponse) -> SearchFilters {
        SearchFilters(
            minscore: parsed.minScore > 0 ? parsed.minScore : nil,
            mininteractions: parsed.minInteractions > 0 ? parsed.minInteractions : nil,
            minlikes: parsed.minLikes > 0 ? parsed.minLikes : nil,
            minzaps: parsed.minZaps > 0 ? parsed.minZaps : nil,
            minreplies: parsed.minReplies > 0 ? parsed.minReplies : nil,
            minreposts: parsed.minReposts > 0 ? parsed.minReposts : nil,
            minwords: parsed.minWords > 0 ? parsed.minWords : nil,
            maxwords: parsed.maxWords > 0 ? parsed.maxWords : nil,
            orientation: orientationRaw(from: parsed.orientation),
            minduration: parsed.minDuration > 0 ? parsed.minDuration : nil,
            maxduration: parsed.maxDuration > 0 ? parsed.maxDuration : nil
        )
    }

    static func orientationRaw(from raw: String) -> String? {
        switch raw {
        case "Horizontal": return FilterOrientation.horizontal.rawValue
        case "Vertical":   return FilterOrientation.vertical.rawValue
        default:           return nil
        }
    }

    static func fetchUsers(pubkeys: [String]) -> AnyPublisher<[ParsedUser], Never> {
        guard !pubkeys.isEmpty else {
            return Just([]).eraseToAnyPublisher()
        }

        return SocketRequest(
            name: "user_infos",
            payload: ["pubkeys": .array(pubkeys.map { .string($0) })]
        )
        .publisher()
        .map { result -> [ParsedUser] in
            let users = result.getSortedUsers()
            // Preserve the order returned by the server's parse response.
            return pubkeys.map { pubkey in
                users.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
            }
        }
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
}
