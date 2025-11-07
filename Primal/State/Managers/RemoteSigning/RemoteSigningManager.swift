//
//  RemoteSigningManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 11. 2025..
//

import Foundation
import PrimalShared

class RemoteSigningManager {
    
    let connectionRepo = AccountRepositoryFactory.shared.createConnectionRepository()
    let sessionRepo = AccountRepositoryFactory.shared.createSessionRepository()
    let remoteSigner: any RemoteSignerService
 
    init() {
        
        let userPubKey = IdentityManager.instance.userHexPubkey
                
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        let signerKeypair = NostrKeyPair(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: signerPubkey)
        let signerConnectionInit = AccountRepositoryFactory.shared.createSignerConnectionInitializer(signerKeyPair: signerKeypair, connectionRepository: connectionRepo)
        
        remoteSigner = AccountServiceFactory.shared.createRemoteSignerService(signerKeyPair: signerKeypair, eventSignatureHandler: SigningManager.instance, nostrEncryptionHandler: EncryptionHandler(), connectionRepository: connectionRepo, sessionRepository: sessionRepo)
        
        Task {
            do {
                try await sessionRepo.endAllActiveSessions()
                
                let result = try await signerConnectionInit.initialize(signerPubKey: signerPubkey, userPubKey: userPubKey, connectionUrl: "nostrconnect://ad5691be23a6b1136f155f233ef298b1e34372cb7753c24913dcaeeca3fc43ce?url=https%3A%2F%2Fapp.coracle.social&name=Coracle&image=https%3A%2F%2Fapp.coracle.social%2Fimages%2Flogo.png&perms=sign_event%3A22242%2Cnip04_encrypt%2Cnip04_decrypt%2Cnip44_encrypt%2Cnip44_decrypt&secret=a0twxw&relay=wss%3A%2F%2Frelay.nsec.app%2F&relay=wss%3A%2F%2Fbucket.coracle.social%2F&relay=wss%3A%2F%2Foffchain.pub%2F").getOrThrow()
                
                let id = result?.connectionId
                
                print("REMOTE SIGNER id: \(id)")
                
                let newResult = try await sessionRepo.startSession(connectionId: id ?? "")
                
                print("REMOTE SIGNER RES: \(newResult)")
                
                remoteSigner.start()
            } catch let error {
                print("REMOTE SIGNER error: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30)) {
            print(self)
        }
    }
}

class EncryptionHandler: NostrEncryptionHandler {
    let nostrEncryptHandler = AccountServiceFactory.shared.createNostrEncryptionService()
    
    func nip04Decrypt(userId: String, participantId: String, ciphertext: String) -> UtilsResult<NSString> {
        // TODO: FIND APPROPRIATE NSEC
        nostrEncryptHandler.nip04Decrypt(privateKey: "", pubKey: participantId, ciphertext: ciphertext)
    }
    
    func nip04Encrypt(userId: String, participantId: String, plaintext: String) -> UtilsResult<NSString> {
        // TODO: FIND APPROPRIATE NSEC
        nostrEncryptHandler.nip04Encrypt(privateKey: "", pubKey: participantId, plaintext: plaintext)
    }
    
    func nip44Decrypt(userId: String, participantId: String, ciphertext: String) -> UtilsResult<NSString> {
        // TODO: FIND APPROPRIATE NSEC
        nostrEncryptHandler.nip44Decrypt(privateKey: "", pubKey: participantId, ciphertext: ciphertext)
    }
    
    func nip44Encrypt(userId: String, participantId: String, plaintext: String) -> UtilsResult<NSString> {
        // TODO: FIND APPROPRIATE NSEC
        nostrEncryptHandler.nip44Encrypt(privateKey: "", pubKey: participantId, plaintext: plaintext)
    }
}
