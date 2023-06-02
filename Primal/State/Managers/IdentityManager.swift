//
//  IdentityManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 31.5.23..
//

import Foundation
import GenericJSON

final class IdentityManager {
    private init() {}
    
    static let the = IdentityManager()
    
    var userHexExists: Bool {
        get {
            let result = get_saved_keypair()
            
            guard
                let keypair = result,
                let _ = try? bech32_decode(keypair.pubkey_bech32)
            else {
                return false
            }
            
            return true
        }
    }
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
    
    @Published var userScore: UInt32 = 0
    @Published var user: PrimalUser?
    @Published var userStats: NostrUserProfileInfo?
    @Published var userSettings: PrimalSettings?
    @Published var userRelays: [String: RelayInfo]?
    @Published var userContacts: Contacts = Contacts(created_at: -1, contacts: [])

    @Published var didFinishInit: Bool = false
    
    func requestUserInfos() {
        guard let json: JSON = try? JSON(["REQ", "user_infos_\(Connection.the.identity)", ["cache": ["user_infos", ["pubkeys": ["\(IdentityManager.the.userHex)"]]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        Connection.the.send(json: json) { res in
            for response in res {
                let kind = ResponseKind.fromGenericJSON(response)
                
                switch kind {
                case .metadata:
                    let nostrUser = NostrContent(json: .object(response.arrayValue?[2].objectValue ?? [:]))
                    self.user = PrimalUser(nostrUser: nostrUser)
                case .userScore:
                    if let contentString = response.arrayValue?[2].objectValue?["content"]?.stringValue {
                        guard let content: [String: UInt32] = try? JSONDecoder().decode([String: UInt32].self, from: contentString.data(using: .utf8)!) else {
                            print("IdentityManager: requestUserInfos: Unable to decode content json for kind: \(ResponseKind.userScore.rawValue)")
                            break
                        }
                        
                        guard let score = content.values.first else {
                            fatalError("IdentityManager: requestUserInfos: Unable to get user score")
                        }
                        
                        self.userScore = score
                    }
                default:
                    assertionFailure("IdentityManager: requestUserInfos: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    func requestUserProfile() {
        guard let json: JSON = try? JSON(["REQ", "profile_info_\(Connection.the.identity)", ["cache": ["user_profile", ["pubkey": "\(IdentityManager.the.userHex)"]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        Connection.the.send(json: json) { res in
            for response in res {
                let kind = ResponseKind.fromGenericJSON(response)
                
                switch kind {
                case .metadata:
                    let nostrUser = NostrContent(json: .object(response.arrayValue?[2].objectValue ?? [:]))
                    self.user = PrimalUser(nostrUser: nostrUser)
                case .userStats:
                    guard let nostrUserProfileInfo: NostrUserProfileInfo = try? JSONDecoder().decode(NostrUserProfileInfo.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding nostr stats string to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    
                    self.userStats = nostrUserProfileInfo
                default:
                    assertionFailure("IdentityManager: requestUserProfile: Got unexpected event kind in response: \(response)")
                }
            }
        }
    }
    func requestUserSettings() {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        guard let settingsJson: JSON = try? JSON(["description": "Sync app settings"]) else {
            print ("Error encoding settings")
            return
        }
        
        let ev = make_settings_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, settings: settingsJson)
        
        guard let json: JSON = try? JSON(
            ["REQ",
             "get_app_settings_\(Connection.the.identity)",
             ["cache":
                ["get_app_settings",
                 ["event_from_user":
                    ["content": ev.content,
                     "created_at": ev.created_at,
                     "id": ev.id,
                     "kind": 30078,
                     "pubkey": ev.pubkey,
                     "sig": ev.sig,
                     "tags": ev.tags
                    ] as [String : Any]]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }

        Connection.the.send(json: json) { res in
            for response in res {
                let kind = ResponseKind.fromGenericJSON(response)
                
                switch kind {
                case .settings:
                    fallthrough
                case .defaultSettings:
                    var primalSettings = PrimalSettings(json: response)
                    let latestFeedExists = primalSettings?.content.feeds.contains(where: { $0.hex == IdentityManager.the.userHex }) ?? false
                    if !latestFeedExists {
                        primalSettings?.content.feeds.insert(PrimalSettingsFeed(name: "Latest", hex: IdentityManager.the.userHex), at: 0)
                    }
                    self.userSettings = primalSettings
                default:
                    assertionFailure("IdentityManager: requestUserSettings: Got unexpected event kind in response: \(response)")
                }
            }
            self.didFinishInit = true
        }
    }
    func requestUserContacts(callback: (() -> Void)? = nil) {
        guard let json: JSON = try? JSON(["REQ", "user_contacts_\(Connection.the.identity)", ["cache": ["contact_list", ["pubkey": "\(IdentityManager.the.userHex)"]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        Connection.the.send(json: json) { res in
            for response in res {
                let kind = ResponseKind.fromGenericJSON(response)
                
                switch kind {
                case .contacts:
                    guard let relays: [String: RelayInfo] = try? JSONDecoder().decode([String: RelayInfo].self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                        print("Error decoding contacts to json")
                        dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                        return
                    }
                    
                    self.userRelays = relays
                    RelaysPostBox.the.connect(relays)
                    
                    var tags: [String]?
                    if let isEmpty = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?.isEmpty {
                        if isEmpty {
                            tags = []
                        } else {
                            if let isInnerEmpty = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?[0].arrayValue?.isEmpty {
                                if isInnerEmpty {
                                    tags = []
                                } else {
                                    tags = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?.map {
                                        return $0.arrayValue?[1].stringValue ?? ""
                                    }
                                }
                            }
                        }
                    }
                    if let contacts = tags {
                        let c = Contacts(created_at: Int(json.arrayValue?[2].objectValue?["created_at"]?.doubleValue ?? -1), contacts: contacts)
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
}
