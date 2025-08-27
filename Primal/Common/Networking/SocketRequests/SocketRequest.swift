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
    let url: URL = URL(string: "https://cache2.primal.net/api/")!
    
    var useHTTP = false
    let name: String
    let payload: JSON?
    
    var connection = Connection.regular
    
    var body: JSON {
        if let payload {
            return [.string(name), payload]
        }
        return [.string(name)]
    }
    
    func httpPublisher() -> AnyPublisher<[JSON], Error> {
        Future { promise in
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            
            if let requestBody = try? JSONEncoder().encode(body) {
                request.httpMethod = "POST"
                request.httpBody = requestBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            URLSession(configuration: .default).dataTask(with: request) { data, response, error in
                guard let data else {
                    promise(.failure(error ?? RequestError.noData))
                    return
                }
                
                let decoder = JSONDecoder()

                do {
                    let responseData = try decoder.decode([JSON].self, from: data)
                    promise(.success(responseData))
                } catch {
                    if let errorData = try? decoder.decode(RequestErrorResponse.self, from: data) {
                        promise(.failure(errorData.error))
                    } else {
                        promise(.failure(error))
                    }
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
    }
    
    func publisher() -> AnyPublisher<PostRequestResult, Never> {
        connection.autoConnectReset()
        
        return Deferred {
            Future { promise in
                connection.requestCache(name: name, payload: payload) { result in
                    let pendingResult = PostRequestResult()
                    
                    result.compactMap { $0.objectValue } .forEach { pendingResult.handlePostEvent($0) }
                    result.compactMap { $0.stringValue } .forEach { pendingResult.message = $0 }
                    
                    pendingResult.postZaps.sort(by: { $0.amount_sats > $1.amount_sats })
                    
                    DatabaseManager.instance.saveProfiles(Array(pendingResult.users.values))
                    DatabaseManager.instance.saveMediaResources(pendingResult.mediaMetadata.flatMap { $0.resources })
//                    DatabaseManager.instance.saveProfileFollowers(pendingResult.userScore) Not sure if this is good
                    DatabaseManager.instance.saveProfileFollowers(pendingResult.userFollowers)
                    
                    promise(.success(pendingResult))
                }
            }
        }
        .waitForConnection(connection)
        .eraseToAnyPublisher()
    }
}

extension PostRequestResult {
    func handlePostEvent(_ payload: [String: JSON]) {
        guard let kind = NostrKind(rawValue: Int(payload["kind"]?.doubleValue ?? -1337)) else {
            print("UNKNOWN KIND")
            return
        }
        
        // MARK: - HASN'T CONTENT
        switch kind {
        case .relays:
            guard let jsonArray = payload["tags"]?.arrayValue else { 
                print("Error decoding relays from json")
                return
            }

            let relayTagContent = jsonArray.compactMap { $0.arrayValue }.filter { $0.first == "r" }

            let allRelays: [String: RelayInfo] = relayTagContent.map({ $0.dropFirst() }).reduce(into: [:]) { partialResult, jsonArray in
                guard let url = jsonArray.first?.stringValue else { return }
                if jsonArray.last?.stringValue == "read" || jsonArray.last?.stringValue == jsonArray.first?.stringValue {
                    partialResult[url, default: .init(read: false, write: false)].read = true
                }
                if jsonArray.last?.stringValue == "write" || jsonArray.last?.stringValue == jsonArray.first?.stringValue {
                    partialResult[url, default: .init(read: false, write: false)].write = true
                }
            }

            if !allRelays.isEmpty {
                relayData = allRelays
            }
            return
        case .zapReceipt:
            guard 
                let id = payload["id"]?.stringValue,
                let tags = payload["tags"]?.arrayValue,
                let zapContent: JSON = tags.tagValueForKey("description")?.decode()
            else {
                print("Error decoding zapReceipt")
                return
            }
            
            zapReceipts[id] = zapContent
            return
        case .handlerInfo:
            events.append(payload)
            return
        case .live:
            events.append(payload)
            Task {
                await LiveEventManager.instance.addLiveEvent(payload)
            }
            return
//        case .shortenedArticle:
//            let longFormEvent = NostrContent(jsonData: payload)
//
//            longFormPosts.append(.init(
//                title: longFormEvent.tags.first(where: { $0.first == "title" })?[safe: 1],
//                image: longFormEvent.tags.first(where: { $0.first == "image" })?[safe: 1],
//                summary: longFormEvent.tags.first(where: { $0.first == "summary" })?[safe: 1],
//                event: longFormEvent
//            ))               
//            return
        default: break
        }
        
        // MARK: - HAS CONTENT
        guard let contentString = payload["content"]?.stringValue else {
            print("NO CONTENT STRING")
            return
        }
        
        switch kind {
        case .metadata:
            let nostrUser = NostrContent(json: .object(payload))
            if var user = PrimalUser(nostrUser: nostrUser) {
                user.rawData = payload.encodeToString()
                users[nostrUser.pubkey] = user
            }
        case .text:
            let content = NostrContent(jsonData: payload)
            posts.append(content)
            order.append(content.id)
        case .repost:
            guard
                let pubKey = payload["pubkey"]?.stringValue,
                let dateNum = payload["created_at"]?.doubleValue,
                let contentJSON: JSON = contentString.decode()
            else {
                if !contentString.isEmpty {
                    print("Error decoding reposts string to json")
                }
                return
            }
            
            let id = payload["id"]?.stringValue ?? ""
            
            reposts.append(.init(id: id, pubkey: pubKey, post: NostrContent(json: contentJSON), date: Date(timeIntervalSince1970: dateNum)))
            order.append(id)
        case .noteStats:
            guard let nostrContentStats: NostrContentStats = try? JSONDecoder().decode(NostrContentStats.self, from: Data(contentString.utf8)) else {
                print("Error decoding NostrContentStats to json")
                return
            }
            stats[nostrContentStats.event_id] = nostrContentStats
        case .notification:
            guard
                let json: JSON = contentString.decode(),
                let notification = PrimalNotification.fromJSON(json)
            else {
                print("Error decoding PrimalNotification to json")
                return
            }
            notifications.append(notification)
        case .paginationEvent:
            guard let pagination: PrimalPagination = contentString.decode() else {
                print("Error decoding PrimalSearchPagination to json")
                return
            }
            self.pagination = pagination
        case .noteActions:
            guard let noteStatus: PrimalNoteStatus = contentString.decode() else {
                print("Error decoding PrimalNoteStatus to json")
                return
            }
            
            if noteStatus.liked {
                PostingManager.instance.userLikes.insert(noteStatus.event_id)
            }
            if noteStatus.replied {
                PostingManager.instance.userReplied.insert(noteStatus.event_id)
            }
            if noteStatus.reposted {
                PostingManager.instance.userReposts.insert(noteStatus.event_id)
            }
            if noteStatus.zapped {
                WalletManager.instance.setZapUnknown(noteStatus.event_id)
            }
        case .mentions:
            guard let contentJSON: JSON = contentString.decode() else {
                print("Error decoding mentions string to json")
                return
            }
            
            let nostrContent = NostrContent(json: contentJSON)
            
            if nostrContent.kind == NostrKind.zapReceipt.rawValue || nostrContent.kind == NostrKind.postZaps.rawValue, let newPayload = contentJSON.objectValue {
                handlePostEvent(newPayload)
            }
            
            mentions.append(nostrContent)
            
            if nostrContent.kind == NostrKind.longForm.rawValue {
                longFormPosts.append(.init(
                    title: nostrContent.tags.first(where: { $0.first == "title" })?[safe: 1],
                    image: nostrContent.tags.first(where: { $0.first == "image" })?[safe: 1],
                    summary: nostrContent.tags.first(where: { $0.first == "summary" })?[safe: 1],
                    event: nostrContent
                ))
            }
        case .mediaMetadata:
            guard let metadata: MediaMetadata = contentString.decode() else {
                print("Error decoding metadata string to json")
                return
            }
            
            MediaManager.add(metadata)
            mediaMetadata.append(metadata)
        case .userScore:
            guard let info: [String: Int] = contentString.decode() else { return }
            
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
            guard let contentArray: [[String: Double]] = contentString.decode() else {
                print("Error decoding popular hashtags")
                return
            }
            
            for object in contentArray {
                guard let (name, count) = object.first else { continue }
                popularHashtags.append(.init(title: name, appearances: count))
            }
        case .timestamp:
            guard let timeStamp = Int(contentString) else {
                print("Error decoding timestamp")
                return
            }
            timestamps.append(.init(timeIntervalSince1970: TimeInterval(timeStamp)))
        case .webPreview:
            guard let webPreview: WebPreviews = contentString.decode() else {
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
            guard let chats: [String: ChatMetadata] = contentString.decode() else {
                print("Error decoding messagesMetadata")
                return
            }
            chatsMetadata = chats
        case .defaultRelays:
            messageArray = contentString.decode()
        case .userPubkey:
            guard let data: [String: String] = contentString.decode(), let pubkey = data["pubkey"] else {
                print("Error decoding userPubkey")
                return
            }
            userPubkey = pubkey
        case .contacts:
            if !contentString.isEmpty {
                relayData = contentString.decode() ?? relayData
            }
            
            guard let tagsArray = payload["tags"]?.arrayValue else { return }
            let tags: Set<String> = Set(tagsArray.compactMap { $0.arrayValue?[safe: 1]?.stringValue })
            
            if !tags.isEmpty {
                let set = DatedSet(created_at: Int(payload["created_at"]?.doubleValue ?? -1), set: tags)
                contacts = set
                allContacts.append(set)
            }
        case .bookmarks:
            guard let tagsArray = payload["tags"]?.arrayValue else { return }
            let tags: [Tag] = tagsArray.compactMap {
                .init(type: $0.arrayValue?[safe: 0]?.stringValue ?? "", text: $0.arrayValue?[safe: 1]?.stringValue ?? "")
            }
            
            if !tags.isEmpty {
                bookmarks = DatedTagArray(created_at: Int(payload["created_at"]?.doubleValue ?? -1), array: tags)
            }
        case .relayHints:
            let hints: [String: String] = contentString.decode() ?? [:]
            
            Task {
                await RelayHintManager.instance.addHints(hints)
            }
        case .postZaps:
            guard let zap: PrimalZapEvent = contentString.decode() else {
                print("Error decoding postZaps")
                return
            }
            postZaps.append(zap)
        case .longFormMetadata:
            guard let json: JSON = contentString.decode(), let objectValue = json.objectValue else {
                print("Error decoding longFormMetadata")
                return
            }
            
            if let eventId = objectValue["event_id"]?.stringValue, let words = objectValue["words"]?.doubleValue {
                longFormWordCount[eventId] = Int(words)
            } else {
                print("Error decoding longFormMetadata")
            }
        case .longForm, .shortenedArticle:
            let longFormEvent = NostrContent(jsonData: payload)

            longFormPosts.append(.init(
                title: longFormEvent.tags.first(where: { $0.first == "title" })?[safe: 1],
                image: longFormEvent.tags.first(where: { $0.first == "image" })?[safe: 1],
                summary: longFormEvent.tags.first(where: { $0.first == "summary" })?[safe: 1],
                event: longFormEvent
            ))
        case .eventBroadcastResponse:
            guard 
                let json: JSON = contentString.decode(),
                let response = json.arrayValue?.first?.objectValue?["responses"]?.arrayValue?.first?.arrayValue,
                let statusArrayString = response.dropFirst().first?.stringValue,
                let statusArray: JSON = statusArrayString.decode(),
                let status = statusArray.arrayValue?.first?.stringValue
            else { return }
            
            eventBroadcastSuccessful = eventBroadcastSuccessful || status == "OK"
        case .highlight:
            highlights.append(NostrContent(json: .object(payload)))
        case .primalName:
            guard let dic: [String: String] = contentString.decode() else {
                print("Error decoding primalName")
                return
            }
            Task {
                await PremiumCustomizationManager.instance.addPremiumNames(dic)
            }
        case .primalLegendInfo:
            guard let dic: [String: LegendCustomization] = contentString.decode() else {
                print("Error decoding primalLegendInfo")
                return
            }
            Task {
                await PremiumCustomizationManager.instance.addLegendCustomizations(dic)
            }
        case .primalPremiumInfo:
            guard let dic: [String: PremiumUserInfo] = contentString.decode() else {
                print("Error decoding primalLegendInfo")
                return
            }
            Task {
                await PremiumCustomizationManager.instance.addPremiumInfo(dic)
            }
        case .blossom:
            Task {
                await BlossomServerManager.instance.addBlossomInfo(payload)
            }
        default:
            events.append(payload)
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
