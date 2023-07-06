//
//  Nostr_Event.swift
//  Primal
//
//  Created by Nikola Lukovic on 5.7.23..
//

import Foundation
import secp256k1_implementation
import GenericJSON

fileprivate let jsonEncoder = JSONEncoder()

struct NostrObject {
    let id: String
    let sig: String
    let tags: [[String]]
    let pubkey: String
    let created_at: Int64
    let kind: Int
    let content: String
}

func createNostrObject(content: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) -> NostrObject? {
    guard
        let keypair = get_saved_keypair(),
        let privkey = keypair.privkey,
        let id = createNostrObjectId(pubkey: keypair.pubkey, tags: tags, content: content, created_at: createdAt, kind: kind),
        let sig = createNostrObjectSig(privkey: privkey, id: id) else {
        
        return nil
    }

    return NostrObject(id: id, sig: sig, tags: tags, pubkey: keypair.pubkey, created_at: createdAt, kind: kind, content: content)
}
func createNostrLikeEvent(post: PrimalFeedPost) -> NostrObject? {
    return createNostrObject(content: "+", kind: 7, tags: [["e", post.id], ["p", post.pubkey]])
}

fileprivate func createNostrObjectId(pubkey: String, tags: [[String]], content: String, created_at: Int64, kind: Int) -> String? {
    let defaultOutputFormatting = jsonEncoder.outputFormatting
    jsonEncoder.outputFormatting = .withoutEscapingSlashes
    defer { jsonEncoder.outputFormatting = defaultOutputFormatting }
    
    guard let tagsJSONData = try? jsonEncoder.encode(tags) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    guard let tagsJSONString =  String(data: tagsJSONData, encoding: .utf8) else {
        print("Unable to encode tags json Data to String")
        return nil
    }
    
    guard let contentJSONData = try? jsonEncoder.encode(content) else {
        print("Unable to encode content to Data")
        return nil
    }
    
    guard let contentJSONString = String(data: contentJSONData, encoding: .utf8) else {
        print("Unable to encode content json Data to String")
        return nil
    }
    
    guard let commitment = "[0,\"\(pubkey)\",\(created_at),\(kind),\(tagsJSONString),\(contentJSONString)]".data(using: .utf8) else {
        print("Unable to encode commitment to Data")
        return nil
    }
    
    let hash = sha256(commitment)
    
    return hex_encode(hash)
}
fileprivate func createNostrObjectSig(privkey: String, id: String) -> String? {
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

extension NostrObject {
    func toJSON() -> JSON {
        return .object([
            "id": .string(self.id),
            "sig": .string(self.sig),
            "tags": .array(self.tags.map { .array($0.map { s in .string(s) }) }),
            "pubkey": .string(self.pubkey),
            "created_at": .number(Double(self.created_at)),
            "kind": .number(Double(self.kind)),
            "content": .string(self.content)
        ])
    }
    
    func toEventJSON() -> JSON {
        return .array([
            .string("EVENT"),
            self.toJSON()
        ])
    }
    
    func toNostrEvent() -> NostrEvent {
        return NostrEvent(content: self.content, pubkey: self.pubkey)
    }
}
