//
//  ExploreCategory.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.4.26..
//

import Foundation

enum ExploreCategory: Int, CaseIterable, SelectionItem {
    case people = 0
    case feeds = 1
    case zaps = 2
    case media = 3
    case topics = 4

    var selectionTitle: String {
        switch self {
        case .people: return "People"
        case .feeds:  return "Feeds"
        case .zaps:   return "Zaps"
        case .media:  return "Media"
        case .topics: return "Topics"
        }
    }
}
