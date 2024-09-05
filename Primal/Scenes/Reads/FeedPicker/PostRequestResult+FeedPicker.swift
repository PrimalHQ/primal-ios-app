//
//  PostRequestResult+FeedPicker.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import Foundation

struct FeedFromMarket: Codable {
    let amount: String?
    let personalized: Bool?
    let picture: String?
    let image: String?
    let name: String
    let about: String?
    var id: String?
    var pubkey: String?
    var subscription: Bool?
}

extension PostRequestResult {
    func feeds() -> [FeedFromMarket] {
        events
            .filter { $0["kind"] == .number(Double(NostrKind.handlerInfo.rawValue)) }
            .compactMap { event in
                guard var feed: FeedFromMarket = event["content"]?.stringValue?.decode() else { return nil }
                
                feed.id = event["tags"]?
                    .arrayValue?.first(where: { $0.arrayValue?.first?.stringValue == "d" })?
                    .arrayValue?[safe: 1]?.stringValue
                
                feed.pubkey = event["pubkey"]?.stringValue
                
                return feed
            }
    }
}
