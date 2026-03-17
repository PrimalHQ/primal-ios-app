//
//  SigningManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 11. 2025..
//

import PrimalShared
import NostrSDK

class SigningManager {
    static let instance = SigningManager()
}

enum SigningError: Error {
    case noNsec
}

extension SigningManager: NostrEventSignatureHandler {
    func __signNostrEvent(unsignedNostrEvent: NostrUnsignedEvent, completionHandler: @escaping @Sendable (SignResult?, (any Error)?) -> Void) {
        guard
            let npub = unsignedNostrEvent.pubKey.hexToNpub(),
            let nsec = ICloudKeychainManager.instance.nsec(npub),
            let keyPair = Keypair(nsec: nsec)
        else {
            completionHandler(nil, SigningError.noNsec)
            return
        }
        
        let privateKey = keyPair.privateKey.hex
        
        let tags = NostrExtensions.shared.mapAsListOfListOfStrings(tags: unsignedNostrEvent.tags)
        guard let object = NostrObject.createAndSign(
            pubkey: keyPair.publicKey.hex,
            privkey: privateKey,
            content: unsignedNostrEvent.content,
            kind: Int(unsignedNostrEvent.kind),
            tags: tags,
            createdAt: unsignedNostrEvent.createdAt
        ) else {
            completionHandler(SignResult.Rejected(error: .init(message: "Failed to sign", cause: nil)), nil)
            return
        }
        
        completionHandler(
            SignResult.Signed(event: .init(
                id: object.id, pubKey: object.pubkey, createdAt: object.created_at, kind: Int32(object.kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: object.tags), content: object.content, sig: object.sig
            )), nil
        )
    }
    
    func verifySignature(nostrEvent: PrimalShared.NostrEvent) -> Bool {
        true
    }
}

extension SigningManager: PrimalPublisher {
    func __signPublishImportNostrEvent(unsignedNostrEvent: NostrUnsignedEvent, outboxRelays: [String]) async throws -> PrimalPublishResult {
        throw WalletError.noWallet
    }
}
