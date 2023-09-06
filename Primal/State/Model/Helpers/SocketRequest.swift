//
//  SocketRequest.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import Combine
import Foundation
import GenericJSON

struct SocketRequest {
    let name: String
    let payload: JSON?
    
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
        guard
            let kind = NostrKind(rawValue: Int(payload["kind"]?.doubleValue ?? -1337)),
            let contentString = payload["content"]?.stringValue
        else { return }
        
        switch kind {
        case .metadata:
            let nostrUser = NostrContent(json: .object(payload))
            if let user = PrimalUser(nostrUser: nostrUser) {
                pendingResult.users[nostrUser.pubkey] = user
            }
        case .text:
            pendingResult.posts.append(NostrContent(jsonData: payload))
        case .noteStats:
            guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: Data(contentString.utf8)) else {
                print("Error decoding NostrContentStats to json")
                return
            }

            pendingResult.stats[nostrContentStats.event_id] = nostrContentStats
        case .notification:
            guard
                let json = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8)),
                let notification = PrimalNotification.fromJSON(json)
            else { return }
            
            pendingResult.notifications.append(notification)
        case .searchPaginationSettingsEvent:
            guard let _ = try? JSONDecoder().decode(PrimalSearchPagination.self, from: Data(contentString.utf8)) else {
                print("Error decoding PrimalSearchPagination to json")
                return
            }
//            print("SocketRequest: Got search pagination event")
        case .noteActions:
            guard let noteStatus = try? JSONDecoder().decode(PrimalNoteStatus.self, from: Data(contentString.utf8)) else {
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
                ZapManager.instance.userZapped[noteStatus.event_id] = 0
            }
        case .repost:
            guard
                let pubKey = payload["pubkey"]?.stringValue,
                let dateNum = payload["created_at"]?.doubleValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8))
            else {
                print("Error decoding reposts string to json")
                return
            }
            
            pendingResult.reposts.append(.init(pubkey: pubKey, post: NostrContent(json: contentJSON), date: Date(timeIntervalSince1970: dateNum)))
        case .mentions:
            guard let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8)) else {
                print("Error decoding mentions string to json")
                return
            }
            
            pendingResult.mentions.append(NostrContent(json: contentJSON))
        case .mediaMetadata:
            guard let metadata = try? JSONDecoder().decode(MediaMetadata.self, from: Data(contentString.utf8)) else {
                print("Error decoding metadata string to json")
                return
            }
            
            pendingResult.mediaMetadata.append(metadata)
        case .userScore:
            guard let info = try? JSONDecoder().decode([String: Int].self, from: Data(contentString.utf8)) else { return }
            
            pendingResult.userScore = info
        case .userStats:
            guard let nostrUserProfileInfo = try? JSONDecoder().decode(NostrUserProfileInfo.self, from: Data(contentString.utf8)) else {
                print("Error decoding nostr stats string to json")
                return
            }
            
            print(nostrUserProfileInfo)
        case .popular_hashtags:
            guard
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8)),
                case .array(let contentArray) = contentJSON
            else {
                print("Error decoding popular hashtags")
                return
            }
            
            for element in contentArray {
                guard
                    let object = element.objectValue,
                    let name = object.keys.first,
                    let count = object[name]?.doubleValue
                else { continue }
                pendingResult.popularHashtags.append(.init(title: name, apperances: count))
            }
        case .timestamp:
            guard let timeStamp = Int(contentString) else {
                print("Error decoding timestamp")
                return
            }
            pendingResult.timestamps.append(.init(timeIntervalSince1970: TimeInterval(timeStamp)))
        case .webPreview:
            guard let webPreview = try? JSONDecoder().decode(WebPreviews.self, from: Data(contentString.utf8)) else {
                print("Error decoding webpreview")
                return
            }
            
            pendingResult.webPreviews.append(webPreview)
        case .followingUser:
            guard let isFollowing = Bool(contentString) else {
                print("Error decoding isFollowing response")
                return
            }
            
            pendingResult.isFollowingUser = isFollowing
        case .encryptedDirectMessage:
            pendingResult.encryptedMessages.append(contentString)
        default:
            print("Unhandled response \(payload)")
        }
    }
}
