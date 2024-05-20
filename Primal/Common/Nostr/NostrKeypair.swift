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
    let privkey: String?
}

struct NKeypair {
    let npub: String
    let nsec: String?
}

struct NostrKeypair {
    let hexVariant: HexKeypair
    let nVariant: NKeypair
}

enum KeyType {
    case npub
    case nsec
}

extension NKeypair {
    static func nostrKeypair(npub: String, nsec: String? = nil) -> NostrKeypair? {
        guard
            let decodedHexPubkey = try? bech32_decode(npub)
        else {
            print("NKeypair: Failed to convert npub to hex")
            return nil
        }

        var hexPrivkey: String? = nil
        if let n = nsec {
            guard
                let decodedHexPrivkey = try? bech32_decode(n)
            else {
                print("NKeypair: Failed to convert nsec to hex")
                return nil
            }
            
            hexPrivkey = hex_encode(decodedHexPrivkey.data)
        }
        
        let hexPubkey = hex_encode(decodedHexPubkey.data)
        
        let nkeypair = NKeypair(npub: npub, nsec: nsec)
        let hexkeypair = HexKeypair(pubkey: hexPubkey, privkey: hexPrivkey)
        
        return NostrKeypair(hexVariant: hexkeypair, nVariant: nkeypair)
    }
    
    static func isValidNsec(_ key: String) -> Bool {
        guard let decoded = try? bech32_decode(key) else {
            return false
        }
        
        if decoded.hrp == "nsec" {
            return true
        }
        
        return false
    }
    
    static func isValidNpub(_ key: String) -> Bool {
        guard let decoded = try? bech32_decode(key) else {
            return false
        }
        
        if decoded.hrp == "npub" {
            return true
        }
        
        return false
    }
    
    static func isValidNsecOrNpub(_ key: String) -> Bool {
        return isValidNsec(key) || isValidNpub(key)
    }
    
    static func type(_ key: String) -> KeyType? {
        guard let decoded = try? bech32_decode(key) else {
            return nil
        }
        
        if decoded.hrp == "npub" {
            return .npub
        } else if decoded.hrp == "nsec" {
            return .nsec
        }
        
        return nil
    }
}

extension HexKeypair {
    static func nostrKeypair(hexPubkey: String, hexPrivkey: String? = nil) -> NostrKeypair? {
        guard let npub = bech32_pubkey(hexPubkey) else {
            print("HexKeypair: Failed to convert hex pubkey to npub")
            return nil
        }
        
        var nsec: String? = nil
        
        if let h = hexPrivkey {
            guard let n = bech32_privkey(h) else {
                print("HexKeypair: Failed to convert hex privkey to nsec")
                return nil
            }
            
            nsec = n
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
        guard let key = try? secp256k1.Schnorr.PrivateKey(dataRepresentation: sec) else {
            return nil
        }
        
        return hex_encode(Data(key.xonly.bytes))
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

    static func npubToHexPubkey(_ npub: String) -> String? {
        guard let decoded = try? bech32_decode(npub) else {
            return nil
        }

        if decoded.hrp == "npub" {
            return hex_encode(decoded.data)
        }

        return nil
    }
}

extension NostrKeypair {
    static func generate() -> NostrKeypair? {
        guard let key = try? secp256k1.Signing.PrivateKey() else { return nil }
        let privkey = hex_encode(key.dataRepresentation)
        let pubkey = hex_encode(Data(key.publicKey.xonly.bytes))
        
        return HexKeypair.nostrKeypair(hexPubkey: pubkey, hexPrivkey: privkey)
    }
}

extension HexKeypair: Equatable {
    static func == (lhs: HexKeypair, rhs: HexKeypair) -> Bool {
        return lhs.privkey == rhs.privkey && lhs.pubkey == rhs.pubkey
    }
}

extension NKeypair: Equatable {
    static func == (lhs: NKeypair, rhs: NKeypair) -> Bool {
        return lhs.nsec == rhs.nsec && lhs.npub == rhs.npub
    }
}

extension NostrKeypair: Equatable {
    static func == (lhs: NostrKeypair, rhs: NostrKeypair) -> Bool {
        return lhs.hexVariant == rhs.hexVariant && lhs.nVariant == rhs.nVariant
    }
}
