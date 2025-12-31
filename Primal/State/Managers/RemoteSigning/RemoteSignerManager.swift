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
    
    
    @Published var activeSessions: [RemoteAppSession] = []
    
    @Published var activeConnections: [RemoteAppConnection] = []
    
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
        
        sessionRepo.observeOngoingSessions(signerPubKey: signerPubkey)
            .toPublisher()
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
    
    func processMissedEvents() {
        guard let object = NostrObject.createNostrObjectAndSign(pubkey: signerPubkey, privkey: signerKeypair.privateKey, content: "", kind: 1337, tags: [["d", "Primal-iOS-App"]]) else { return }

        SocketRequest(name: "get_queued_events_for_nip46", payload: ["event_from_signer": object.toJSON()]).publisher()
            .sink(receiveValue: { [self] res in
                guard !res.events.isEmpty else { return }
                
                missedEventsFromNotifications = res.events.compactMap { .init(primalObject: NostrObject.fromJSONDict($0)) }
                             
                let eventPubkeys = missedEventsFromNotifications.map({ $0.pubKey }).unique()
                let eventIds = missedEventsFromNotifications.map({ $0.id })

                Task {
                    do {
                        for eventPubkey in eventPubkeys {
                            if let active = try await sessionRepo.findActiveSessionForConnection(clientPubKey: eventPubkey).getOrNull() {
                                print("NO ACTION")
                            } else {
                                _ = try await sessionRepo.startSession(clientPubKey: eventPubkey)
                            }
                        }
                        
                        let result = try await sessionEventRepo.processMissedEvents(signerKeyPair: signerKeypair, eventIds: eventIds)
                        
                    } catch {
                        print(error)
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    
    func initializeConnection(url: String, userPubKey: String, trustLevel: TrustLevel) async throws -> RemoteAppConnection? {
        let signerConnectionInit = AccountRepositoryFactory.shared.createSignerConnectionInitializer(connectionRepository: connectionRepo, sessionRepository: sessionRepo)
        
        return try await signerConnectionInit.initialize(
            signerPubKey: signerPubkey,
            userPubKey: userPubKey,
            connectionUrl: url,
            trustLevel: trustLevel,
            nwcConnectionString: nil,
        ).getOrThrow()
    }
    
    func endAllSessions() {
        endSessions(activeSessions)
    }
    
    func endSessions(_ sessions: [RemoteAppSession]) {
        Task {
            try? await sessionRepo.endSessions(sessionIds: sessions.map { $0.sessionId })
        }
    }
    
    func checkDeliveredNotifications() {
        RemoteSignerManager.instance.processMissedEvents()
        
        UNUserNotificationCenter.current().getDeliveredNotifications  { notifications in
            // Background thread
            DispatchQueue.main.async {
                RemoteSignerManager.instance.dismissRemoteSignerNotifications(notifications)
            }
        }
    }
    
    private func dismissRemoteSignerNotifications(_ notifications: [UNNotification]) {
        let remoteSignerNotifications: [UNNotification] = notifications.compactMap {
            guard
                let extra = $0.request.content.userInfo["extra"] as? [String: Any],
                let event = extra["nip46_event"] as? [String: Any],
                let eventPubkey = extra["nip46_event_pubkey"] as? String,
                let eventId = event["id"] as? String
            else { return nil }
            
            return $0
        }
        
        PushNotificationsManager.instance.dismissNotifications(remoteSignerNotifications)
    }
}

extension RemoteSignerManager: Nip46EventsHandler {
    func __fetchNip46Events(eventIds: [String]) async throws -> UtilsResult<NSArray> {
        UtilsResult<NSArray>.companion.success(value: missedEventsFromNotifications) as! UtilsResult<NSArray>
    }
}
