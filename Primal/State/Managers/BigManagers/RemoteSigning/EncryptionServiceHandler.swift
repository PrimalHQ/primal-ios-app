//
//  EncryptionServiceHandler.swift
//  Primal
//
//  Created by Pavle Stevanović on 3. 12. 2025..
//

import Foundation
import PrimalShared
import NostrSDK

class EncryptionServiceHandler: NipsNostrEncryptionService, NIP44v2Encrypting, NostrEncryptionHandler {
    static let instance = EncryptionServiceHandler()
    
    func getPrivkeyForUserId(_ userId: String) -> String? {
        guard
            let npub = userId.hexToNpub(),
            let nsec = ICloudKeychainManager.instance.nsec(npub)
        else {
            if let keypair = OnboardingSession.instance?.newUserKeypair, keypair.hexVariant.pubkey == userId {
                return keypair.hexVariant.privkey
            }
            return nil
        }
        return Keypair(nsec: nsec)?.privateKey.hex
    }
    
    func nip04Decrypt(privateKey: String, pubKey: String, ciphertext: String) -> UtilsResult<NSString> {
        guard let res = decryptDirectMessage(ciphertext, privkey: privateKey, pubkey: pubKey) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return UtilsResultCompanion.shared.success(value: res as NSString) as! UtilsResult<NSString>
    }
    
    func nip04Encrypt(privateKey: String, pubKey: String, plaintext: String) -> UtilsResult<NSString> {
        guard let res = encryptDirectMessage(plaintext, privkey: privateKey, pubkey: pubKey) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return UtilsResultCompanion.shared.success(value: res as NSString) as! UtilsResult<NSString>
    }
    
    func nip44Decrypt(privateKey: String, pubKey: String, ciphertext: String) -> UtilsResult<NSString> {
        guard let privKey = PrivateKey(hex: privateKey), let pubkey = PublicKey(hex: pubKey), let res = try? decrypt(payload: ciphertext, privateKeyA: privKey, publicKeyB: pubkey) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        
        return UtilsResultCompanion.shared.success(value: res as NSString) as! UtilsResult<NSString>
    }
    
    func nip44Encrypt(privateKey: String, pubKey: String, plaintext: String) -> UtilsResult<NSString> {
        guard let privKey = PrivateKey(hex: privateKey), let pubkey = PublicKey(hex: pubKey), let res = try? encrypt(plaintext: plaintext, privateKeyA: privKey, publicKeyB: pubkey) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return UtilsResultCompanion.shared.success(value: res as NSString) as! UtilsResult<NSString>
    }
    
    func nip04Decrypt(userId: String, participantId: String, ciphertext: String) -> UtilsResult<NSString> {
        guard let privkey = getPrivkeyForUserId(userId) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return nip04Decrypt(privateKey: privkey, pubKey: participantId, ciphertext: ciphertext)
    }
    
    func nip04Encrypt(userId: String, participantId: String, plaintext: String) -> UtilsResult<NSString> {
        guard let privkey = getPrivkeyForUserId(userId) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return nip04Encrypt(privateKey: privkey, pubKey: participantId, plaintext: plaintext)
    }
    
    func nip44Decrypt(userId: String, participantId: String, ciphertext: String) -> UtilsResult<NSString> {
        guard let privkey = getPrivkeyForUserId(userId) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return nip44Decrypt(privateKey: privkey, pubKey: participantId, ciphertext: ciphertext)
    }
    
    func nip44Encrypt(userId: String, participantId: String, plaintext: String) -> UtilsResult<NSString> {
        guard let privkey = getPrivkeyForUserId(userId) else {
            return UtilsResultCompanion.shared.failure(exception: .init(message: "Test")) as! UtilsResult<NSString>
        }
        return nip44Encrypt(privateKey: privkey, pubKey: participantId, plaintext: plaintext)
    }
}
