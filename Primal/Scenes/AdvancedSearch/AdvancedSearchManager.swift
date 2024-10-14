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
    case global, myFollows, myNetwork, myFollowsInteractions
}

enum SearchOrder {
    case time, contentScore
}

enum TimePickerOption {
    case anytime, today, thisWeek, thisMonth, thisYear, custom(Date, Date)
}

class AdvancedSearchManager {
    @Published var searchType: SearchType = .notes
    @Published var searchScope: SearchScope = .global
    @Published var searchOrder: SearchOrder = .time
    
    @Published var postedBy: [ParsedUser] = []
    @Published var replyingTo: [ParsedUser] = []
    @Published var zappedBy: [ParsedUser] = []
    
    @Published var timePosted: TimePickerOption = .anytime
    @Published var filters: String?
    
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
        case .myFollowsInteractions:    return "My Follows Interaction"
        }
    }
}

extension SearchOrder: PickableEnum {
    static var name: String { "Order By" }
    
    var name: String {
        switch self {
        case .time:         return "Time"
        case .contentScore: return "Content Score"
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
