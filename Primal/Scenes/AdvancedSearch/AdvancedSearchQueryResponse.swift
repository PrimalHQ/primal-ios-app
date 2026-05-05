//
//  AdvancedSearchQueryResponse.swift
//  Primal
//
//  Mirrors Android's AdvancedSearchQueryResponse — the decoded payload
//  returned by the cache server's `parse_advanced_search_query` verb.
//

import Foundation

struct AdvancedSearchQueryResponse: Codable {
    var includes: String = ""
    var excludes: String = ""
    var hashtags: String = ""
    var kind: String = "Notes"
    var postedBy: [String] = []
    // Android serializes this field on the wire as "replingTo" (sic).
    var replyingTo: [String] = []
    var zappedBy: [String] = []
    var timeframe: String = "Anytime"
    var customTimeframe: CustomTimeframe = .init()
    var scope: String = "Global"
    var sortBy: String = "Time"
    var orientation: String = "Any"
    var minWords: Int = 0
    var maxWords: Int = 0
    var minDuration: Int = 0
    var maxDuration: Int = 0
    var minScore: Int = 0
    var minInteractions: Int = 0
    var minLikes: Int = 0
    var minZaps: Int = 0
    var minReplies: Int = 0
    var minReposts: Int = 0
    var following: [String] = []
    var userMentions: [String] = []
    var sentiment: String = "Neutral"

    struct CustomTimeframe: Codable {
        var since: String = ""
        var until: String = ""
    }

    enum CodingKeys: String, CodingKey {
        case includes, excludes, hashtags, kind, postedBy
        case replyingTo = "replingTo"
        case zappedBy, timeframe, customTimeframe, scope, sortBy, orientation
        case minWords, maxWords, minDuration, maxDuration, minScore
        case minInteractions, minLikes, minZaps, minReplies, minReposts
        case following, userMentions, sentiment
    }
}

extension PostRequestResult {
    var advancedSearchQuery: AdvancedSearchQueryResponse? {
        guard let event = events.first(where: {
            Int($0["kind"]?.doubleValue ?? 0) == NostrKind.parsedAdvancedSearch.rawValue
        }) else { return nil }

        return event["content"]?.stringValue?.decode()
    }
}
