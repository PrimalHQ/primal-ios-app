//
//  Crypto.swift
//
//  Primal
//  damus
//
//  Created by William Casarin on 2022-04-11.
//  Modified by Nikola Lukovic on 11.7.23..
//

import Foundation
import CommonCrypto
import secp256k1
import secp256k1_implementation

enum EncEncoding {
    case base64
    case bech32
}

func sha256(_ data: Data) -> Data {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

func random_bytes(count: Int) -> Data {
    var bytes = [Int8](repeating: 0, count: count)
    guard
        SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess
    else {
        fatalError("can't copy secure random data")
    }
    return Data(bytes: bytes, count: count)
}

func encrypt_message(message: String, privkey: String, to_pk: String, encoding: EncEncoding = .base64) -> String? {
    let iv = random_bytes(count: 16).bytes
    guard let shared_sec = get_shared_secret(privkey: privkey, pubkey: to_pk) else {
        return nil
    }
    let utf8_message = Data(message.utf8).bytes
    guard let enc_message = aes_encrypt(data: utf8_message, iv: iv, shared_sec: shared_sec) else {
        return nil
    }
    
    switch encoding {
    case .base64:
        return encode_dm_base64(content: enc_message.bytes, iv: iv)
    case .bech32:
        return encode_dm_bech32(content: enc_message.bytes, iv: iv)
    }
    
}

func get_shared_secret(privkey: String, pubkey: String) -> [UInt8]? {
    guard let privkey_bytes = try? privkey.bytes else {
        return nil
    }
    guard var pk_bytes = try? pubkey.bytes else {
        return nil
    }
    pk_bytes.insert(2, at: 0)
    
    var publicKey = secp256k1_pubkey()
    var shared_secret = [UInt8](repeating: 0, count: 32)
    
    var ok =
    secp256k1_ec_pubkey_parse(
        secp256k1.Context.raw,
        &publicKey,
        pk_bytes,
        pk_bytes.count) != 0
    
    if !ok {
        return nil
    }
    
    ok = secp256k1_ecdh(
        secp256k1.Context.raw,
        &shared_secret,
        &publicKey,
        privkey_bytes, {(output,x32,_,_) in
            memcpy(output,x32,32)
            return 1
        }, nil) != 0
    
    if !ok {
        return nil
    }
    
    return shared_secret
}

func encode_dm_bech32(content: [UInt8], iv: [UInt8]) -> String {
    let content_bech32 = bech32_encode(hrp: "pzap", content)
    let iv_bech32 = bech32_encode(hrp: "iv", iv)
    return content_bech32 + "_" + iv_bech32
}

func encode_dm_base64(content: [UInt8], iv: [UInt8]) -> String {
    let content_b64 = base64_encode(content)
    let iv_b64 = base64_encode(iv)
    return content_b64 + "?iv=" + iv_b64
}

func base64_encode(_ content: [UInt8]) -> String {
    return Data(content).base64EncodedString()
}

func aes_encrypt(data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
    return aes_operation(operation: CCOperation(kCCEncrypt), data: data, iv: iv, shared_sec: shared_sec)
}

func aes_operation(operation: CCOperation, data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
    let data_len = data.count
    let bsize = kCCBlockSizeAES128
    let len = Int(data_len) + bsize
    var decrypted_data = [UInt8](repeating: 0, count: len)
    
    let key_length = size_t(kCCKeySizeAES256)
    if shared_sec.count != key_length {
        assert(false, "unexpected shared_sec len: \(shared_sec.count) != 32")
        return nil
    }
    
    let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
    let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
    
    var num_bytes_decrypted :size_t = 0
    
    let status = CCCrypt(operation,  /*op:*/
                         algorithm,  /*alg:*/
                         options,    /*options:*/
                         shared_sec, /*key:*/
                         key_length, /*keyLength:*/
                         iv,         /*iv:*/
                         data,       /*dataIn:*/
                         data_len, /*dataInLength:*/
                         &decrypted_data,/*dataOut:*/
                         len,/*dataOutAvailable:*/
                         &num_bytes_decrypted/*dataOutMoved:*/
    )
    
    if UInt32(status) != UInt32(kCCSuccess) {
        return nil
    }
    
    return Data(bytes: decrypted_data, count: num_bytes_decrypted)
    
}
