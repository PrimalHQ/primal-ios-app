//
//  PremiumListFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.2.25..
//

import Foundation
import Combine
import GenericJSON

class PremiumListFeedManager: BaseFeedManager {
    // Accessed from the main thread
    @Published var users: [PremiumListItem] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(request: FeedManagerRequest(name: "membership_premium_leaderboard", body: [:]))
        baseDelegate = self
        
        requestResultEmitter
            .map { res in
                guard
                    let listResponse = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.primalPremiumInfoList.rawValue }),
                    let items: [PremiumListServerResponse] = listResponse["content"]?.stringValue?.decode()
                else {
                    return []
                }
                
                let users = res.getSortedUsers()
                
                let premiumUsers: [PremiumListItem] = items.enumerated().map { (index, item) in
                    .init(
                        index: Int(item.index),
                        user: users.first(where: { $0.data.pubkey == item.pubkey }) ?? .init(data: .init(pubkey: item.pubkey)),
                        since: Date(timeIntervalSince1970: item.premium_since)
                    )
                }
                
                return premiumUsers
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (users: [PremiumListItem]) in
                guard let self else { return }
                self.users += users
            }
            .store(in: &cancellables)
        
        refresh()
    }
    
    override func refresh() {
        users = []
        
        super.refresh()
    }
}

extension PremiumListFeedManager: BaseFeedManagerDelegate {
    func userMuted(pubkey: String) {
        
    }
    
    func requestOffset(until: Double) -> Int {
        1
    }
}
