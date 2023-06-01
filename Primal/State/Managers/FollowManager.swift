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
    
    static let the: FollowManager = FollowManager()
    
    func isFollowing(_ pubkey: String) -> Bool { IdentityManager.the.userContacts.contacts.contains(pubkey) }
    
    func sendBatchFollowEvent(_ pubkeys: [String]) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = IdentityManager.the.userContacts.contacts
        contacts.append(contentsOf: pubkeys)
        IdentityManager.the.userContacts.contacts = contacts
        
        let relays = IdentityManager.the.userRelays ?? makeBootstrapRelays()
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: relays)
        
        RelaysPostBox.the.send(ev)
    }
    
    func sendFollowEvent(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = IdentityManager.the.userContacts.contacts
        contacts.append(pubkey)
        IdentityManager.the.userContacts.contacts = contacts
        
        let relays = IdentityManager.the.userRelays ?? makeBootstrapRelays()
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: relays)
        
        RelaysPostBox.the.send(ev)
    }
    
    func sendUnfollowEvent(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let indexOfPubkeyToRemove = IdentityManager.the.userContacts.contacts.firstIndex(of: pubkey)
        
        if let index = indexOfPubkeyToRemove {
            IdentityManager.the.userContacts.contacts.remove(at: index)
            
            let relays = IdentityManager.the.userRelays ?? makeBootstrapRelays()
            
            let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: IdentityManager.the.userContacts.contacts, relays: relays)
            
            RelaysPostBox.the.send(ev)
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
