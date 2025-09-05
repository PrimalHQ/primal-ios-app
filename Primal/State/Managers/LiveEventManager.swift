//
//  LiveEventManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 7. 2025..
//

import Foundation
import GenericJSON
import Combine
import NostrSDK

struct ParsedLiveEvent: Hashable {
    let event: ProcessedLiveEvent
    let user: ParsedUser
    
    var title: String {
        let title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty { return user.data.firstIdentifier }
        return title
    }
}

enum LiveState: Hashable {
    case started(String)
    case ended(String?)
}

struct ProcessedLiveEvent: Hashable {
    var state: LiveState
    
    var creatorPubkey: String
    var dTag: String
    
    var title: String
    var summary: String
    var image: String
    
    var status: String
    
    var pubkey: String
    
    var participants: Int
    
    var starts: Date
    
    var event: [String: JSON]
    
    static func fromEvent(_ event: [String: JSON]) -> ProcessedLiveEvent? {
        guard
            let creatorPubkey = event["pubkey"]?.stringValue,
            let tags = event["tags"]?.arrayValue,
            let dTag = tags.tagValueForKey("d")
        else { return nil }
        
        let status = tags.tagValueForKey("status") ?? "live"
        
        let eventDate = Date(timeIntervalSince1970: event["created_at"]?.doubleValue ?? 0)
        let state: LiveState
        if status != "ended", let live = tags.tagValueForKey("streaming"), eventDate.isOneHourOld() {
            state = .started(live)
        } else {
            state = .ended(tags.tagValueForKey("recording") ?? tags.tagValueForKey("streaming"))
        }
        
        let pubkey = tags.tagValueForKeyWithRole("p", role: "host") ?? creatorPubkey
        
        let starts = Double(tags.tagValueForKey("starts") ?? "") ?? Date().timeIntervalSince1970
        
        return .init(
            state: state,
            creatorPubkey: creatorPubkey,
            dTag: dTag,
            title: tags.tagValueForKey("title") ?? "",
            summary: tags.tagValueForKey("summary") ?? "",
            image: tags.tagValueForKey("image") ?? "",
            status: status,
            pubkey: pubkey,
            participants: Int(tags.tagValueForKey("current_participants") ?? "") ?? 1,
            starts: Date(timeIntervalSince1970: starts),
            event: event
        )
    }
}
extension ProcessedLiveEvent: MetadataCoding {
    var universalID: String {
        "\(NostrKind.live.rawValue):\(pubkey):\(dTag)"
    }
    
    var creatorUniversalID: String {
        "\(NostrKind.live.rawValue):\(creatorPubkey):\(dTag)"
    }
    
    func noteId() -> String {
        var metadata = Metadata()
        let hint = RelayHintManager.instance.getRelayHint(universalID)
        if !hint.isEmpty {
            metadata.relays = [hint]
        }
        
        metadata.kind = UInt32(NostrKind.live.rawValue)
        metadata.pubkey = creatorPubkey
        metadata.identifier = dTag
        
        return (try? encodedIdentifier(with: metadata, identifierType: .address)) ?? bech32_note_id(event["id"]?.stringValue ?? "") ?? event["id"]?.stringValue ?? ""
    }
    
    var isLive: Bool {
        if case .started = state {
            return true
        }
        return false
    }
    
    var eventDate: Date { Date(timeIntervalSince1970: event["created_at"]?.doubleValue ?? 0) }
}

extension ParsedLiveEvent {
    var videoURL: String? {
        switch event.state {
        case .started(let string):
            return string
        case .ended(let string):
            return string
        }
    }
    
    var isLive: Bool { event.isLive }
    
    var startedText: String {
        if isLive {
            return "Started \(event.starts.timeAgoDisplay(addAgo: true))"
        }
        return "Streamed \(event.starts.timeAgoDisplay(addAgo: true))"
    }
}

class LiveEventManager {
    static let instance = LiveEventManager()
    
    @Published private var liveEvents: [String: ProcessedLiveEvent] = [:]
    @Published private var cachedUsers: [String: ParsedUser] = [:]
    
    var currentlyLiveFollowing: [ParsedUser] {
        var users: [ParsedUser] = []
        for (pubkey, event) in liveEvents {
            if event.isLive, event.eventDate.isOneHourOld(), let user = cachedUsers[pubkey], FollowManager.instance.isFollowing(pubkey), !LiveMuteManager.instance.isMuted(pubkey) {
                users.append(user)
            }
        }
        return users.sorted(by: { $0.followersSafe > $1.followersSafe })
    }
    
    var currentlyLiveFollowingPublisher: AnyPublisher<[ParsedUser], Never> {
        Publishers.CombineLatest3($liveEvents, $cachedUsers, LiveMuteManager.instance.$mutedPubkeys)
            .map { events, cachedUsers, mutedPubkeys in
                var users: [ParsedUser] = []
                for (pubkey, event) in events {
                    if event.isLive, event.eventDate.isOneHourOld(), let user = cachedUsers[pubkey], FollowManager.instance.isFollowing(pubkey), !mutedPubkeys.contains(pubkey) {
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
        guard let processed = ProcessedLiveEvent.fromEvent(event) else { return }
        
        if let oldEvent = liveEvents[processed.pubkey],  oldEvent.eventDate > processed.eventDate {
            return // Ignore older live events
        }
        
        liveEvents[processed.pubkey] = processed
        
        if cachedUsers[processed.pubkey] == nil {
            SocketRequest(name: "user_infos", payload: ["pubkeys": .array([.string(processed.pubkey)])]).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    for user in res.getSortedUsers() {
                        self?.cachedUsers[user.data.pubkey] = user
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func liveEvent(for pubkey: String) -> ProcessedLiveEvent? {
        return liveEvents[pubkey]
    }
    
    func user(for pubkey: String) -> ParsedUser? {
        cachedUsers[pubkey]
    }
}
