//
//  UserFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import Foundation
import Combine
import GenericJSON

class ExploreUsersFeedManager: UserFeedManager {
    init() {
        super.init(request: FeedManagerRequest(name: "follow_lists", body: [:]))
    }
}

class UserList {
    var id: String
    var dTag: String
    var name: String
    var description: String
    var imageData: MediaMetadata.Resource
    var updatedAt: Date
    
    var user: ParsedUser
    
    var list: [ParsedUser]
    
    var baseEvent: [String: JSON]
    
    init(id: String, dTag: String, name: String, description: String, imageData: MediaMetadata.Resource, updatedAt: Date, user: ParsedUser, list: [ParsedUser], baseEvent: [String : JSON]) {
        self.id = id
        self.dTag = dTag
        self.name = name
        self.description = description
        self.imageData = imageData
        self.updatedAt = updatedAt
        self.user = user
        self.list = list
        self.baseEvent = baseEvent
    }
}

class UserFeedManager: BaseFeedManager {
    // Accessed from the main thread
    @Published var userLists: [UserList] = []
    @Published private var oldUserLists: [UserList] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(request: FeedManagerRequestProtocol) {
        super.init(request: request)
        baseDelegate = self
        
        requestResultEmitter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                let userListObjects: [[String: JSON]] = result.events.filter({ Int($0["kind"]?.doubleValue ?? 0) == NostrKind.followList.rawValue })
                
                guard let self else { return }
                
                let users = result.getSortedUsers()
                
                let lists: [UserList] = userListObjects.compactMap { (event) -> UserList? in
                    guard
                        let userPubkey = event["pubkey"]?.stringValue,
                        let id = event["id"]?.stringValue,
                        let tags = event["tags"]?.arrayValue,
                        let title = tags.first(where: { $0.arrayValue?.first?.stringValue == "title" })?.arrayValue?[safe: 1]?.stringValue,
                        let dTag = tags.first(where: { $0.arrayValue?.first?.stringValue == "d" })?.arrayValue?[safe: 1]?.stringValue,
                        let imageUrl = tags.first(where: { $0.arrayValue?.first?.stringValue == "image" })?.arrayValue?[safe: 1]?.stringValue
                    else { return nil }
                    
                    let description = tags.first(where: { $0.arrayValue?.first?.stringValue == "description" })?.arrayValue?[safe: 1]?.stringValue ?? ""
                    let taggedUserPubkeys = tags.compactMap { $0.arrayValue?.first?.stringValue == "p" ? $0.arrayValue?[safe: 1]?.stringValue : nil }
                    let media = result.mediaMetadata.first(where: { $0.event_id == id })?.resources.first(where: { $0.url == imageUrl })
                    let createdAt = event["created_at"]?.doubleValue
                    
                    let userList: [ParsedUser] = taggedUserPubkeys.map({ pubkey in
                            users.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
                        })
                        .sorted(by: { $0.followers ?? 0 > $1.followers ?? 0 })
                    
                    
                    return UserList(
                        id: id,
                        dTag: dTag,
                        name: title,
                        description: description,
                        imageData: media ?? .init(url: imageUrl, variants: []),
                        updatedAt: .init(timeIntervalSince1970: createdAt ?? 0),
                        user: users.first(where: { $0.data.pubkey == userPubkey }) ?? .init(data: .init(pubkey: userPubkey)),
                        list: userList,
                        baseEvent: event
                    )
                }
                
                userLists = oldUserLists + lists
                oldUserLists = userLists
            }
            .store(in: &cancellables)
    }
    
    override func refresh() {
        oldUserLists = []
        
        super.refresh()
    }
}

extension UserFeedManager: BaseFeedManagerDelegate {
    func userMuted(pubkey: String) {
        userLists = userLists.filter { $0.user.data.pubkey != pubkey }
        oldUserLists = oldUserLists.filter { $0.user.data.pubkey != pubkey }
    }
    
    func requestOffset(until: Double) -> Int {
        1
    }
}
