//
//  SocketRequest.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import Combine
import Foundation
import GenericJSON

public struct SocketRequest {
    let name: String
    let payload: JSON
    
    private let pendingResult: PostRequestResult = .init()
    
    func publisher() -> AnyPublisher<PostRequestResult, Never> {
        Future { promise in
            Connection.instance.requestCache(name: name, request: payload) { result in
                result.compactMap { $0.arrayValue?.last?.objectValue } .forEach { handlePostEvent($0) }
                promise(.success(pendingResult))
            }
        }.eraseToAnyPublisher()
    }
}

private extension SocketRequest {
    private func handlePostEvent(_ payload: [String: JSON]) {
        guard let kind = ResponseKind(rawValue: UInt32(payload["kind"]?.doubleValue ?? -1337)) else { return }
        
        switch kind {
        case .metadata:
            let nostrUser = NostrContent(json: .object(payload))
            if let user = PrimalUser(nostrUser: nostrUser) {
                pendingResult.users[nostrUser.pubkey] = user
            }
        case .text:
            pendingResult.posts.append(NostrContent(json: .object(payload)))
        case .noteStats:
            guard
                let content = payload["content"]?.stringValue,
                let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: Data(content.utf8))
            else {
                print("Error decoding NostrContentStats to json")
                return
            }
            
            pendingResult.stats[nostrContentStats.event_id] = nostrContentStats
        case .searchPaginationSettingsEvent:
            guard
                let content = payload["content"]?.stringValue,
                let searchPaginationEvent = try? JSONDecoder().decode(PrimalSearchPagination.self, from: Data(content.utf8))
            else {
                print("Error decoding PrimalSearchPagination to json")
                return
            }
//            searchPaginationEvent = searchPaginationEvent
        case .noteActions:
            guard
                let content = payload["content"]?.stringValue,
                let noteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: Data(content.utf8))
            else {
                print("Error decoding PrimalNoteStatus to json")
                return
            }
            
            if noteStatus.liked {
                LikeManager.instance.userLikes.insert(noteStatus.event_id)
            }
            if noteStatus.replied {
                PostManager.instance.userReplied.insert(noteStatus.event_id)
            }
            if noteStatus.reposted {
                PostManager.instance.userReposts.insert(noteStatus.event_id)
            }
            if noteStatus.zapped {
                PostManager.instance.userZapped.insert(noteStatus.event_id)
            }
            
        case .repost:
            guard
                let pubKey = payload["pubkey"]?.stringValue,
                let contentString = payload["content"]?.stringValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult.reposts.append(.init(pubkey: pubKey, post: NostrContent(json: contentJSON)))
        case .mentions:
            guard
                let contentString = payload["content"]?.stringValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult.mentions.append(NostrContent(json: contentJSON))
        case .mediaMetadata:
            guard
                let contentString = payload["content"]?.stringValue,
                let metadata = try? JSONDecoder().decode(MediaMetadata.self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult.mediaMetadata.append(metadata)
        case .userScore:
            guard
                let contentString = payload["content"]?.stringValue,
                let info = try? JSONDecoder().decode([String: Int].self, from: Data(contentString.utf8))
            else { return }
            
            pendingResult.userScore = info
        case .userStats:
            guard
                let contentString = payload["content"]?.stringValue,
                let nostrUserProfileInfo = try? JSONDecoder().decode(NostrUserProfileInfo.self, from: Data(contentString.utf8))
            else {
                print("Error decoding nostr stats string to json")
                return
            }
            
            print(nostrUserProfileInfo)
        default:
            assertionFailure("FeedManager: requestNewPage: Got unexpected event kind in response: \(payload)")
        }
    }
}
