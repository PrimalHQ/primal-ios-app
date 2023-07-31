//
//  FollowManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 11.5.23..
//  Modified by Nikola Lukovic on 31.5.23..
//

import Foundation

final class FollowManager {
    private init() {}
    
    static let instance: FollowManager = FollowManager()
    
    func isFollowing(_ pubkey: String) -> Bool { IdentityManager.instance.userContacts.contacts.contains(pubkey) }
    
    func sendBatchFollowEvent(_ pubkeys: [String], successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        if LoginManager.instance.method() != .nsec { return }
        
        var contacts = IdentityManager.instance.userContacts.contacts
        contacts.append(contentsOf: pubkeys)
        IdentityManager.instance.userContacts.contacts = contacts
        
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
        
        guard let ev = NostrObject.contacts(contacts, relays: relays) else {
            return
        }
        
        RelaysPostbox.instance.request(ev, specificRelay: nil, errorDelay: 5, successHandler: { _ in
            if let successHandler {
                successHandler()
            }
        }, errorHandler: {
            if let errorHandler {
                errorHandler()
            }
        })
    }
    
    private func follow(_ pubkey: String) {
        var contacts = IdentityManager.instance.userContacts.contacts
        contacts.append(pubkey)
        IdentityManager.instance.userContacts.contacts = contacts
        
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
        
        guard let ev = NostrObject.contacts(contacts, relays: relays) else {
            return
        }
        
        //    RelaysPostBox_bkp.the.send(ev)
        RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
            
        }, errorHandler: {
            
        })
    }
    
    func sendFollowEvent(_ pubkey: String) {
        if LoginManager.instance.method() != .nsec { return }

        IdentityManager.instance.requestUserContacts() {
            self.follow(pubkey)
        }
    }
    
    private func unfollow(_ pubkey: String) {
        let indexOfPubkeyToRemove = IdentityManager.instance.userContacts.contacts.firstIndex(of: pubkey)
        
        if let index = indexOfPubkeyToRemove {
            IdentityManager.instance.userContacts.contacts.remove(at: index)
            
            let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
            
            guard let ev = NostrObject.contacts(IdentityManager.instance.userContacts.contacts, relays: relays) else {
                return
            }
            
            //    RelaysPostBox_bkp.the.send(ev)
            RelaysPostbox.instance.request(ev, specificRelay: nil, successHandler: { _ in
                
            }, errorHandler: {
                
            })
        }
    }
    
    func sendUnfollowEvent(_ pubkey: String) {
        if LoginManager.instance.method() != .nsec { return }

        IdentityManager.instance.requestUserContacts() {
            self.unfollow(pubkey)
        }
    }
    
    private func makeBootstrapRelays() -> [String: RelayInfo] {
        var relays: [String: RelayInfo] = [:]
        
        bootstrap_relays.forEach { relay in
            relays[relay] = RelayInfo(read: true, write: true)
        }
        
        return relays
    }
}
