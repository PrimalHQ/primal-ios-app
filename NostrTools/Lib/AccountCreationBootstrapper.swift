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
    private var oksReceived: Int = 0
    
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
        self.pool.connect()
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
                    print("NSEC: \(self.keypair.privkey_bech32!)")
                    
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
            case .event(let r, let ev):
                print(r, ev)
            case .eose:
                break
            case .ok(let res):
                print("account created from: \(relay) with result: \(res.msg)")
                if res.ok {
                    self.oksReceived += 1
                }
                if self.oksReceived >= Int(Double(bootstrap_relays.count) / 1.25) {
                    if let callback = self.cb {
                        print("oks received: \(self.oksReceived)")
                        callback()
                    }
                }
                break
            }
        }
    }
}
