//
//  NostrKeypair.swift
//  Primal
//
//  Created by Nikola Lukovic on 12.7.23..
//

import Foundation
import secp256k1

struct HexKeypair {
    let pubkey: String
    let privkey: String
}

struct NKeypair {
    let npub: String
    let nsec: String
}

struct NostrKeypair {
    let hexVariant: HexKeypair
    let nVariant: NKeypair
}

extension NKeypair {
    static func nostrKeypair(npub: String, nsec: String) -> NostrKeypair? {
        guard
            let decodedHexPubkey = try? bech32_decode(npub)
        else {
            print("NKeypair: Failed to convert npub to hex")
            return nil
        }

        guard
            let decodedHexPrivkey = try? bech32_decode(nsec)
        else {
            print("NKeypair: Failed to convert nsec to hex")
            return nil
        }
        
        let hexPubkey = hex_encode(decodedHexPubkey.data)
        let hexPrivkey = hex_encode(decodedHexPrivkey.data)
        
        let nkeypair = NKeypair(npub: npub, nsec: nsec)
        let hexkeypair = HexKeypair(pubkey: hexPubkey, privkey: hexPrivkey)
        
        return NostrKeypair(hexVariant: hexkeypair, nVariant: nkeypair)
    }
    
    static func isValidNsec(_ key: String) -> Bool {
        guard let decoded = try? bech32_decode(key) else {
            return false
        }
        
        let hexed = hex_encode(decoded.data)
        if decoded.hrp == "nsec" {
            return true
        }
        
        return false
    }
}

extension HexKeypair {
    static func nostrKeypair(hexPubkey: String, hexPrivkey: String) -> NostrKeypair? {
        guard let npub = bech32_pubkey(hexPubkey) else {
            print("HexKeypair: Failed to convert hex pubkey to npub")
            return nil
        }
        
        guard let nsec = bech32_privkey(hexPrivkey) else {
            print("HexKeypair: Failed to convert hex privkey to nsec")
            return nil
        }
        
        let hexKeypair = HexKeypair(pubkey: hexPubkey, privkey: hexPrivkey)
        let nKeypair = NKeypair(npub: npub, nsec: nsec)
        
        return NostrKeypair(hexVariant: hexKeypair, nVariant: nKeypair)
    }
    
    static func privkeyToPubkey(_ hexPrivkey: String) -> String? {
        guard let sec = hex_decode(hexPrivkey) else {
            print("HexKeypair: Failed to hex decode privkey")
            return nil
        }
        guard let key = try? secp256k1.Signing.PrivateKey(rawRepresentation: sec) else {
            return nil
        }
        
        return hex_encode(Data(key.publicKey.xonly.bytes))
    }
    
    static func nsecToHexPrivkey(_ nsec: String) -> String? {
        guard let decoded = try? bech32_decode(nsec) else {
            return nil
        }
        
        if decoded.hrp == "nsec" {
            return hex_encode(decoded.data)
        }
        
        return nil
    }
}