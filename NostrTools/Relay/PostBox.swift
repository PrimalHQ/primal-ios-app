//
//  PostBox.swift
//  damus
//
//  Created by William Casarin on 2023-03-20.
//

import Foundation

final class Relayer {
    let relay: String
    var attempts: Int
    var retry_after: Double
    var last_attempt: Int64?
    
    init(relay: String, attempts: Int, retry_after: Double) {
        self.relay = relay
        self.attempts = attempts
        self.retry_after = retry_after
        self.last_attempt = nil
    }
}

class PostedEvent {
    let event: NostrEvent
    let skip_ephemeral: Bool
    var remaining: [Relayer]
    let flush_after: Date?
    var flushed_once: Bool
    let on_flush: OnFlush?
    
    init(event: NostrEvent, remaining: [String], skip_ephemeral: Bool, flush_after: Date?, on_flush: OnFlush?) {
        self.event = event
        self.skip_ephemeral = skip_ephemeral
        self.flush_after = flush_after
        self.on_flush = on_flush
        self.flushed_once = false
        self.remaining = remaining.map {
            Relayer(relay: $0, attempts: 0, retry_after: 10.0)
        }
    }
}

final class PostBox: ObservableObject {
    let pool: RelayPool
    var events: [String: PostedEvent]
    
    init(pool: RelayPool) {
        self.pool = pool
        self.events = [:]
        pool.register_handler(sub_id: "postbox", handler: handle_event)
    }
    
    func try_flushing_events() {
        let now = Int64(Date().timeIntervalSince1970)
        for kv in events {
            let event = kv.value
            for relayer in event.remaining {
                if relayer.last_attempt == nil || (now >= (relayer.last_attempt! + Int64(relayer.retry_after))) {
                    print("attempt #\(relayer.attempts) to flush event '\(event.event.content)' to \(relayer.relay) after \(relayer.retry_after) seconds")
                    flush_event(event, to_relay: relayer)
                }
            }
        }
    }
    
    func handle_event(relay_id: String, _ ev: NostrConnectionEvent) {
        try_flushing_events()
        
        guard case .nostr_event(let resp) = ev else {
            return
        }
        
        guard case .ok(let cr) = resp else {
            return
        }
        
        remove_relayer(relay_id: relay_id, event_id: cr.event_id)
    }
    
    func remove_relayer(relay_id: String, event_id: String) {
        guard let ev = self.events[event_id] else {
            return
        }
        ev.remaining = ev.remaining.filter {
            $0.relay != relay_id
        }
        if ev.remaining.count == 0 {
            self.events.removeValue(forKey: event_id)
        }
    }
    
    private func flush_event(_ event: PostedEvent, to_relay: Relayer? = nil) {
        var relayers = event.remaining
        if let to_relay {
            relayers = [to_relay]
        }
        
        for relayer in relayers {
            relayer.attempts += 1
            relayer.last_attempt = Int64(Date().timeIntervalSince1970)
            relayer.retry_after *= 1.5
            pool.send(.event(event.event), to: [relayer.relay])
        }
    }
    
    func flush() {
        for event in events {
            flush_event(event.value)
        }
    }
    
    func send(_ event: NostrEvent) {
        // Don't add event if we already have it
        if events[event.id] != nil {
            return
        }
        
        let remaining = pool.descriptors.map { $0.url.id }
        
        let posted_ev = PostedEvent(event: event, remaining: remaining, skip_ephemeral: true, flush_after: nil, on_flush: nil)
        events[event.id] = posted_ev
        
        flush_event(posted_ev)
    }
    
    func send(_ event: NostrEvent, to: [String]? = nil, skip_ephemeral: Bool = true, delay: TimeInterval? = nil, on_flush: OnFlush? = nil) {
        // Don't add event if we already have it
        if events[event.id] != nil {
            return
        }
        
        let remaining = to ?? pool.our_descriptors.map { $0.url.id }
        let after = delay.map { d in Date.now.addingTimeInterval(d) }
        let posted_ev = PostedEvent(event: event, remaining: remaining, skip_ephemeral: skip_ephemeral, flush_after: after, on_flush: on_flush)
        
        events[event.id] = posted_ev
        
//        if after == nil {
            flush_event(posted_ev)
//        }
    }
}
