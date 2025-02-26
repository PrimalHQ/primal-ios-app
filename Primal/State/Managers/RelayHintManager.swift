//
//  RelayHintManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.4.24..
//

import Combine
import Foundation
import NostrSDK

class RelayHintManager: MetadataCoding {
    static let instance = RelayHintManager()
    
    var hints: [String: String] = [:]
    var userRelays: [String: [String]] = [:]
    
    var cancellables: Set<AnyCancellable> = []
    
    @MainActor
    func addHints(_ hints: [String: String]) {
        for (key, value) in hints {
            self.hints[key] = value
        }
    }
    
    func getRelayHint(_ id: String) -> String { hints[id] ?? "" }
    
    func encodeUserWithRelays(_ user: PrimalUser) -> String {
        var metadata = Metadata()
        metadata.pubkey = user.pubkey
        metadata.relays = userRelays[user.pubkey] ?? []
        guard
            metadata.relays?.isEmpty == false,
            let nprofile = try? encodedIdentifier(with: metadata, identifierType: .profile)
        else {
            fetchRelayHints(user)
            return user.npub
        }
        
        return nprofile
    }
    
    var fetchedPubkeys: Set<String> = []
    func fetchRelayHints(_ user: PrimalUser) {
        if fetchedPubkeys.contains(user.pubkey) { return }
        
        fetchedPubkeys.insert(user.pubkey)
        
        SocketRequest(name: "get_user_relays_2", payload: ["pubkeys": [.string(user.pubkey)]]).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                let relays = res.relayData.filter({ $0.value.write }).map({ $0.key }).unique().prefix(2)
                
                self?.userRelays[user.pubkey] = Array(relays)
            }
            .store(in: &cancellables)
    }
}
