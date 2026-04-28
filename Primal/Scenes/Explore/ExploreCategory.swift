//
//  ExploreCategory.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.4.26..
//

import Foundation

enum ExploreCategory: Int, CaseIterable, SelectionItem {
    case people = 0
    case feeds  = 1
    case followPacks = 2
    case zaps   = 3
    case media  = 4

    var selectionTitle: String {
        switch self {
        case .people: return "Explore"
        case .feeds:  return "Feed Gallery"
        case .followPacks: return "Follow Packs"
        case .zaps:   return "Zaps"
        case .media:  return "Media"
        }
    }

    var selectionSubtitle: String? {
        switch self {
        case .people: return "Find people, feeds, media"
        case .feeds:  return "Browse feed gallery"
        case .followPacks: return "Curated lists of users to follow"
        case .zaps:   return "Top zaps on Nostr today"
        case .media:  return "Top images and videos on Nostr today"
        }
    }
}
