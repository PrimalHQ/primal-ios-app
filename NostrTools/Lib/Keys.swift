//
//  Keys.swift
//  damus
//
//  Created by William Casarin on 2022-05-21.
//

import Foundation
import secp256k1
import Vault

let PUBKEY_HRP = "npub"
let PRIVKEY_HRP = "nsec"

struct FullKeypair: Equatable {
    let pubkey: String
    let privkey: String
}

struct Keypair {
    let pubkey: String
    let privkey: String?
    let pubkey_bech32: String
    let privkey_bech32: String?
    
    func to_full() -> FullKeypair? {
        guard let privkey = self.privkey else {
            return nil
        }
        
        return FullKeypair(pubkey: pubkey, privkey: privkey)
    }
    
    init(pubkey: String, privkey: String?) {
        self.pubkey = pubkey
        self.privkey = privkey
        self.pubkey_bech32 = bech32_pubkey(pubkey) ?? pubkey
        self.privkey_bech32 = privkey.flatMap { bech32_privkey($0) }
    }
}

enum Bech32Key {
    case pub(String)
    case sec(String)
}

struct PrimalKeychainConfiguration: KeychainConfiguration {
    var serviceName = "Primal"
    var accessGroup: String? = nil
    var accountName = "privkey"
}

enum ParsedKey {
    case pub(String)
    case priv(String)
    
    var is_pub: Bool {
        if case .pub = self {
            return true
        }
        
        return false
    }

}

func parse_key(_ thekey: String) -> ParsedKey? {
    var key = thekey
    if key.count > 0 && key.first! == "@" {
        key = String(key.dropFirst())
    }
    
    if let bech_key = decode_bech32_key(key) {
        switch bech_key {
        case .pub(let pk):
            return .pub(pk)
        case .sec(let sec):
            return .priv(sec)
        }
    }
    
    return nil
}

func get_error(parsed_key: ParsedKey?) -> String? {
    if parsed_key == nil {
        return "Invalid key"
    }
    
    return nil
}

func process_login(_ key: ParsedKey, is_pubkey: Bool) -> Bool {
    switch key {
    case .priv(let priv): do {
        guard let pk = privkey_to_pubkey(privkey: priv) else {
            return false
        }
        do {
            try save_keypair(pubkey: pk, privkey: priv)
        } catch {
            return false
        }
        return true
    }
        
    case .pub(let pub): do {
        do {
            try clear_saved_privkey()
        } catch {
            return false
        }
        
        save_pubkey(pubkey: pub)
        return true
    }
    }
}

func decode_bech32_key(_ key: String) -> Bech32Key? {
    guard let decoded = try? bech32_decode(key) else {
        return nil
    }
    
    let hexed = hex_encode(decoded.data)
    if decoded.hrp == "npub" {
        return .pub(hexed)
    } else if decoded.hrp == "nsec" {
        return .sec(hexed)
    }
    
    return nil
}

func bech32_privkey(_ privkey: String) -> String? {
    guard let bytes = hex_decode(privkey) else {
        return nil
    }
    return bech32_encode(hrp: "nsec", bytes)
}

func bech32_pubkey(_ pubkey: String) -> String? {
    guard let bytes = hex_decode(pubkey) else {
        return nil
    }
    return bech32_encode(hrp: "npub", bytes)
}

func bech32_nopre_pubkey(_ pubkey: String) -> String? {
    guard let bytes = hex_decode(pubkey) else {
        return nil
    }
    return bech32_encode(hrp: "", bytes)
}

func bech32_note_id(_ evid: String) -> String? {
    guard let bytes = hex_decode(evid) else {
        return nil
    }
    return bech32_encode(hrp: "note", bytes)
}

func generate_new_keypair() -> Keypair {
    let key = try! secp256k1.Signing.PrivateKey()
    let privkey = hex_encode(key.rawRepresentation)
    let pubkey = hex_encode(Data(key.publicKey.xonly.bytes))
    return Keypair(pubkey: pubkey, privkey: privkey)
}

func privkey_to_pubkey(privkey: String) -> String? {
    guard let sec = hex_decode(privkey) else {
        return nil
    }
    guard let key = try? secp256k1.Signing.PrivateKey(rawRepresentation: sec) else {
        return nil
    }
    return hex_encode(Data(key.publicKey.xonly.bytes))
}

func save_pubkey(pubkey: String) {
    UserDefaults.standard.set(pubkey, forKey: "pubkey")
}

func save_privkey(privkey: String) throws {
    try Vault.savePrivateKey(privkey, keychainConfiguration: PrimalKeychainConfiguration())
}

func clear_saved_privkey() throws {
    try Vault.deletePrivateKey(keychainConfiguration: PrimalKeychainConfiguration())
}

func clear_saved_pubkey() {
    UserDefaults.standard.removeObject(forKey: "pubkey")
}

func save_keypair(pubkey: String, privkey: String) throws {
    save_pubkey(pubkey: pubkey)
    try save_privkey(privkey: privkey)
}

func clear_keypair() throws {
    try clear_saved_privkey()
    clear_saved_pubkey()
}

func get_saved_keypair() -> Keypair? {
    do {
        try removePrivateKeyFromUserDefaults()
        
        return get_saved_pubkey().flatMap { pubkey in
            let privkey = get_saved_privkey()
            return Keypair(pubkey: pubkey, privkey: privkey)
        }
    } catch {
        return nil
    }
}

func get_saved_pubkey() -> String? {
    return UserDefaults.standard.string(forKey: "pubkey")
}

func get_saved_privkey() -> String? {
    let mkey = try? Vault.getPrivateKey(keychainConfiguration: PrimalKeychainConfiguration());
    return mkey.map { $0.trimmingCharacters(in: .whitespaces) }
}

/**
 Detects whether a string might contain an nsec1 prefixed private key.
 It does not determine if it's the current user's private key and does not verify if it is properly encoded or has the right length.
 */
func contentContainsPrivateKey(_ content: String) -> Bool {
    if #available(iOS 16.0, *) {
        return content.contains(/nsec1[02-9ac-z]+/)
    } else {
        let regex = try! NSRegularExpression(pattern: "nsec1[02-9ac-z]+")
        return (regex.firstMatch(in: content, range: NSRange(location: 0, length: content.count)) != nil)
    }
    
}

fileprivate func removePrivateKeyFromUserDefaults() throws {
    guard let privKey = UserDefaults.standard.string(forKey: "privkey") else { return }
    try save_privkey(privkey: privKey)
    UserDefaults.standard.removeObject(forKey: "privkey")
}
