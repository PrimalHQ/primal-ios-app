//
//  IdentityManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Combine
import Foundation
import GenericJSON
import UIKit
import Kingfisher

let APP_NAME = "Primal-iOS App"

final class IdentityManager {
    private init() {
        $userRelays.sink { info in
            RelaysPostbox.instance.disconnect()
            
            guard let info else {
                RelaysPostbox.instance.connect(bootstrap_relays)
                return
            }
            
            let writeRelays = info.filter {
                guard $0.value.write else { return false }
                guard let url = URL(string: $0.key) else { return false }
                if url.scheme != "wss" { return false }
                if url.absoluteString.containsEmoji { return false }
                return true
            }
            
            var relayKeys = Array(writeRelays.keys)
            if relayKeys.isEmpty {
                relayKeys = bootstrap_relays // Default relay list
            }
            RelaysPostbox.instance.connect(relayKeys)
        }
        .store(in: &cancellables)
    }
    
    static let instance = IdentityManager()

    var userHexPubkey: String {
        get {
            guard
                ICloudKeychainManager.instance.userPubkey.isEmpty,
                let result = ICloudKeychainManager.instance.getLoginInfo()
            else {
                return ICloudKeychainManager.instance.userPubkey
            }
            
            return result.hexVariant.pubkey
        }
    }
    
    var parsedUserSafe: ParsedUser { parsedUser ?? .init(data: user ?? .init(pubkey: userHexPubkey)) }
    
    @Published var user: PrimalUser?
    @Published var parsedUser: ParsedUser?
    @Published var userStats: NostrUserProfileInfo?
    @Published var userSettings: PrimalSettingsContent?
    @Published var userRelays: [String: RelayInfo]?
    @Published var userContacts = DatedSet(created_at: -10, set: [])
    
    var followListContentString = ""
    
    @Published var didFinishInit: Bool = false
    
    var cancellables: Set<AnyCancellable> = []

    func requestUserProfile() {
        DatabaseManager.instance.getProfilePublisher(userHexPubkey).first()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] user in
                self?.parsedUser = user
            }
            .store(in: &cancellables)
        
        DatabaseManager.instance.getProfileStatsPublisher(userHexPubkey).first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                guard let self, let stats else { return }
                userStats = stats.info
            }
            .store(in: &cancellables)
        
        SocketRequest(name: "user_profile", payload: ["pubkey": .string(userHexPubkey)]).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let user = result.users.first?.value else { return }
                self?.user = user
                if user.deleted ?? false {
                    self?.handleDeletedAccount()
                }
                self?.userStats = result.userStats ?? self?.userStats
                self?.parsedUser = result.createParsedUser(user)
            }
            .store(in: &cancellables)
    }
    
    func requestDefaultSettings(_ callback: @escaping (_: PrimalSettingsContent) -> Void) {
        let request: JSON = .object([
            "cache": .array([
                .string("get_default_app_settings"),
                .object([
                    "client": .string(APP_NAME)
                ])
            ])
        ])
        
        Connection.regular.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .defaultSettings:
                    if let settings = PrimalSettings(json: response) {
                        callback(settings.content)
                    }
                default:
                        print("IdentityManager: requestUserSettings: Got unexpected event kind in response: \(String(describing: kind)) \(response)")
                }
            }
        }
    }
    
    func requestUserSettings() {
        var request: JSON = .object([
            "cache": .array([
                .string("get_default_app_settings"),
                .object([
                    "client": .string(APP_NAME)
                ])
            ])
        ])
        
        if LoginManager.instance.method() == .nsec {
            guard let ev = NostrObject.getSettings() else { return }
            
            request = .object([
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
        }
        
        Connection.regular.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .settings:
                    fallthrough
                case .defaultSettings:
                    guard var settings = PrimalSettings(json: response) else { return }
                    
                    // Ensure Latest feed *always* exists
                    let latestFeedExists = settings.content.feeds?.contains(where: { $0.hex == IdentityManager.instance.userHexPubkey && $0.includeReplies != true }) ?? false
                    if !latestFeedExists {
                        settings.content.feeds?.insert(.latest, at: 0)
                    }
                    
                    let latestWithRepliesFeedExists = settings.content.feeds?.contains(where: { $0.hex == IdentityManager.instance.userHexPubkey && $0.includeReplies == true }) ?? false
                    if !latestWithRepliesFeedExists {
                        settings.content.feeds?.insert(.latestWithReplies, at: 1)
                    }
                    
                    // There were breaking changes to how settings work over the time
                    // So if someone somehow has broken settings request, merge and replace what's broken with default values seamlessly
                    if settings.content.isBorked() {
                        self.requestDefaultSettings { defaultSettings in
                            settings.content.merge(with: defaultSettings)
                            self.userSettings = settings.content
                            self.updateSettings(settings.content)
                        }
                    } else {
                        self.userSettings = settings.content
                    }
                default:
                        print("IdentityManager: requestUserSettings: Got unexpected event kind in response: \(String(describing: kind))")
                }
            }
            self.didFinishInit = true
        }
    }
    
    func requestUserContactsAndRelays(callback: (() -> Void)? = nil) {
        requestRelays { [weak self] in
            self?.requestUserContacts {
                callback?()
            }
        }
    }
    
    func clear() {
        user = nil
        parsedUser = nil
        userStats = nil
        userSettings = nil
        userRelays = nil
        userContacts = .init(created_at: -1, set: [])
    }
    
    // Never just requestRelays as some clients might not support NIP-65
    private func requestRelays(callback: (() -> Void)? = nil) {
        SocketRequest(name: "get_user_relays", payload: .object(["pubkey": .string(userHexPubkey)])).publisher()
            .sink { result in
                if !result.relayData.isEmpty {
                    self.userRelays = result.relayData
                }
                
                callback?()
            }
            .store(in: &cancellables)
    }
    
    func requestUserContacts(callback: (() -> Void)? = nil) {
        let request: JSON = .object([
            "cache": .array([
                "contact_list",
                .object([
                    "pubkey": .string(userHexPubkey)
                ])
            ])
        ])
        
        // WE NEED TO USE OLD METHOD OF REQUEST TO GET followListContentString as String
        Connection.regular.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)
                
                switch kind {
                case .contacts:
                    self.followListContentString = response.arrayValue?[2].objectValue?["content"]?.stringValue ?? self.followListContentString
                    
                    var tags: Set<String>?
                    if let isEmpty = response.arrayValue?[2].objectValue?["tags"]?.arrayValue?.isEmpty {
                        if isEmpty {
                            tags = []
                        } else {
                            if let isInnerEmpty = response.arrayValue?[2].objectValue?["tags"]?.arrayValue?[0].arrayValue?.isEmpty {
                                if isInnerEmpty {
                                    tags = []
                                } else {
                                    let res = response.arrayValue?[2].objectValue?["tags"]?.arrayValue?.map {
                                        $0.arrayValue?[safe: 1]?.stringValue ?? ""
                                    }
                                    
                                    if let res {
                                        tags = Set<String>(res)
                                    }
                                }
                            }
                        }
                    }
                    if let contacts = tags {
                        let c = DatedSet(created_at: Int(response.arrayValue?[2].objectValue?["created_at"]?.doubleValue ?? -1), set: contacts)
                        if self.userContacts.created_at <= c.created_at {
                            self.userContacts = c
                            callback?()
                        }
                    }
                case .metadata, .userScore, .mediaMetadata, .userFollowers:
                    break // NO ACTION
                default:
                    print("IdentityManager: requestUserContacts: Got unexpected event kind in response: \(String(describing: kind))")
                }
            }
        }
    }

    func updateSettings(_ settings: PrimalSettingsContent) {
        if LoginManager.instance.method() != .nsec { return }

        userSettings = settings
        
        guard let ev = NostrObject.updateSettings(settings) else { return }
        
        Connection.regular.requestCache(name: "set_app_settings", payload: .object([
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
        if LoginManager.instance.method() != .nsec { return }

        guard let ev = NostrObject.create(content: "{\"description\": \"update notifications last seen timestamp\"}", kind: NostrKind.settings.rawValue, tags: []) else { return }
        
        Connection.regular.requestCache(name: "set_notifications_seen", payload: .object([
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
        if LoginManager.instance.method() != .nsec { return }

        guard var settings = userSettings else { return }
        settings.notifications = notifications
        updateSettings(settings)
    }
    
    func updateFeeds(_ feeds: [PrimalSettingsFeed]) {
        if LoginManager.instance.method() != .nsec { return }

        let count = feeds.filter({ $0.name.hasPrefix("Latest") }).count
        if count > 2 {
            print(count)
        }
        
        guard var settings = userSettings else { return }
        settings.feeds = feeds
        updateSettings(settings)
    }
    
    func addFeedToList(feed: PrimalSettingsFeed) {
        if LoginManager.instance.method() != .nsec { return }

        guard
            var settings = userSettings,
            let feeds = settings.feeds,
            !feeds.isEmpty
        else { return }
        
        settings.feeds?.append(feed)
        
        updateSettings(settings)
    }
    
    func removeFeedFromList(hex: String) {
        if LoginManager.instance.method() != .nsec { return }

        guard
            var settings = userSettings,
            let feeds = settings.feeds,
            !feeds.isEmpty
        else { return }
        
        settings.feeds?.removeAll(where: { $0.hex == hex })
        
        updateSettings(settings)
    }
    
    func deleteAccount() async -> [JSON] {
        return await withCheckedContinuation { continuation in
            let profile = NostrProfile(
                name: "Deleted Account",
                display_name: "Deleted Account",
                about: "Deleted Account",
                picture: nil,
                banner: nil,
                website: nil,
                lud06: nil,
                lud16: nil,
                nip05: nil,
                deleted: true
            )
            
            guard let event = NostrObject.metadata(profile) else { return }
            RelaysPostbox.instance.request(event, successHandler: { res in
                continuation.resume(returning: res)
            }, errorHandler: {
                print("IdentityManager: DeleteAccount failed to send event to Relays")
                continuation.resume(returning: [])
            })
        }
    }
    
    func updateProfile(_ data: NostrProfile, callback: @escaping (Bool) -> Void) {
        guard let metadata_ev = NostrObject.metadata(data) else {
            callback(false)
            return
        }
        
        RelaysPostbox.instance.connect(bootstrap_relays)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            RelaysPostbox.instance.request(metadata_ev, successHandler: { _ in
                callback(true)
            }, errorHandler: {
                callback(false)
            })
        }
    }
    
    private func handleDeletedAccount() {
        let alert = UIAlertController(title: "This account has been deleted", message: "You cannot sign into this account because it has been deleted", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .destructive) { _ in
            LoginManager.instance.logout()
        })
        DispatchQueue.main.async {
            RootViewController.instance.present(alert, animated: true)
        }
    }
}

private extension IdentityManager {
    
}
