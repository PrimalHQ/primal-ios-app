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
    let permissionRepo = AccountRepositoryFactory.shared.createPermissionsRepository()
    let remoteSigner: any RemoteSignerService
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var activeSessions: [AppSession] = []
    
    @Published var activeConnections: [AppConnection] = []
    
    var isActive: Bool { !activeSessions.isEmpty }
    var isActivePublisher: AnyPublisher<Bool, Never> {
        $activeSessions.map({ !$0.isEmpty }).removeDuplicates().eraseToAnyPublisher()
    }
 
    init() {
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        let signerKeypair = NostrKeyPair(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: signerPubkey)
        
        remoteSigner = AccountServiceFactory.shared.createRemoteSignerService(signerKeyPair: signerKeypair, eventSignatureHandler: SigningManager.instance, nostrEncryptionService: EncryptionServiceHandler.instance, nostrEncryptionHandler: EncryptionServiceHandler.instance, connectionRepository: connectionRepo, sessionRepository: sessionRepo)
        
        remoteSigner.initialize()
        
        sessionRepo.observeActiveSessions(signerPubKey: signerPubkey)
            .toPublisher()
            .map { $0 as [AppSession] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                self?.activeSessions = sessions
            }
            .store(in: &cancellables)
        
        connectionRepo.observeAllConnections(signerPubKey: signerPubkey)
            .toPublisher()
            .map { $0 as [AppConnection] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connections in
                self?.activeConnections = connections
            }
            .store(in: &cancellables)
        
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
    
    func initializeConnection(url: String, userPubKey: String, trustLevel: TrustLevel) {
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        let signerKeypair = NostrKeyPair(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: signerPubkey)
        
        let signerConnectionInit = AccountRepositoryFactory.shared.createSignerConnectionInitializer(connectionRepository: connectionRepo, sessionRepository: sessionRepo)
        
        Task {
            do {
                let result = try await signerConnectionInit.initialize(signerPubKey: signerPubkey, userPubKey: userPubKey, connectionUrl: url, trustLevel: trustLevel).getOrThrow()
            } catch let error {
                print("REMOTE SIGNER error: \(error)")
            }
        }
    }
    
    func endSessions(_ sessions: [AppSession]) {
        Task {
            try? await sessionRepo.endSessions(sessionIds: sessions.map { $0.sessionId })
        }
    }
}

extension RemoteSigningManager: Nip46EventsHandler {
    func __fetchNip46Events(eventIds: [String]) async throws -> UtilsResult<NSArray> {
        UtilsResult<NSArray>.companion.success(value: []) as! UtilsResult<NSArray>
    }
}
