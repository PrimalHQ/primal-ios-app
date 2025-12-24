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
import GenericJSON

class RemoteSignerManager {
    static let instance = RemoteSignerManager()
    
    let connectionRepo = AccountRepositoryFactory.shared.createConnectionRepository()
    let sessionRepo = AccountRepositoryFactory.shared.createSessionRepository()
    let permissionRepo = AccountRepositoryFactory.shared.createPermissionsRepository()
    lazy var sessionEventRepo = AccountRepositoryFactory.shared.createSessionEventRepository(nip46EventsHandler: self)
    
    let remoteSigner: any RemoteSignerService
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var activeSessions: [AppSession] = []
    
    @Published var activeConnections: [AppConnection] = []
    
    var permissionsMap: [String: String] = [:]
    
    var isActive: Bool { !activeSessions.isEmpty }
    var isActivePublisher: AnyPublisher<Bool, Never> {
        $activeSessions.map({ !$0.isEmpty }).removeDuplicates().eraseToAnyPublisher()
    }
    
    var pendingActionsPublisher: AnyPublisher<[SessionEvent], Never> {
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        return sessionEventRepo.observeEventsPendingUserAction(signerPubKey: signerPubkey).toPublisher()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
 
    init() {
        let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
        let signerKeypair = NostrKeyPair(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: signerPubkey)
        
        remoteSigner = AccountServiceFactory.shared.createRemoteSignerService(signerKeyPair: signerKeypair, eventSignatureHandler: SigningManager.instance, nostrEncryptionService: EncryptionServiceHandler.instance, nostrEncryptionHandler: EncryptionServiceHandler.instance, connectionRepository: connectionRepo, sessionRepository: sessionRepo, sessionInactivityTimeoutInMinutes: 0)
        
        remoteSigner.initialize()
        
        sessionRepo.observeActiveSessions(signerPubKey: signerPubkey)
            .toPublisher()
//            .map { $0 as [AppSession] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                self?.activeSessions = sessions
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            connectionRepo.observeAllConnections(signerPubKey: signerPubkey).toPublisher().replaceError(with: []),
            AppDelegate.shared.$pushNotificationsToken
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (connections, tokenData) in
                self?.activeConnections = connections
                
                guard let self, let tokenData else { return }
                let currentToken = tokenData.map { String(format: "%02.2hhx", $0) }.joined()

                var signerEvents: [NostrObject] = []
                
                for connection in connections {
                    let relays = connection.relays
                    let appPubkey = connection.clientPubKey

                    let contentJson: [String: JSON] = [
                        "token": .string(currentToken),
                        "relays": .array(relays.map({ .string($0) })),
                        "clientPubKeys": [.string(appPubkey)]
                    ]
                    
                    let signerPubkey = "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876"
                    let privkey = "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8"
                    
                    guard let contentString = contentJson.encodeToString() else { continue }

                    guard let object = NostrObject.createNostrObjectAndSign(pubkey: signerPubkey, privkey: privkey, content: contentString, kind: 1337, tags: [["d", "Primal-iOS-App"]]) else { continue }
                    
                    signerEvents.append(object)
                }
                
                UserDefaults.standard.signerNotificationEnableEvents = signerEvents
                AppDelegate.shared.updateNotificationsSettings()
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
        Task { @MainActor in
            guard let permissionsMap = try await permissionRepo.getNamingMap().getOrThrow() else { return }
            
            var newDic: [String: String] = [:]
            for (key, value) in permissionsMap {
                if let keyS = key as? String, let valS = value as? String {
                    newDic[keyS] = valS
                }
            }
            self.permissionsMap = newDic
        }
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
    
    func endAllSessions() {
        endSessions(activeSessions)
    }
    
    func endSessions(_ sessions: [AppSession]) {
        Task {
            try? await sessionRepo.endSessions(sessionIds: sessions.map { $0.sessionId })
        }
    }
}

extension RemoteSignerManager: Nip46EventsHandler {
    func __fetchNip46Events(eventIds: [String]) async throws -> UtilsResult<NSArray> {
        UtilsResult<NSArray>.companion.success(value: []) as! UtilsResult<NSArray>
    }
}
