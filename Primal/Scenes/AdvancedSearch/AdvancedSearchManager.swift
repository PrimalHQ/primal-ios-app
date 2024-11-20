//
//  AdvancedSearchManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import Combine
import Foundation

protocol PickableEnum: CaseIterable, Equatable {
    var name: String { get }
    static var name: String { get }
}

enum SearchType {
    case notes, reads, noteReplies, readsComments, images, videos, sound
}

enum SearchScope {
    case global, myFollows, myNetwork, myFollowsInteractions, myNetworkInteractions, myNotifications, notMyFollows
}

enum SearchOrder {
    case time, contentScore, numberOfReplies, satsZapped, numberOfInteractions
}

enum TimePickerOption {
    case anytime, today, thisWeek, thisMonth, thisYear, custom(Date, Date)
}

struct SearchFilters: Codable {
    var minscore: Int?
    var mininteractions: Int?
    var minlikes: Int?
    var minzaps: Int?
    var minreplies: Int?
    var minreposts: Int?
    
    // Reads
    var minwords: Int?
    var maxwords: Int?
    
    // Images & Video
    var orientation: String?
    
    // Video & Audio
    var minduration: Int?
    var maxduration: Int?
}

extension PrimalFeed {
    var isFromAdvancedSearchScreen: Bool {
        spec.contains(" pas:1 ")
    }
}

class AdvancedSearchManager: ObservableObject {
    @Published var includeWordsText: String = ""
    @Published var excludeWordsText: String = ""
    
    @Published var searchType: SearchType = .notes
    @Published var searchScope: SearchScope = .global
    @Published var searchOrder: SearchOrder = .time
    
    @Published var postedBy: [ParsedUser] = []
    @Published var replyingTo: [ParsedUser] = []
    @Published var zappedBy: [ParsedUser] = []
    
    @Published var timePosted: TimePickerOption = .anytime
    @Published var filters: SearchFilters = .init()
    
    @Published var isFromAdvancedSearchScreen = false
    
    var feed: PrimalFeed {
        let query = generateQueryString().replacingOccurrences(of: "\"", with: "\\\"")
        
        let includeText = includeWordsText.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = includeText.isEmpty ? "Search Results" : "Search: \(includeText)"
        
        return PrimalFeed(
            name: title,
            spec: "{\"id\":\"advsearch\",\"query\":\"\(query)\"}",
            description: "Primal search results",
            feedkind: "search",
            enabled: true
        )
    }
    
    func generateQueryString() -> String {
        var string = searchType.configurationString
        
        if !includeWordsText.isEmpty {
            let words = getWords(includeWordsText)
            for word in words {
                string += " \(word)"
            }
        }
        
        if !excludeWordsText.isEmpty {
            let words = getWords(excludeWordsText)
            for word in words {
                string += " -\(word)"
            }
        }
        
        let possibleConfigs: [String?] = [
            postedBy.configurationString(modifier: "from"),
            replyingTo.configurationString(modifier: "to"),
            zappedBy.configurationString(modifier: "zappedby"),
            searchScope.configurationString,
            searchOrder.configurationString,
            filters.configurationString(type: searchType),
            timePosted.configurationString,
        ]
        
        for config in possibleConfigs {
            if let config {
                string += " \(config)"
            }
        }
        
        if isFromAdvancedSearchScreen {
            string += " pas:1 "
        }
        
        return string
    }
    
    func getWords(_ string: String) -> [String] {
        let components = splitQuotations(string).enumerated()
        
        let quoted = components.filter { $0.offset % 2 != 0 }.map { "\"\($0.element)\"" }
        let regular = components.filter { $0.offset % 2 == 0 }.map { $0.element }

        let words = regular
            .map { $0.split(separator: " ") }
            .flatMap { $0 }
            .map { String($0) }
            .filter { !$0.isEmpty }
            
        return words + quoted
    }
    
    func splitQuotations(_ string: String) -> [String] {
        let pattern = "[\"'‘’“”]"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [string] }
            
        let modifiedText = regex.stringByReplacingMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string), withTemplate: "|")

        return modifiedText.components(separatedBy: "|")
    }
}

extension SearchType: PickableEnum {
    static var name: String { "Search" }
    
    var name: String {
        switch self {
        case .notes:            return "Notes"
        case .reads:            return "Reads"
        case .noteReplies:      return "Note Replies"
        case .readsComments:    return "Reads Comments"
        case .images:           return "Images"
        case .videos:           return "Videos"
        case .sound:            return "Sound"
        }
    }
}

extension SearchScope: PickableEnum {
    static var name: String { "Scope" }
    
    var name: String {
        switch self {
        case .global:                   return "Global"
        case .myFollows:                return "My Follows"
        case .myNetwork:                return "My Network"
        case .myFollowsInteractions:    return "My Follows Interactions"
        case .myNetworkInteractions:    return "My Network Interactions"
        case .notMyFollows:             return "Not My Follows"
        case .myNotifications:          return "My Notifications"
        }
    }
}

extension SearchOrder: PickableEnum {
    static var name: String { "Order By" }
    
    var name: String {
        switch self {
        case .time:                 return "Time"
        case .contentScore:         return "Content Score"
        case .numberOfReplies:      return "Number Of Replies"
        case .satsZapped:           return "Sats Zapped"
        case .numberOfInteractions: return "Number Of Interactions"
        }
    }
}

extension TimePickerOption: PickableEnum {
    static var allCases: [TimePickerOption] { [.anytime, .today, .thisWeek, .thisMonth, .thisYear] }
    
    var name: String {
        switch self {
        case .anytime:      return "Anytime"
        case .today:        return "Today"
        case .thisWeek:     return "This Week"
        case .thisMonth:    return "This Month"
        case .thisYear:     return "This Year"
        case .custom:       return "Custom"
        }
    }
    
    static var name: String { "Time Posted" }
}

// MARK: - Configuration string

private extension Array where Element: ParsedUser {
    func configurationString(modifier: String) -> String? {
        if isEmpty { return nil }
        
        let npubs = map { "\(modifier):\($0.data.npub)" }.joined(separator: " OR ")
        
        if count == 1 {
            return npubs
        }
        return "(\(npubs))"
    }
}

extension SearchType {
    var configurationString: String {
        switch self {
        case .notes:            return "kind:1"
        case .reads:            return "kind:30023"
        case .noteReplies:      return "kind:1 repliestokind:1"
        case .readsComments:    return "kind:1 repliestokind:30023"
        case .images:           return "filter:image"
        case .videos:           return "filter:video"
        case .sound:            return "filter:audio"
        }
    }
}

extension SearchScope {
    var configurationString: String? {
        switch self {
        case .global:                   return nil
        case .myFollows:                return "scope:myfollows"
        case .myNetwork:                return "scope:mynetwork"
        case .myFollowsInteractions:    return "scope:myfollowinteractions"
        case .myNetworkInteractions:    return "scope:mynetworkinteractions"
        case .notMyFollows:             return "scope:notmyfollows"
        case .myNotifications:          return "scope:mynotifications"
        }
    }
}

extension SearchOrder {
    var configurationString: String? {
        switch self {
        case .time:                 return nil
        case .contentScore:         return "orderby:score"
        case .numberOfReplies:      return "orderby:replies"
        case .satsZapped:           return "orderby:satszapped"
        case .numberOfInteractions: return "orderby:likes"
        }
    }
}

extension TimePickerOption {
    var configurationString: String? {
        switch self {
        case .anytime:                  return nil
        case .today:                    return "since:yesterday"
        case .thisWeek:                 return "since:lastweek"
        case .thisMonth:                return "since:lastmonth"
        case .thisYear:                 return "since:lastyear"
        case let .custom(start, end):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm"
            
            var string = ""
//            if let start {
                string += "since:\(dateFormatter.string(from: start))"
//            }
//            if let end {
                string += " until:\(dateFormatter.string(from: end))"
//            }
        
            return string.isEmpty ? nil : string
        }
    }
}

extension SearchFilters {
    func configurationString(type: SearchType) -> String? {
        var copy = self
        
        switch type {
        case .notes, .noteReplies, .readsComments:
            copy.minduration = nil
            copy.maxduration = nil
            copy.minwords = nil
            copy.maxwords = nil
            copy.orientation = nil
        case .reads:
            copy.minduration = nil
            copy.maxduration = nil
            copy.orientation = nil
        case .images:
            copy.minduration = nil
            copy.maxduration = nil
            copy.minwords = nil
            copy.maxwords = nil
        case .videos:
            copy.minwords = nil
            copy.maxwords = nil
        case .sound:
            copy.minwords = nil
            copy.maxwords = nil
            copy.orientation = nil
        }
        
        // We drop '{' and '}' characters
        guard 
            let string = copy.encodeToString()?
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: ",", with: " ")
                .dropFirst().dropLast(),
            !string.isEmpty
        else { return nil }

        return string.string
    }
}
