//
//  SigningManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 11. 2025..
//

import PrimalShared

class SigningManager {
    static let instance = SigningManager()
}


extension SigningManager: NostrEventSignatureHandler {
    func __signNostrEvent(unsignedNostrEvent: NostrUnsignedEvent, completionHandler: @escaping @Sendable (SignResult?, (any Error)?) -> Void) {
        let tags = NostrExtensions.shared.mapAsListOfListOfStrings(tags: unsignedNostrEvent.tags)
        guard let object = NostrObject.create(content: unsignedNostrEvent.pubKey, kind: Int(unsignedNostrEvent.kind), tags: tags) else {
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
