//
//  WalletConnectURL.swift
//  Primal
//
//  Created by Nikola Lukovic on 7.6.23..
//

import Foundation

struct WalletConnectURL: Equatable {
    static func == (lhs: WalletConnectURL, rhs: WalletConnectURL) -> Bool {
        return lhs.keypair == rhs.keypair &&
        lhs.pubkey == rhs.pubkey &&
        lhs.relay == rhs.relay
    }
    
    let relay: RelayURL
    let keypair: FullKeypair
    let pubkey: String
    let lud16: String?
    
    func to_url() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "nostrwalletconnect"
        urlComponents.host = pubkey
        urlComponents.queryItems = [
            URLQueryItem(name: "relay", value: relay.id),
            URLQueryItem(name: "secret", value: keypair.privkey)
        ]
        
        if let lud16 {
            urlComponents.queryItems?.append(URLQueryItem(name: "lud16", value: lud16))
        }
        
        return urlComponents.url!
    }
    
    init?(str: String) {
        guard let url = URL(string: str),
              url.scheme == "nostrwalletconnect",
              let pk = url.host, pk.utf8.count == 64,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let items = components.queryItems,
              let relay = items.first(where: { qi in qi.name == "relay" })?.value,
              let relay_url = RelayURL(relay),
              let secret = items.first(where: { qi in qi.name == "secret" })?.value,
              secret.utf8.count == 64,
              let our_pk = privkey_to_pubkey(privkey: secret)
        else {
            return nil
        }
        
        let lud16 = items.first(where: { qi in qi.name == "lud16" })?.value
        let keypair = FullKeypair(pubkey: our_pk, privkey: secret)
        self = WalletConnectURL(pubkey: pk, relay: relay_url, keypair: keypair, lud16: lud16)
    }
    
    init(pubkey: String, relay: RelayURL, keypair: FullKeypair, lud16: String?) {
        self.pubkey = pubkey
        self.relay = relay
        self.keypair = keypair
        self.lud16 = lud16
    }
}
