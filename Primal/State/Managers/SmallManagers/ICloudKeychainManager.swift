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

extension Keychain {
    private static let savedNpubsKey = "primal-saved-npubs"
    
    fileprivate func getSavedNpubs() -> [String] {
        guard let npubsJSON = try? getString(Self.savedNpubsKey) else {
            print("ICloudKeychain: There are no saved npubs in ICloud Keychain")
            return []
        }
        
        guard let npubs: [String] = npubsJSON.decode() else {
            print("ICloudKeychain: Error converting npubs JSON string to [String] type")
            return []
        }
        
        return npubs
    }
    
    func hasSavedNpubs() -> Bool { (try? contains(Self.savedNpubsKey)) ?? false }
    
    func saveNpubs(_ npubs: [String]) throws {
        guard let npubsJSONString = npubs.encodeToString() else {
            print("ICloudKeychain: Error converting npubs JSON Data to String")
            return
        }
        
        try set(npubsJSONString, key: Self.savedNpubsKey)
    }
}

final class ICloudKeychainManager {
    private let keychain: Keychain = Keychain(service: "net.primal.iosapp.Primal")
        .synchronizable(false)
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    static let instance: ICloudKeychainManager = ICloudKeychainManager()
    
    @Published var userPubkey: String = ""
    
    lazy var npubs: [String] = keychain.getSavedNpubs()
    
    func hasSavedNpub(_ npub: String) -> Bool { npubs.contains(where: { $0 == npub }) }
    
    func getSavedNsec(_ npub: String) -> String? {
        guard let nsec = try? keychain.getString(npub) else {
            print("ICloudKeychain: There is no nsec saved to ICloud Keychain associated with npub: \(npub)")
            return nil
        }
        
        return nsec
    }
    
    func saveKeypair(npub: String, nsec: String? = nil) -> Bool {
        userPubkey = ""
        
        if let index = npubs.firstIndex(where: { $0 == npub }) {
            npubs.remove(at: index)
        }
        
        npubs.insert(npub, at: 0)
        
        do {
            try keychain.saveNpubs(npubs)
            if let nsec {
                try keychain.set(nsec, key: npub)
            }
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
    
    // Used until we get to support multiple accounts
    func getLoginInfo() -> NostrKeypair? {
        guard let npub = npubs.first else { return nil }
        
        let keypair = NKeypair.nostrKeypair(npub: npub, nsec: getSavedNsec(npub))
        userPubkey = keypair?.hexVariant.pubkey ?? ""
        return keypair
    }
    
    @discardableResult
    func logoutCurrentUser() -> Bool {
        guard let npub = npubs.first else { return false }
        userPubkey = ""
        return removeKeypair(npub)
    }
    
    @discardableResult
    func clearSavedKeys() -> Bool {
        do {
            try keychain.removeAll()
            userPubkey = ""
            return true
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
    }
    
    func removeKeypair(_ npub: String) -> Bool {
        userPubkey = ""
        npubs.remove(object: npub)
    
        do {
            try keychain.saveNpubs(npubs)
            try keychain.remove(npub)
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
}
