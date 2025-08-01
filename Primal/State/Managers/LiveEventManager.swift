//
//  LiveEventManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 7. 2025..
//

import Foundation
import GenericJSON
import Combine

struct ParsedLiveEvent: Hashable {
    var liveURL: String
    
    var creatorPubkey: String
    var dTag: String
    
    var title: String
    var summary: String
    var image: String
    
    var status: String
    
    var pubkey: String
    
    var participants: Int
    
    var event: [String: JSON]
}

class LiveEventManager {
    static let instance = LiveEventManager()
    
    @Published private var liveEvents: [String: ParsedLiveEvent] = [:]
    
    @MainActor
    func addLiveEvent(_ event: [String: JSON]) {
        guard
            let creatorPubkey = event["pubkey"]?.stringValue,
            let tags = event["tags"]?.arrayValue,
            let dTag = tags.tagValueForKey("d"),
            let live = tags.tagValueForKey("streaming")
        else { return }
        
        let pubkey = tags.tagValueForKeyWithRole("p", role: "host") ?? creatorPubkey
            
        liveEvents[pubkey] = .init(
            liveURL: live,
            creatorPubkey: creatorPubkey,
            dTag: dTag,
            title: tags.tagValueForKey("title") ?? "",
            summary: tags.tagValueForKey("summary") ?? "",
            image: tags.tagValueForKey("image") ?? "",
            status: tags.tagValueForKey("status") ?? "live",
            pubkey: pubkey,
            participants: Int(tags.tagValueForKey("current_participants") ?? "") ?? 1,
            event: event
        )
    }
    
    func liveEvent(for pubkey: String) -> ParsedLiveEvent? {
        return liveEvents[pubkey]
    }
}
