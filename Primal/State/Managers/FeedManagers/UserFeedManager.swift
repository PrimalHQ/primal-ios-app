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
        super.init(request: FeedManagerRequest(name: "explore_people", body: ["user_pubkey": .string(IdentityManager.instance.userHexPubkey)]))
    }
}

class UserFeedManager: BaseFeedManager {
    // Accessed from the main thread
    @Published var users: [ParsedUser] = []
    
    @Published private var oldUsers: [ParsedUser] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(request: FeedManagerRequestProtocol) {
        super.init(request: request)
        baseDelegate = self
        
        requestResultEmitter
            .map { $0.getSortedUsers() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self else { return }
                self.users = oldUsers + users
                self.oldUsers = self.users
            }
            .store(in: &cancellables)
    }
    
    override func refresh() {
        oldUsers = []
        
        super.refresh()
    }
}

extension UserFeedManager: BaseFeedManagerDelegate {
    func userMuted(pubkey: String) {
        users = users.filter { $0.data.pubkey != pubkey }
        oldUsers = oldUsers.filter { $0.data.pubkey != pubkey }
    }
    
    func requestOffset(until: Double) -> Int {
        1
    }
}
