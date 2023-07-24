//
//  ICloudKeychainManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 27.6.23..
//
import KeychainAccess
import Foundation
import Combine
import GenericJSON

final class ICloudKeychainManager {
    private let keychain: Keychain = Keychain(service: "net.primal.iosapp.Primal")
        .synchronizable(false)
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    private static let savedNpubsKey = "primal-saved-npubs"
    static let instance: ICloudKeychainManager = ICloudKeychainManager()
    
    func hasSavedNpubs() -> Bool {
        let items = keychain.allItems()
        print(items)
        
        guard let contains = try? keychain.contains(Self.savedNpubsKey) else {
            print("ICloudKeychain: There are no saved npubs in ICloud Keychain")
            return false
        }
        
        return contains
    }
    func hasSavedNpub(_ npub: String) -> Bool {
        if !hasSavedNpubs() {
            return false
        }
        
        let npubs = getSavedNpubs()
        
        return npubs.contains(where: { $0 == npub })
    }
    
    func getSavedNpubs() -> [String] {
        guard let npubsJSON = try? keychain.getString(Self.savedNpubsKey) else {
            print("ICloudKeychain: There are no saved npubs in ICloud Keychain")
            return []
        }
        
        guard let npubsJSONData = npubsJSON.data(using: .utf8) else {
            print("ICloudKeychain: Error converting npubs JSON string to Data type")
            return []
        }
        
        guard let npubs = try? JSONDecoder().decode([String].self, from: npubsJSONData) else {
            print("ICloudKeychain: Error converting npubs JSON string to [String] type")
            return []
        }
        
        return npubs
    }
    func getSavedNsec(_ npub: String) -> String? {
        guard let nsec = try? keychain.getString(npub) else {
            print("ICloudKeychain: There is no nsec saved to ICloud Keychain associated with npub: \(npub)")
            return nil
        }
        
        return nsec
    }
    
    func saveKeypair(npub: String, nsec: String) -> Bool {
        var npubs = getSavedNpubs()
        
        if npubs.contains(where: { $0 == npub }) {
            return true
        }
        
        npubs.append(npub)
        
        do {
            let npubsJSONData = try JSONEncoder().encode(npubs)
            
            guard let npubsJSONString = String(data: npubsJSONData, encoding: .utf8) else {
                print("ICloudKeychain: Error converting npubs JSON Data to String")
                return false
            }
            
            try keychain.set(npubsJSONString, key: Self.savedNpubsKey)
            try keychain.set(nsec, key: npub)
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
    
    // Used until we get to support multiple accounts
    func getLoginInfo() -> NostrKeypair? {
        if !hasSavedNpubs() {
            return nil
        }
        
        let npubs = getSavedNpubs()
        
        let firstNsec = getSavedNsec(npubs[0])
        
        return NKeypair.nostrKeypair(npub: npubs[0], nsec: firstNsec)
    }
    // Used until we get to support multiple accounts
    func upsertLoginInfo(npub: String, nsec: String? = nil) -> Bool {
        var npubs = getSavedNpubs()
        
        if npubs.count == 0 {
            npubs.append(npub)
        } else {
            npubs[0] = npub
        }
        
        do {
            let npubsJSONData = try JSONEncoder().encode(npubs)
            
            guard let npubsJSONString = String(data: npubsJSONData, encoding: .utf8) else {
                print("ICloudKeychain: Error converting npubs JSON Data to String")
                return false
            }
            
            try keychain.set(npubsJSONString, key: Self.savedNpubsKey)
            if let privkey = nsec {
                try keychain.set(privkey, key: npub)
            }
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
    
    func clearSavedKeys() -> Bool {
        do {
            try keychain.removeAll()
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
    
    func removeKeypair(_ npub: String) -> Bool {
        var npubs = getSavedNpubs()
        
        npubs.remove(object: npub)
        
        do {
            let npubsJSONData = try JSONEncoder().encode(npubs)
            
            guard let npubsJSONString = String(data: npubsJSONData, encoding: .utf8) else {
                print("ICloudKeychain: Error converting npubs JSON Data to String")
                return false
            }
            
            try keychain.set(Self.savedNpubsKey, key: npubsJSONString)
            try keychain.remove(npub)
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
    
    func fetchPrimalUsersForSavedNpubs(_ callback: @escaping (_ users: [PrimalUser]) -> Void) {
        let conn = TemporaryConnection()
        
        conn.$isConnected.sink { isConnected in
            if isConnected {
                let npubs = self.getSavedNpubs()
                let request: JSON = .object([
                    "pubkeys": .array(npubs.compactMap { npub in
                        guard let decoded = try? bech32_decode(npub) else {
                            return nil
                        }
                        
                        let pubkey = hex_encode(decoded.data)
                        
                        return .string(pubkey)
                    })
                ])
                var result: [PrimalUser] = []
                conn.requestCache(name: "user_infos", request: request) { res in
                    for response in res {
                        let kind = NostrKind.fromGenericJSON(response)
                        
                        switch kind {
                        case .metadata:
                            let nostrUser = NostrContent(json: .object(response.arrayValue?[2].objectValue ?? [:]))
                            if let primalUser = PrimalUser(nostrUser: nostrUser) {
                                result.append(primalUser)
                            }
                        case .userScore:
                            print("ICloudKeychainManager: nostrUserForSavedNpubs: Got userScore")
                        case .mediaMetadata:
                            print("ICloudKeychainManager: nostrUserForSavedNpubs: Got mediaMetada")
                        default:
                            print("ICloudKeychainManager: nostrUserForSavedNpubs: Got unexpected event kind in response: \(response)")
                        }
                    }
                    callback(result)
                    conn.disconnect()
                    for cancellable in self.cancellables {
                        cancellable.cancel()
                    }
                }
            }
        }.store(in: &cancellables)
        
        conn.connect()
    }
}
