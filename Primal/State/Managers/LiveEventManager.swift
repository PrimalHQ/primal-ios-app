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
    @Published private var cachedUsers: [String: ParsedUser] = [:]
    
    var currentlyLiveFollowing: AnyPublisher<[ParsedUser], Never> {
        Publishers.CombineLatest($liveEvents, $cachedUsers)
            .map { events, cachedUsers in
                var users: [ParsedUser] = []
                for (pubkey, event) in events {
                    if let user = cachedUsers[pubkey], FollowManager.instance.isFollowing(pubkey) {
                        users.append(user)
                    }
                }
                return users.sorted(by: { $0.followersSafe > $1.followersSafe })
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var cancellables: Set<AnyCancellable> = []
    
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
        
        SocketRequest(name: "user_infos", payload: ["pubkeys": .array([.string(pubkey)])]).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                for user in res.getSortedUsers() {
                    self?.cachedUsers[user.data.pubkey] = user
                }
            }
            .store(in: &cancellables)
    }
    
    func liveEvent(for pubkey: String) -> ParsedLiveEvent? {
        return liveEvents[pubkey]
    }
}
