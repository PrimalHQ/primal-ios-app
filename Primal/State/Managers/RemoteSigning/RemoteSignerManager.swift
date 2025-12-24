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
import UserNotifications

extension PrimalShared.NostrEvent {
    convenience init(primalObject: NostrObject) {
        self.init(id: primalObject.id, pubKey: primalObject.pubkey, createdAt: Int64(primalObject.created_at), kind: Int32(primalObject.kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: primalObject.tags), content: primalObject.content, sig: primalObject.sig)
    }
}

class RemoteSignerManager {
    static let instance = RemoteSignerManager()
    
    let connectionRepo = AccountRepositoryFactory.shared.createConnectionRepository()
    let sessionRepo = AccountRepositoryFactory.shared.createSessionRepository()
    let permissionRepo = AccountRepositoryFactory.shared.createPermissionsRepository()
    lazy var sessionEventRepo = AccountRepositoryFactory.shared.createSessionEventRepository(nip46EventsHandler: self)
    
    let remoteSigner: any RemoteSignerService
    
    var cancellables: Set<AnyCancellable> = []

    var signerPubkey: String { signerKeypair.pubKey }
    let signerKeypair: NostrKeyPair = {
        if let pubkey = UserDefaults.standard.string(forKey: "signerPubkey"), let privkey = UserDefaults.standard.string(forKey: "signerPrivkey") {
            return .init(privateKey: privkey, pubKey: pubkey)
        }
        
        guard let newKeypair = NostrKeypair.generate()?.hexVariant, let privkey = newKeypair.privkey else {
            return .init(privateKey: "84900a8ca6e4260db5e75cfbd36b98f9c8f49afc82cd704455744de687e7b8b8", pubKey: "82562bf3224b34e80ef420b96ad6061dbfdb34c9055ac1f8ca5fa562814b9876")
        }
        
        UserDefaults.standard.set(newKeypair.privkey, forKey: "signerPrivkey")
        UserDefaults.standard.set(newKeypair.pubkey, forKey: "signerPubkey")
        
        return .init(privateKey: privkey, pubKey: newKeypair.pubkey)
    }()
    
    
    @Published var activeSessions: [AppSession] = []
    
    @Published var activeConnections: [AppConnection] = []
    
    var permissionsMap: [String: String] = [:]
    
    var missedEventsFromNotifications: [PrimalShared.NostrEvent] = []
    
    var isActive: Bool { !activeSessions.isEmpty }
    var isActivePublisher: AnyPublisher<Bool, Never> {
        $activeSessions.map({ !$0.isEmpty }).removeDuplicates().eraseToAnyPublisher()
    }
    
    var pendingActionsPublisher: AnyPublisher<[SessionEvent], Never> {
        return sessionEventRepo.observeEventsPendingUserAction(signerPubKey: signerPubkey).toPublisher()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
 
    init() {
        
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
            PushNotificationsManager.instance.$pushNotificationsToken
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
                    
                    guard let contentString = contentJson.encodeToString() else { continue }

                    guard let object = NostrObject.createNostrObjectAndSign(pubkey: signerPubkey, privkey: signerKeypair.privateKey, content: contentString, kind: 1337, tags: [["d", "Primal-iOS-App"]]) else { continue }
                    
                    signerEvents.append(object)
                }
                
                UserDefaults.standard.signerNotificationEnableEvents = signerEvents
                PushNotificationsManager.instance.updateNotificationsSettings()
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
    
    func processNotifications(_ notifications: [UNNotification]) {
        
        let eventsWithPubkeys: [(event: [String: Any], eventPubkey: String, id: String, notification: UNNotification)] = notifications.compactMap {
            guard
                let extra = $0.request.content.userInfo["extra"] as? [String: Any],
                let event = extra["nip46_event"] as? [String: Any],
                let eventPubkey = extra["nip46_event_pubkey"] as? String,
                let eventId = event["id"] as? String
            else { return nil }
            
            return (event, eventPubkey, eventId, $0)
        }
        
        guard !eventsWithPubkeys.isEmpty else { return }
        
        missedEventsFromNotifications = eventsWithPubkeys.compactMap {
            guard
                let id = $0.0["id"] as? String,
                let pubkey = $0.0["pubkey"] as? String,
                let createdAt = $0.0["created_at"] as? Double,
                let kind = $0.0["kind"] as? Double,
                let tags = $0.0["tags"] as? [[String]],
                let content = $0.0["content"] as? String,
                let sig = $0.0["sig"] as? String
            else { return nil }
            
            return .init(id: id, pubKey: pubkey, createdAt: Int64(createdAt), kind: Int32(kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: tags), content: content, sig: sig)
        }
        
        let eventPubkeys = eventsWithPubkeys.map({ $0.eventPubkey }).unique()
        
        Task {
            do {
                for eventPubkey in eventPubkeys {
                    if let active = try await sessionRepo.findActiveSessionForConnection(clientPubKey: eventPubkey).getOrNull() {
                        print("NO ACTION")
                    } else {
                        try await sessionRepo.startSession(clientPubKey: eventPubkey)
                    }
                }
                
                let result = try await sessionEventRepo.processMissedEvents(signerKeyPair: signerKeypair, eventIds: eventsWithPubkeys.map { $0.id })
                
                PushNotificationsManager.instance.dismissNotifications(eventsWithPubkeys.map { $0.notification })
            } catch {
                print(error)
            }
        }
    }
    
    func initializeConnection(url: String, userPubKey: String, trustLevel: TrustLevel) {
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
        UtilsResult<NSArray>.companion.success(value: missedEventsFromNotifications) as! UtilsResult<NSArray>
    }
}
