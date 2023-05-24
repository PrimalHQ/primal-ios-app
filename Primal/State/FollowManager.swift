//
//  FollowManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 11.5.23..
//

import Combine
import Foundation

final class FollowManager {
    let connection: SocketManager
    init(socket: SocketManager) {
        self.connection = socket
    }
    
    func isFollowing(_ pubkey: String) -> Bool { connection.currentUserContacts.contacts.contains(pubkey) }
    
    func toggleFollow(_ pubkey: String) {
        if isFollowing(pubkey) {
            sendUnfollowEvent(pubkey)
        } else {
            sendFollowEvent(pubkey)
        }
    }
    
    func sendBatchFollowEvent(_ pubkeys: [String]) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = connection.currentUserContacts.contacts
        contacts.append(contentsOf: pubkeys)
        connection.currentUserContacts.contacts = contacts
        
        let relays = connection.currentUserRelays ?? makeBootstrapRelays()
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: relays)
        
        connection.postBox.send(ev)
    }
    
    func sendFollowEvent(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = connection.currentUserContacts.contacts
        contacts.append(pubkey)
        connection.currentUserContacts.contacts = contacts
        
        let relays = connection.currentUserRelays ?? makeBootstrapRelays()
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: relays)
        
        connection.postBox.send(ev)
    }
    
    func sendUnfollowEvent(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let indexOfPubkeyToRemove = connection.currentUserContacts.contacts.firstIndex(of: pubkey)
        
        if let index = indexOfPubkeyToRemove {
            connection.currentUserContacts.contacts.remove(at: index)
            
            let relays = connection.currentUserRelays ?? makeBootstrapRelays()
            
            let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: connection.currentUserContacts.contacts, relays: relays)
            
            connection.postBox.send(ev)
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
