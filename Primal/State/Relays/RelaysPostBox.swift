//
//  RelaysPostBox.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation

final class RelaysPostBox {
    private let _postBox: PostBox = PostBox(pool: RelayPool())
    
    private init() {}
    
    static let the = RelaysPostBox()
    
    var isConnected: Bool {
        get {
            return _postBox.pool.num_connected != 0
        }
    }
    
    var numConnected: Int {
        get {
            return _postBox.pool.num_connected
        }
    }
    
    var postBox: PostBox {
        get {
            return _postBox
        }
    }
    
    var pool: RelayPool {
        get {
            return _postBox.pool
        }
    }
    
    func disconnect() {
        _postBox.pool.disconnect()
        _postBox.pool.relays = []
    }
    
    func connect(_ relays: [String: RelayInfo]) {
        for relay in relays {
            add_rw_relay(pool: _postBox.pool, url: relay.key, info: .rw, variant: .regular)
        }
        
        if
            let nwcUrl = UserDefaults.standard.string(forKey: "nwc"),
            let nwc = WalletConnectURL(str: nwcUrl) {
            add_rw_relay(pool: _postBox.pool, url: nwc.relay.url.absoluteString, info: .rw, variant: .nwc)
        }
        
        _postBox.pool.disconnect()
        _postBox.pool.connect()
    }
    
    func send(_ req: NostrEvent) {
        _postBox.send(req)
    }
    
    func registerHandler(sub_id: String, handler: @escaping (String, NostrConnectionEvent) -> ()) {
        _postBox.pool.register_handler(sub_id: sub_id, handler: handler)
    }
    
    func zapRelays() -> [RelayDescriptor] {
        return Array(_postBox.pool.our_descriptors.prefix(10))
    }
}
