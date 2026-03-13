//
//  NwcServiceManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 12. 2. 2026..
//

import Foundation
import Combine
import GenericJSON
import PrimalShared

private extension String {
    static let autoStartNWCServiceKey = "autoStartNWCServiceKey"
}

class NwcServiceManager {
    static let shared = NwcServiceManager()
    
    @Published private(set) var activeServices: [String: NWCService] = [:]
    
    @Published private(set) var autoStartService: Bool = UserDefaults.standard.bool(forKey: .autoStartNWCServiceKey)
    
    
    var isServiceActive: Bool { !activeServices.isEmpty }
    
    var isServiceActivePublisher: AnyPublisher<Bool, Never> {
        $activeServices.map({ !$0.isEmpty }).removeDuplicates().eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        $autoStartService.removeDuplicates().dropFirst().sink { autoStartService in
            UserDefaults.standard.set(autoStartService, forKey: .autoStartNWCServiceKey)
        }
        .store(in: &cancellables)

        PushNotificationsManager.instance.$pushNotificationsToken
            .sink { [weak self] _ in
                self?.updatePushNotificationEvents()
            }
            .store(in: &cancellables)
    }
    
    func setAutoStart(_ isOn: Bool) {
        autoStartService = isOn

        if isOn {
            startService()
            updatePushNotificationEvents()
        } else {
            UserDefaults.standard.nwcNotificationEnableEvents = []
            PushNotificationsManager.instance.updateNotificationsSettings()
        }
    }
    
    func endService() {
        activeServices = [:]
    }
    
    func startService() {
        let pubkeys = LoginManager.instance.loggedInNpubs()
            .filter { ICloudKeychainManager.instance.hasNsec($0) }
            .compactMap { $0.npubToPubkey() }

        let nwcRepo = WalletManager.instance.nwcRepo

        Task { @MainActor in
            var pubkeysWithNWC: [String] = []
            for pubkey in pubkeys {
                guard try await !nwcRepo.getConnections(userId: pubkey).isEmpty else { continue }
                pubkeysWithNWC.append(pubkey)
            }

            activeServices = pubkeysWithNWC.reduce(into: [:], { $0[$1] = activeServices[$1] ?? NWCService(pubkey: $1) })
        }

        updatePushNotificationEvents()
    }

    func updatePushNotificationEvents() {
        guard autoStartService else {
            UserDefaults.standard.nwcNotificationEnableEvents = []
            PushNotificationsManager.instance.updateNotificationsSettings()
            return
        }
        guard let tokenData = PushNotificationsManager.instance.pushNotificationsToken else { return }

        let currentToken = tokenData.map { String(format: "%02.2hhx", $0) }.joined()

        let pubkeys = LoginManager.instance.loggedInNpubs()
            .filter { ICloudKeychainManager.instance.hasNsec($0) }
            .compactMap { $0.npubToPubkey() }

        let nwcRepo = WalletManager.instance.nwcRepo

        Task { @MainActor in
            var nwcEvents: [NostrObject] = []

            for pubkey in pubkeys {
                let connections: [NwcConnection]
                do {
                    connections = try await nwcRepo.getConnections(userId: pubkey)
                } catch {
                    continue
                }

                for connection in connections {
                    let contentJson: [String: JSON] = [
                        "token": .string(currentToken),
                        "relays": .array([.string(connection.relay)]),
                        "clientPubKeys": .array([])
                    ]

                    guard let contentString = contentJson.encodeToString() else { continue }

                    guard let object = NostrObject.createNostrObjectAndSign(
                        pubkey: connection.serviceKeyPair.pubKey,
                        privkey: connection.serviceKeyPair.privateKey,
                        content: contentString,
                        kind: 1337,
                        tags: [["d", "Primal-iOS-App"]]
                    ) else { continue }

                    nwcEvents.append(object)
                }
            }

            UserDefaults.standard.nwcNotificationEnableEvents = nwcEvents
            PushNotificationsManager.instance.updateNotificationsSettings()
        }
    }
}

class NWCService {
    let nwcService: NwcService
 
    init(pubkey: String) {
        nwcService = WalletRepositoryFactory.shared.createNwcService(walletRepository: WalletManager.instance.walletRepo, nostrEncryptionService: EncryptionServiceHandler.instance, nwcRepository: WalletManager.instance.nwcRepo)
        
        nwcService.initialize(userId: pubkey)
    }
    
    deinit {
        nwcService.destroy()
    }
}
