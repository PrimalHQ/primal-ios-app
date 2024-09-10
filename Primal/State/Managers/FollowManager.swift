//
//  FollowManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 11.5.23..
//  Modified by Nikola Lukovic on 31.5.23..
//

import Combine
import Foundation

final class FollowManager {
    static let instance: FollowManager = FollowManager()
    
    @Published var pubkeysToFollow: Set<String> = []
    @Published var pubkeysToUnfollow: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        Publishers.CombineLatest3($pubkeysToFollow, $pubkeysToUnfollow, Connection.regular.isConnectedPublisher)
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] pubkeysF, pubkeysUF, isConnected in
                if pubkeysF.isEmpty && pubkeysUF.isEmpty { return }
                guard isConnected else { return }
                
                IdentityManager.instance.requestUserContacts {
                    guard let self else { return }
                    
                    let responseContacts = IdentityManager.instance.userContacts.set
                    let contacts = responseContacts.union(pubkeysF).subtracting(pubkeysUF)
                    
                    DispatchQueue.main.async {
                        if self.pubkeysToFollow != pubkeysF || self.pubkeysToUnfollow != pubkeysUF { return } // Don't update yet, another update is coming
                        
                        self.pubkeysToFollow = []
                        self.pubkeysToUnfollow = []
                        
                        if responseContacts == contacts { return } // Don't update if same
                        
                        self.sendBatchEvent(contacts, errorHandler:  {
                            self.pubkeysToFollow = self.pubkeysToFollow.union(pubkeysF)
                            self.pubkeysToUnfollow = self.pubkeysToUnfollow.union(pubkeysUF)
                        })
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func isFollowing(_ pubkey: String) -> Bool {
        !pubkeysToUnfollow.contains(pubkey) && (pubkeysToFollow.contains(pubkey) || IdentityManager.instance.userContacts.set.contains(pubkey))
    }
    
    func sendFollowEvent(_ pubkey: String) {
        if LoginManager.instance.method() != .nsec { return }

        pubkeysToUnfollow.remove(pubkey)
        pubkeysToFollow.insert(pubkey)
    }
    
    func sendUnfollowEvent(_ pubkey: String) {
        if LoginManager.instance.method() != .nsec { return }
        
        pubkeysToFollow.remove(pubkey)
        pubkeysToUnfollow.insert(pubkey)
    }
    
    func sendBatchFollowEvent(_ pubkeys: Set<String>, successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        if LoginManager.instance.method() != .nsec { return }
        
        var contacts = IdentityManager.instance.userContacts.set
        for pubkey in pubkeys {
            contacts.insert(pubkey)
        }
        
        sendBatchEvent(pubkeys, successHandler: successHandler, errorHandler: errorHandler)
    }
    
    func addRelay(url: String) {
        IdentityManager.instance.requestUserContactsAndRelays() {
            var relays = IdentityManager.instance.userRelays ?? [:]
            relays[url] = .init(read: true, write: true)
            IdentityManager.instance.userRelays = relays
            self.updateRelays()
        }
    }
    
    func removeRelay(url: String) {
        var relays = IdentityManager.instance.userRelays ?? self.makeBootstrapRelays()
            
        if let _ = relays.removeValue(forKey: url) {
            IdentityManager.instance.userRelays = relays
            self.updateRelays()
        }
    }
    
    func resetDefaultRelays() {
        SocketRequest(name: "get_default_relays", payload: nil).publisher()
            .sink { result in
                guard let relays = result.messageArray else { return }
                
                var newRelays: [String: RelayInfo] = [:]
                relays.forEach { newRelays[$0] = .init(read: true, write: true) }
                IdentityManager.instance.userRelays = newRelays
                    
                self.updateRelays()
            }
            .store(in: &cancellables)
    }
    
    private func sendBatchEvent(_ pubkeys: Set<String>, successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        IdentityManager.instance.userContacts.set = pubkeys
        
        guard let ev = NostrObject.contacts(pubkeys) else {
            errorHandler?()
            return
        }
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in successHandler?() }, errorHandler: errorHandler)
    }
    
    private func updateRelays() {
        guard let relays = IdentityManager.instance.userRelays, let ev = NostrObject.relays(relays) else { return }
        
        RelaysPostbox.instance.request(ev)
    }
    
    private func follow(_ pubkey: String) {
        sendBatchFollowEvent([pubkey])
    }
    
    private func unfollow(_ pubkey: String) {
        guard let index = IdentityManager.instance.userContacts.set.firstIndex(of: pubkey) else { return }
        
        IdentityManager.instance.userContacts.set.remove(at: index)
            
        guard let ev = NostrObject.contacts(IdentityManager.instance.userContacts.set) else { return }
            
        RelaysPostbox.instance.request(ev)
    }
    
    private func makeBootstrapRelays() -> [String: RelayInfo] {
        var relays: [String: RelayInfo] = [:]
        
        bootstrap_relays.forEach { relay in
            relays[relay] = RelayInfo(read: true, write: true)
        }
        
        return relays
    }
}
