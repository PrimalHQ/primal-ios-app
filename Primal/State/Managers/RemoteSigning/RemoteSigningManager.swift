//
//  RemoteSigningManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 11. 2025..
//

import Combine
import Foundation
import PrimalShared
import NostrSDK

class RemoteSigningManager {
    static let instance = RemoteSigningManager()
    
    let connectionRepo = AccountRepositoryFactory.shared.createConnectionRepository()
    let sessionRepo = AccountRepositoryFactory.shared.createSessionRepository()
    let remoteSigner: any RemoteSignerService
    
    var cancellables: Set<AnyCancellable> = []
 
    init() {
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        let signerKeypair = NostrKeyPair(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: signerPubkey)
        
        remoteSigner = AccountServiceFactory.shared.createRemoteSignerService(signerKeyPair: signerKeypair, eventSignatureHandler: SigningManager.instance, nostrEncryptionService: EncryptionServiceHandler.instance, nostrEncryptionHandler: EncryptionServiceHandler.instance, connectionRepository: connectionRepo, sessionRepository: sessionRepo)
        
        remoteSigner.initialize()
        
        let sessionEventRepo = AccountRepositoryFactory.shared.createSessionEventRepository(nip46EventsHandler: self)
//        "3bfadd33-08ec-4ba1-b902-b62c7ea90166"
//        sessionRepo.observeSessionsByConnectionId(connectionId: "8ab4d840-6272-43de-a0de-1b93539b23ba")
//            .toPublisher()
//            .sink { session in
//                for session in session.makeIterator() {
//                    print(session.sessionId)
//                    
//                    sessionEventRepo.observeEventsForSession(sessionId: session.sessionId)
//                        .toPublisher()
//                        .sink { sessionEvents in
//                            for event in sessionEvents.makeIterator() {
//                                print(event.description)
//                            }
//                        }
//                        .store(in: &self.cancellables)
//                }
//            }
//            .store(in: &cancellables)
//        
       
    }
    
    func startSession(url: String, userPubKey: String, trustLevel: TrustLevel) {
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        let signerKeypair = NostrKeyPair(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: signerPubkey)
        
        let signerConnectionInit = AccountRepositoryFactory.shared.createSignerConnectionInitializer(signerKeyPair: signerKeypair, connectionRepository: connectionRepo, nostrEncryptionService: EncryptionServiceHandler.instance)
        
        Task {
            do {
                try await connectionRepo.deleteConnectionsByUser(userPubKey: userPubKey)
                
                let result = try await signerConnectionInit.initialize(signerPubKey: signerPubkey, userPubKey: userPubKey, connectionUrl: url, trustLevel: trustLevel).getOrThrow()
                
                guard let id = result?.connectionId else { return }
                
                print("REMOTE SIGNER id: \(id)")
                
                let newResult = try await sessionRepo.startSession(connectionId: id)
                
                print("REMOTE SIGNER RES: \(newResult)")
                
            } catch let error {
                print("REMOTE SIGNER error: \(error)")
            }
        }
    }
}

extension RemoteSigningManager: Nip46EventsHandler {
    func __fetchNip46Events(eventIds: [String]) async throws -> UtilsResult<NSArray> {
        UtilsResult<NSArray>.companion.success(value: []) as! UtilsResult<NSArray>
    }
}
