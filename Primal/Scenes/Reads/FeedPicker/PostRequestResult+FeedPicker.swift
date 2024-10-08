//
//  PostRequestResult+FeedPicker.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import Foundation
import GenericJSON

struct FeedFromMarket: Codable {
    let amount: String?
    let personalized: Bool?
    let picture: String?
    let image: String?
    let name: String
    let about: String?
    var id: String?
    var lud16: String?
    var pubkey: String?
    var subscription: Bool?
}

struct FeedMetadata: Codable {
    let is_primal: Bool
    let kind: String
    let event_id: String
}

struct FeedFollowActions: Codable {
    let dvm_pubkey: String
    let users: [String]
    let dvm_kind: Int
    let dvm_id: String
}

struct ParsedFeedFromMarket {
    let data: FeedFromMarket
    let user: ParsedUser
    let metadata: FeedMetadata?
    let followActions: FeedFollowActions?
    let stats: NostrContentStats?
    let users: [ParsedUser]
}

extension PostRequestResult {
    func feeds() -> [ParsedFeedFromMarket] {
        let metadata: [FeedMetadata] = events
            .filter { $0["kind"]?.doubleValue == Double(NostrKind.dvmFeedMetadata.rawValue) }
            .compactMap { $0["content"]?.stringValue?.decode() }
        
        let followActions: [FeedFollowActions] = events
            .filter { $0["kind"]?.doubleValue == Double(NostrKind.dvmFollowActions.rawValue) }
            .compactMap { $0["content"]?.stringValue?.decode() }
        
        return events
            .filter { $0["kind"] == .number(Double(NostrKind.handlerInfo.rawValue)) }
            .compactMap { event in
                guard var feed: FeedFromMarket = event["content"]?.stringValue?.decode() else { return nil }
                
                let eventId = event["id"]?.stringValue
                
                feed.id = event["tags"]?
                    .arrayValue?.first(where: { $0.arrayValue?.first?.stringValue == "d" })?
                    .arrayValue?[safe: 1]?.stringValue
                
                feed.pubkey = event["pubkey"]?.stringValue
                
                let followAction = followActions.first(where: { $0.dvm_pubkey == feed.pubkey && $0.dvm_id == feed.id })
                
                return ParsedFeedFromMarket(
                    data: feed,
                    user: createParsedUser(users[feed.pubkey ?? ""] ?? .init(pubkey: feed.pubkey ?? "")), 
                    metadata: metadata.first(where: { $0.event_id == eventId }),
                    followActions: followAction,
                    stats: stats[eventId ?? ""],
                    users: followAction?.users.map { pubkey in createParsedUser(users[pubkey] ?? .init(pubkey: pubkey)) } ?? []
                )
            }
    }
}
