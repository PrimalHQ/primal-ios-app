//
//  Nostr_Event.swift
//  Primal
//
//  Created by Nikola Lukovic on 5.7.23..
//

import Foundation
import secp256k1_implementation

fileprivate let jsonEncoder = JSONEncoder()

struct Nostr_Event {
    let id: String
    let sig: String
    let tags: [[String]]
    let pubkey: String
    let created_at: Int64
    let kind: Int
    let content: String
}

func createNostrEvent(content: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) -> Nostr_Event? {
    
    guard
        let keypair = get_saved_keypair(),
        let privkey = keypair.privkey,
        let id = create_nostr_event_id(pubkey: keypair.pubkey, tags: tags, content: content, created_at: createdAt, kind: kind),
        let sig = create_nostr_event_sig(privkey: privkey, id: id) else {
        
        return nil
    }

    return Nostr_Event(id: id, sig: sig, tags: tags, pubkey: keypair.pubkey, created_at: createdAt, kind: kind, content: content)
}

fileprivate func create_nostr_event_id(pubkey: String, tags: [[String]], content: String, created_at: Int64, kind: Int) -> String? {
    let defaultOutputFormatting = jsonEncoder.outputFormatting
    jsonEncoder.outputFormatting = .withoutEscapingSlashes
    defer { jsonEncoder.outputFormatting = defaultOutputFormatting }
    
    guard let tagsJSONData = try? jsonEncoder.encode(tags) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    let tagsJSONString =  String(decoding: tagsJSONData, as: UTF8.self)
    
    guard let commitment = "[0,\"\(pubkey)\",\(created_at),\(kind),\(tagsJSONString),\(content)]".data(using: .utf8) else {
        print("Unable to encode commitment to Data")
        return nil
    }
    
    let hash = sha256(commitment)
    
    return hex_encode(hash)
}
fileprivate func create_nostr_event_sig(privkey: String, id: String) -> String? {
    guard let privkeyBytes = try? privkey.bytes else {
        print("Unable to get bytes from privkey")
        return nil
    }
    
    guard let key = try? secp256k1.Signing.PrivateKey(rawRepresentation: privkeyBytes) else {
        print("Unable to get key from privkey bytes")
        return nil
    }
    
    var aux_rand = random_bytes(count: 64)
    
    guard var idBytes = try? id.bytes else {
        print("Unable to get bytes from id")
        return nil
    }
    
    guard let sig = try? key.schnorr.signature(message: &idBytes, auxiliaryRand: &aux_rand) else {
        print("Failed to create signature for: \(id)")
        return nil
    }
    
    return hex_encode(sig.rawRepresentation)
}
