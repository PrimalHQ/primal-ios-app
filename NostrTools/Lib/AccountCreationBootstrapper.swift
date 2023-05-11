//
//  AccountCreationBootstrapper.swift
//  Primal
//
//  Created by Nikola Lukovic on 9.5.23..
//

import Foundation

public let bootstrap_relays = [
    "wss://relay.shitforce.one",
    "wss://nb.relay.center",
    "wss://nos.lol",
    "wss://nostr1.current.fyi",
    "wss://nostr.bitcoiner.social",
    "wss://relay.nostr.bg",
    "wss://universe.nostrich.land",
    "wss://relay.wellorder.net",
    "wss://e.nos.lol",
    "wss://damus.relay.center"
]

class AccountCreationBootstrapper {
    private let pool: RelayPool
    private var profile: Profile?
    private let keypair: Keypair
    private var cb: (() -> Void)?
    
    init() {
        self.pool = RelayPool()
        self.keypair = generate_new_keypair()
    }
    
    deinit {
        self.pool.disconnect()
    }
    
    func disconnect() {
        self.pool.disconnect()
    }
    
    func signup(nickName: String, displayName: String, about: String, pictureUrl: String, bannerUrl: String, successCallback: @escaping () -> Void) {
        self.profile = Profile(name: nickName, display_name: displayName, about: about, picture: pictureUrl, banner: bannerUrl, website: nil, lud06: nil, lud16: nil, nip05: nil)
        for relay in bootstrap_relays {
            add_rw_relay(self.pool, relay)
        }
        self.cb = successCallback
        self.pool.register_handler(sub_id: "signup", handler: handleSignupEvent)
    }
    
    private func handleSignupEvent(relay: String, ev: NostrConnectionEvent) {
        switch ev {
        case .ws_event(let wsev):
            switch wsev {
            case .connected:
                let metadata_ev = make_metadata_event(keypair: self.keypair, metadata: self.profile!)
                let contacts_ev = make_first_contact_event(keypair: self.keypair, bootstrap_relays: bootstrap_relays)
                
                if let metadata_ev {
                    self.pool.send(.event(metadata_ev))
                }
                if let contacts_ev {
                    self.pool.send(.event(contacts_ev))
                }
                
                do {
                    try save_keypair(pubkey: self.keypair.pubkey, privkey: self.keypair.privkey!)
                    self.pool.disconnect()
                    if let callback = self.cb {
                        callback()
                    }
                } catch {
                    print("Failed to save keys")
                }
                
            case .error(let err):
                print(String(describing: err))
            default:
                break
            }
        case .nostr_event(let resp):
            switch resp {
            case .notice(let msg):
                print(msg)
            case .event:
                print("event in signup?")
            case .eose:
                break
            case .ok:
                break
            }
        }
    }
}

//class AccountRecommendedFollowBootstrapper {
//    private let pool: RelayPool
//    private let userRelays: [String: RelayInfo]
//    private let handleConnectedEvent: () -> Void
//    var contacts: [String]
//
//    init(handleConnectedEvent: @escaping () -> Void) {
//        self.handleConnectedEvent = handleConnectedEvent
//        self.pool = RelayPool()
//        for relay in bootstrap_relays {
//            add_rw_relay(self.pool, relay)
//            userRelays[relay] = RelayInfo(read: true, write: true)
//        }
//        self.pool.register_handler(sub_id: "follow/unfollow", handler: handleFollowUnfollowEvent)
//    }
//
//    deinit {
//        self.pool.disconnect()
//    }
//
//    func disconnect() {
//        self.pool.disconnect()
//    }
//
//    func follow(_ pubkey: String) {
//        self.contacts.append(pubkey)
//
//        guard let keypair = get_saved_keypair() else {
//            print("Error getting saved keypair")
//            return
//        }
//
//        let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: contacts, relays: self.userRelays)
//
//        self.pool.send(.event(ev))
//    }
//
//    func unfollow(_ pubkey: String) {
//        let indexOfPubkeyToRemove = self.contacts.firstIndex(of: pubkey)
//
//        if let index = indexOfPubkeyToRemove {
//            self.contacts.remove(at: index)
//
//            guard let keypair = get_saved_keypair() else {
//                print("Error getting saved keypair")
//                return
//            }
//
//            let ev = make_contacts_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, contacts: self.contacts, relays: self.userRelays)
//
//            self.pool.send(.event(ev))
//        }
//    }
//
//    private func handleFollowUnfollowEvent(relay: String, ev: NostrConnectionEvent) {
//        switch ev {
//        case .ws_event(let wsev):
//            switch wsev {
//            case .connected:
//                self.handleConnectedEvent()
//            case .error(let err):
//                print(String(describing: err))
//            default:
//                break
//            }
//        case .nostr_event(let resp):
//            switch resp {
//            case .notice(let msg):
//                print(msg)
//            case .event:
//                print("event in signup?")
//            case .eose:
//                break
//            case .ok:
//                break
//            }
//        }
//    }
//
//}
