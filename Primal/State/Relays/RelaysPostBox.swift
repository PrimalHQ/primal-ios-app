//
//  RelaysPostBox.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation

final class RelaysPostBox {
    private let postBox: PostBox = PostBox(pool: RelayPool())
    
    private init() {}
    
    static let the = RelaysPostBox()
    
    var isConnected: Bool {
        get {
            return postBox.pool.num_connected != 0
        }
    }
    
    func connect(_ relays: [String: RelayInfo]) {
        for relay in relays {
            add_rw_relay(postBox.pool, relay.key)
        }
        
        postBox.pool.connect()
    }
    
    func send(_ req: NostrEvent) {
        postBox.send(req)
    }
    
    func registerHandler(sub_id: String, handler: @escaping (String, NostrConnectionEvent) -> ()) {
        postBox.pool.register_handler(sub_id: sub_id, handler: handler)
    }
}
