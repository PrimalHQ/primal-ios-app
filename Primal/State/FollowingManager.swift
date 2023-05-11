//
//  Following.swift
//  Primal
//
//  Created by Pavle D Stevanović on 11.5.23..
//

import Combine
import Foundation

class FollowingManager {
    let feed: Feed
    init(feed: Feed) {
        self.feed = feed
    }
    
    func isFollowing(_ pubkey: String) -> Bool { feed.currentUserContacts.contacts.contains(pubkey) }
    
    func toggleFollow(_ pubkey: String) {
        if isFollowing(pubkey) {
            sendUnfollowEvent(pubkey)
        } else {
            sendFollowEvent(pubkey)
        }
    }
    
    func sendFollowEvent(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        var contacts = feed.currentUserContacts.contacts
        contacts.append(pubkey)
        feed.currentUserContacts.contacts = contacts
        
        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: feed.currentUserRelays!)
        
        feed.postBox.send(ev)
    }
    
    func sendUnfollowEvent(_ pubkey: String) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        let indexOfPubkeyToRemove = feed.currentUserContacts.contacts.firstIndex(of: pubkey)
        
        if let index = indexOfPubkeyToRemove {
            feed.currentUserContacts.contacts.remove(at: index)
            
            let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: feed.currentUserContacts.contacts, relays: feed.currentUserRelays!)
            
            feed.postBox.send(ev)
        }
    }
}
