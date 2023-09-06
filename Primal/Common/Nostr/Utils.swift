//
//  Utils.swift
//  Primal
//
//  Created by Nikola Lukovic on 30.8.23..
//

import Foundation
import CryptoSwift

func decryptDirectMessage(_ content: String, privkey: String, pubkey: String) -> String? {
    let splitted = Array(content.split(separator: "?"))
    
    if splitted.count != 2 {
        return nil
    }
    
    guard let content = base64_decode(String(splitted[0])) else {
        return nil
    }
    
    var sec = String(splitted[1])
    if !sec.hasPrefix("iv=") {
        return nil
    }
    
    sec = String(sec.dropFirst(3))
    guard let iv = base64_decode(sec) else {
        return nil
    }
    
    guard
        let sharedSecret = get_shared_secret(privkey: privkey, pubkey: pubkey),
        let aes = try? AES(key: sharedSecret, blockMode: CBC(iv: iv), padding: .pkcs7),
        let decryptedBytes = try? aes.decrypt(content)
    else {
        return nil
    }
    
    return String(data: Data(decryptedBytes), encoding: .utf8)
}

func encryptDirectMessage(_ content: String, privkey: String, pubkey: String) -> String? {
    let iv = AES.randomIV(AES.blockSize)
    
    guard
        let sharedSecret = get_shared_secret(privkey: privkey, pubkey: pubkey),
        let aes = try? AES(key: sharedSecret, blockMode: CBC(iv: iv), padding: .pkcs7),
        let encryptedBytes = try? aes.encrypt(Array(content.utf8))
    else {
        return nil
    }
    
    let base64Content = encryptedBytes.toBase64()
    let base64Iv = iv.toBase64()
    
    return "\(base64Content)?iv=\(base64Iv)"
}
