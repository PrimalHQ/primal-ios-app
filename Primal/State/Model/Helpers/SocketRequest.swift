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
            Connection.regular.requestCache(name: name, payload: payload) { result in
                result.compactMap { $0.arrayValue?.last?.objectValue } .forEach { pendingResult.handlePostEvent($0) }
                result.compactMap { $0.arrayValue?.last?.stringValue } .forEach { pendingResult.message = $0 }
                
                promise(.success(pendingResult))
            }
        }.eraseToAnyPublisher()
    }
}

extension PostRequestResult {
    func handlePostEvent(_ payload: [String: JSON]) {
        guard
            let kind = NostrKind(rawValue: Int(payload["kind"]?.doubleValue ?? -1337)),
            let contentString = payload["content"]?.stringValue
        else {
            print("UNKNOWN KIND")
            return
        }
        
        switch kind {
        case .metadata:
            let nostrUser = NostrContent(json: .object(payload))
            if let user = PrimalUser(nostrUser: nostrUser) {
                users[nostrUser.pubkey] = user
            }
        case .text:
            posts.append(NostrContent(jsonData: payload))
        case .noteStats:
            guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: Data(contentString.utf8)) else {
                print("Error decoding NostrContentStats to json")
                return
            }

            stats[nostrContentStats.event_id] = nostrContentStats
        case .notification:
            guard
                let json = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8)),
                let notification = PrimalNotification.fromJSON(json)
            else {
                print("Error decoding PrimalNotification to json")
                return
            }
            
            notifications.append(notification)
        case .paginationEvent:
            guard let pagination = try? JSONDecoder().decode(PrimalPagination.self, from: Data(contentString.utf8)) else {
                print("Error decoding PrimalSearchPagination to json")
                return
            }
            self.pagination = pagination
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
                WalletManager.instance.setZapUnknown(noteStatus.event_id)
            }
        case .repost:
            guard
                let pubKey = payload["pubkey"]?.stringValue,
                let dateNum = payload["created_at"]?.doubleValue,
                let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.isEmpty ? "{}".utf8 : contentString.utf8))
            else {
                print("Error decoding reposts string to json")
                return
            }
            
            let id = payload["id"]?.stringValue ?? ""
            
            reposts.append(.init(id: id, pubkey: pubKey, post: NostrContent(json: contentJSON), date: Date(timeIntervalSince1970: dateNum)))
        case .mentions:
            guard let contentJSON = try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8)) else {
                print("Error decoding mentions string to json")
                return
            }
            
            mentions.append(NostrContent(json: contentJSON))
        case .mediaMetadata:
            guard let metadata = try? JSONDecoder().decode(MediaMetadata.self, from: Data(contentString.utf8)) else {
                print("Error decoding metadata string to json")
                return
            }
            
            mediaMetadata.append(metadata)
        case .userScore:
            guard let info = try? JSONDecoder().decode([String: Int].self, from: Data(contentString.utf8)) else { return }
            
            userScore = info
        case .userFollowers:
            guard let info: [String: Int] = contentString.decode() else {
                print("Error decoding user followers")
                return
            }
            userFollowers = info
        case .userStats:
            guard let nostrUserProfileInfo: NostrUserProfileInfo = contentString.decode() else {
                print("Error decoding nostr stats string to json")
                return
            }
            userStats = nostrUserProfileInfo
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
                popularHashtags.append(.init(title: name, apperances: count))
            }
        case .timestamp:
            guard let timeStamp = Int(contentString) else {
                print("Error decoding timestamp")
                return
            }
            timestamps.append(.init(timeIntervalSince1970: TimeInterval(timeStamp)))
        case .webPreview:
            guard let webPreview = try? JSONDecoder().decode(WebPreviews.self, from: Data(contentString.utf8)) else {
                print("Error decoding webpreview")
                return
            }
            
            webPreviews.append(webPreview)
        case .followingUser:
            guard let isFollowing = Bool(contentString) else {
                print("Error decoding isFollowing response")
                return
            }
            
            isFollowingUser = isFollowing
        case .encryptedDirectMessage:
            guard
                let pubkey = payload["pubkey"]?.stringValue,
                let id = payload["id"]?.stringValue,
                let date = payload["created_at"]?.doubleValue,
                let recipientPubkey = payload["tags"]?.arrayValue?.first?.arrayValue?.last?.stringValue
            else {
                print("Error decoding encrypted message")
                return
            }
            encryptedMessages.append(.init(id: id, pubkey: pubkey, recipientPubkey: recipientPubkey, date: .init(timeIntervalSince1970: date), message: contentString))
        case .messagesMetadata:
            guard let chats = try? JSONDecoder().decode([String: ChatMetadata].self, from: Data(contentString.utf8)) else {
                print("Error decoding messagesMetadata")
                return
            }
            chatsMetadata = chats
        case .defaultRelays:
            messageArray = contentString.decode()
        default:
            print("Unhandled response \(payload)")
        }
    }
}

extension String {
    func decode<T: Codable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: Data(utf8))
        } catch {
            print("Error decoding \(T.self) from \(self) error \(error)")
        }
        return nil
    }
}

extension Encodable {
    func encodeToString() -> String? {
        do {
            let data = try JSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding \(self) error \(error)")
        }
        return nil
    }
}
