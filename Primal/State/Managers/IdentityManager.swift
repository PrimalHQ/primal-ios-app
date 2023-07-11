//
//  IdentityManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Combine
import Foundation
import GenericJSON

final class IdentityManager {
    private init() {}
    
    static let instance = IdentityManager()

    var userHex: String {
        get {
            let result = get_saved_keypair()
            
            guard
                let keypair = result,
                let decoded = try? bech32_decode(keypair.pubkey_bech32)
            else {
                return ""
            }
            
            return hex_encode(decoded.data)
        }
    }
    
    var isNewUser: Bool = false
    
    @Published var user: PrimalUser?
    @Published var userStats: NostrUserProfileInfo?
    @Published var userSettings: PrimalSettings?
    @Published var userRelays: [String: RelayInfo]?
    @Published var userContacts: Contacts = Contacts(created_at: -1, contacts: [])
    
    @Published var didFinishInit: Bool = false
        
    func requestUserInfos() {
        let request: JSON = .object([
            "pubkeys": .array([.string(userHex)])
        ])
        
        Connection.instance.requestCache(name: "user_infos", request: request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .metadata:
                    let nostrUser = NostrContent(json: .object(response.arrayValue?[2].objectValue ?? [:]))
                    self.user = PrimalUser(nostrUser: nostrUser)
                case .userScore:
                    if let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue {
                        guard let content: [String: UInt32] = try? JSONDecoder().decode([String: UInt32].self, from: contentString.data(using: .utf8)!) else {
                            print("IdentityManager: requestUserInfos: Unable to decode content json for kind: \(NostrKind.userScore.rawValue)")
                            break
                        }
                        
                        guard let score = content.values.first else {
                            fatalError("IdentityManager: requestUserInfos: Unable to get user score")
                        }
                        
                        print("IdentityManager: requestUserInfos: User score: \(score)")
                    }
                case .mediaMetadata:
                    print("IdentityManager: requestUserInfos: Got mediaMetada")
                default:
                    assertionFailure("IdentityManager: requestUserInfos: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    func requestUserProfile() {
        let request: JSON = .object([
            "cache": .array([
                "user_profile",
                .object([
                    "pubkey": .string(userHex)
                ])
            ])
        ])
        
        Connection.instance.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .metadata:
                    let nostrUser = NostrContent(json: .object(response.arrayValue?[2].objectValue ?? [:]))
                    self.user = PrimalUser(nostrUser: nostrUser)
                case .userStats:
                    guard let nostrUserProfileInfo: NostrUserProfileInfo = try? JSONDecoder().decode(NostrUserProfileInfo.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding nostr stats string to json")
                        return
                    }
                    
                    self.userStats = nostrUserProfileInfo
                default:
                    assertionFailure("IdentityManager: requestUserProfile: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    func requestDefaultSettings(_ callback: @escaping (_: PrimalSettings) -> Void) {
        let request: JSON = .object([
            "cache": .array([
                .string("get_default_app_settings"),
                .object([
                    "client": "Primal-iOS App"
                ])
            ])
        ])
        
        Connection.instance.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .defaultSettings:
                    var primalSettings = PrimalSettings(json: response)
                    // Ensure Latest feed *always* exists
                    let latestFeedExists = primalSettings?.content.feeds?.contains(where: { $0.hex == IdentityManager.instance.userHex }) ?? false
                    if !latestFeedExists {
                        primalSettings?.content.feeds?.insert(PrimalSettingsFeed(name: "Latest", hex: IdentityManager.instance.userHex), at: 0)
                    }
                    if let settings = primalSettings {
                        callback(settings)
                    }
                default:
                    assertionFailure("IdentityManager: requestUserSettings: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    func requestUserSettings() {
        guard let ev = NostrObject.getSettings() else { return }
        
        let request: JSON = .object([
            "cache": .array([
                .string("get_app_settings"),
                .object([
                    "event_from_user": .object([
                        "content": .string(ev.content),
                        "created_at": .number(Double(ev.created_at)),
                        "id": .string(ev.id),
                        "kind": .number(30078),
                        "pubkey": .string(ev.pubkey),
                        "sig": .string(ev.sig),
                        "tags": .array(ev.tags.map { .array($0.map { s in .string(s) }) })
                    ])
                ])
            ])
        ])
        
        Connection.instance.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .settings:
                    fallthrough
                case .defaultSettings:
                    var primalSettings = PrimalSettings(json: response)
                    // Ensure Latest feed *always* exists
                    let latestFeedExists = primalSettings?.content.feeds?.contains(where: { $0.hex == IdentityManager.instance.userHex }) ?? false
                    if !latestFeedExists {
                        primalSettings?.content.feeds?.insert(PrimalSettingsFeed(name: "Latest", hex: IdentityManager.instance.userHex), at: 0)
                    }
                    guard var settings = primalSettings else { return }
                    
                    // There were breaking changes to how settings work over the time
                    // So if someone somehow has broken settings request, merge and replace what's broken with default values seamlessly
                    if settings.content.isBorked() {
                        self.requestDefaultSettings { defaultSettings in
                            settings.content.merge(with: defaultSettings.content)
                            self.userSettings = settings
                            self.updateSettings(settings)
                        }
                    } else {
                        self.userSettings = settings
                    }
                    
                    // Cache server starts tracking notifications for users *only* when they update their settings
                    // If we're a new user start tracking as soon as possible by updating their settings with default one
                    if self.isNewUser {
                        self.updateSettings(settings)
                        self.isNewUser = false
                    }
                default:
                    assertionFailure("IdentityManager: requestUserSettings: Got unexpected event kind in response: \(response)")
                }
            }
            self.didFinishInit = true
        }
    }
    func requestUserContacts(callback: (() -> Void)? = nil) {
        let request: JSON = .object([
            "cache": .array([
                "contact_list",
                .object([
                    "pubkey": .string(userHex)
                ])
            ])
        ])
        
        Connection.instance.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .contacts:
                    guard let relays: [String: RelayInfo] = try? JSONDecoder().decode([String: RelayInfo].self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding contacts to json")
                        return
                    }
                    
                    self.userRelays = relays
                    
                    let relayKeys = Array(relays.keys)
                    
                    if
                        let nwcUrl = UserDefaults.standard.string(forKey: .nwcDefaultsKey),
                        let nwc = WalletConnectURL(str: nwcUrl) {
                        ZapManager.instance.connect(nwc.relay.url.absoluteString)
                    }
                    
                    RelaysPostbox.instance.connect(relayKeys)
                    
                    var tags: [String]?
                    if let isEmpty = response.arrayValue?[2].objectValue?["tags"]?.arrayValue?.isEmpty {
                        if isEmpty {
                            tags = []
                        } else {
                            if let isInnerEmpty = response.arrayValue?[2].objectValue?["tags"]?.arrayValue?[0].arrayValue?.isEmpty {
                                if isInnerEmpty {
                                    tags = []
                                } else {
                                    tags = response.arrayValue?[2].objectValue?["tags"]?.arrayValue?.map {
                                        return $0.arrayValue?[1].stringValue ?? ""
                                    }
                                }
                            }
                        }
                    }
                    if let contacts = tags {
                        let c = Contacts(created_at: Int(response.arrayValue?[2].objectValue?["created_at"]?.doubleValue ?? -1), contacts: contacts)
                        if self.userContacts.created_at <= c.created_at {
                            self.userContacts = c
                            if let c = callback {
                                c()
                            }
                        }
                    }
                default:
                    assertionFailure("IdentityManager: requestUserContacts: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    
    func updateSettings(_ settings: PrimalSettings) {
        userSettings = settings
        
        guard let ev = NostrObject.updateSettings(settings.content) else { return }
        
        Connection.instance.requestCache(name: "set_app_settings", request: .object([
            "settings_event":  .object([
                "content": .string(ev.content),
                "created_at": .number(Double(ev.created_at)),
                "id": .string(ev.id),
                "kind": .number(30078),
                "pubkey": .string(ev.pubkey),
                "sig": .string(ev.sig),
                "tags": .array(ev.tags.map { .array($0.map { s in .string(s) }) })
            ])
        ])) { result in
            print(result)
        }
    }
    
    func updateLastSeen() {
        guard let ev = NostrObject.create(content: "{\"description\": \"update notifications last seen timestamp\"}", kind: NostrKind.settings.rawValue, tags: []) else { return }
        
        Connection.instance.requestCache(name: "set_notifications_seen", request: .object([
            "event_from_user":  .object([
                "content": .string(ev.content),
                "created_at": .number(Double(ev.created_at)),
                "id": .string(ev.id),
                "kind": .number(Double(ev.kind)),
                "pubkey": .string(ev.pubkey),
                "sig": .string(ev.sig),
                "tags": .array([])
            ])
        ])) { _ in }
    }
    
    func updateNotifications(_ notifications: PrimalSettingsNotifications) {
        guard var settings = userSettings else { return }
        settings.content.notifications = notifications
        updateSettings(settings)
    }
    
    func updateFeeds(_ feeds: [PrimalSettingsFeed]) {
        guard var settings = userSettings else { return }
        settings.content.feeds = feeds
        updateSettings(settings)
    }
    
    func addFeedToList(feed: PrimalSettingsFeed) {
        guard
            var settings = userSettings,
            let feeds = settings.content.feeds,
            !feeds.isEmpty
        else { return }
        
        settings.content.feeds?.append(feed)
        
        updateSettings(settings)
    }
    
    func removeFeedFromList(hex: String) {
        guard
            var settings = userSettings,
            let feeds = settings.content.feeds,
            !feeds.isEmpty
        else { return }
        
        settings.content.feeds?.removeAll(where: { $0.hex == hex })
        
        updateSettings(settings)
    }
}
