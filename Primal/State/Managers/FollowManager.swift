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
        Publishers.CombineLatest3($pubkeysToFollow, $pubkeysToUnfollow, Connection.regular.$isConnected)
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] pubkeysF, pubkeysUF, isConnected in
                if pubkeysF.isEmpty && pubkeysUF.isEmpty { return }
                guard isConnected else { return }
                
                IdentityManager.instance.requestUserContactsAndRelays() {
                    guard let self else { return }
                    
                    let contacts = IdentityManager.instance.userContacts.contacts.union(pubkeysF).subtracting(pubkeysUF)
                    
                    DispatchQueue.main.async {
                        if self.pubkeysToFollow != pubkeysF || self.pubkeysToUnfollow != pubkeysUF { return } // Don't update yet, another update is coming
                        
                        self.pubkeysToFollow = []
                        self.pubkeysToUnfollow = []
                        
                        if IdentityManager.instance.userContacts.contacts == contacts { return } // Don't update if same
                        
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
        !pubkeysToUnfollow.contains(pubkey) && (pubkeysToFollow.contains(pubkey) || IdentityManager.instance.userContacts.contacts.contains(pubkey))
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
        
        var contacts = IdentityManager.instance.userContacts.contacts
        for pubkey in pubkeys {
            contacts.insert(pubkey)
        }
        
        sendBatchEvent(pubkeys, successHandler: successHandler, errorHandler: errorHandler)
    }
    
    func addRelay(url: String) {
        IdentityManager.instance.requestUserContactsAndRelays() {
            var relays = IdentityManager.instance.userRelays ?? self.makeBootstrapRelays()
            relays[url] = .init(read: true, write: true)
            IdentityManager.instance.userRelays = relays
            IdentityManager.instance.fullRelayList += [url]
            self.updateFollowsAndRelays()
        }
    }
    
    func removeRelay(url: String) {
        IdentityManager.instance.requestUserContactsAndRelays() {
            var relays = IdentityManager.instance.userRelays ?? self.makeBootstrapRelays()
            
            RelaysPostbox.instance.pool.disconnect(relay: url)

            IdentityManager.instance.fullRelayList.remove(object: url)
            if let _ = relays.removeValue(forKey: url) {
                IdentityManager.instance.userRelays = relays
                self.updateFollowsAndRelays()
            }
        }
    }
    
    func resetDefaultRelays() {
        SocketRequest(name: "get_default_relays", payload: nil).publisher()
            .sink { result in
                guard let relays = result.messageArray else { return }
                
                IdentityManager.instance.requestUserContactsAndRelays() {
                    var newRelays: [String: RelayInfo] = [:]
                    relays.forEach { newRelays[$0] = .init(read: true, write: true) }
                    IdentityManager.instance.userRelays = newRelays
                    RelaysPostbox.instance.disconnect()
                    RelaysPostbox.instance.connect(relays)
                    
                    self.updateFollowsAndRelays()
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func sendBatchEvent(_ pubkeys: Set<String>, successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        IdentityManager.instance.userContacts.contacts = pubkeys
        
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
        
        guard let ev = NostrObject.contacts(pubkeys, relays: relays) else {
            errorHandler?()
            return
        }
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, errorDelay: 5, successHandler: { _ in successHandler?() }, errorHandler: errorHandler)
    }
    
    private func updateFollowsAndRelays() {
        let contacts = IdentityManager.instance.userContacts.contacts
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
        
        guard let ev = NostrObject.contacts(contacts, relays: relays) else { return }
        
        // RelaysPostBox_bkp.the.send(ev)
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            
        }, errorHandler: {
            
        })
    }
    
    private func follow(_ pubkey: String) {
        sendBatchFollowEvent([pubkey])
    }
    
    private func unfollow(_ pubkey: String) {
        guard let index = IdentityManager.instance.userContacts.contacts.firstIndex(of: pubkey) else { return }
        
        IdentityManager.instance.userContacts.contacts.remove(at: index)
            
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
            
        guard let ev = NostrObject.contacts(IdentityManager.instance.userContacts.contacts, relays: relays) else { return }
            
            //    RelaysPostBox_bkp.the.send(ev)
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
        }, errorHandler: {
        })
    }
    
    private func makeBootstrapRelays() -> [String: RelayInfo] {
        var relays: [String: RelayInfo] = [:]
        
        bootstrap_relays.forEach { relay in
            relays[relay] = RelayInfo(read: true, write: true)
        }
        
        return relays
    }
}
