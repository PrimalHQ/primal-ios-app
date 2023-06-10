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
    
    func sendBatchFollowEvent(_ pubkeys: [String]) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = IdentityManager.instance.userContacts.contacts
        contacts.append(contentsOf: pubkeys)
        IdentityManager.instance.userContacts.contacts = contacts
        
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: relays)
        
        RelaysPostBox.the.send(ev)
    }
    
    private func follow(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = IdentityManager.instance.userContacts.contacts
        contacts.append(pubkey)
        IdentityManager.instance.userContacts.contacts = contacts
        
        let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: relays)
        
        RelaysPostBox.the.send(ev)
    }
    
    func sendFollowEvent(_ pubkey: String) {
        IdentityManager.instance.requestUserContacts() {
            self.follow(pubkey)
        }
    }
    
    private func unfollow(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let indexOfPubkeyToRemove = IdentityManager.instance.userContacts.contacts.firstIndex(of: pubkey)
        
        if let index = indexOfPubkeyToRemove {
            IdentityManager.instance.userContacts.contacts.remove(at: index)
            
            let relays = IdentityManager.instance.userRelays ?? makeBootstrapRelays()
            
            let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: IdentityManager.instance.userContacts.contacts, relays: relays)
            
            RelaysPostBox.the.send(ev)
        }
    }
    
    func sendUnfollowEvent(_ pubkey: String) {
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
