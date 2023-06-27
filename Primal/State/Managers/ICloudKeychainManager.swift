//
//  ICloudKeychainManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 27.6.23..
//

import KeychainAccess
import Foundation

final class ICloudKeychain {
    private let keychain: Keychain = Keychain(service: "net.primal.iosapp.Primal")
        .accessibility(.whenUnlocked)
        .synchronizable(true)

    private init() {}
    
    private static let savedNpubsKey = "primal-saved-npubs"
    static let instance: ICloudKeychain = ICloudKeychain()
    
    func hasSavedNpubs() -> Bool {
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
        npubs.append(npub)
        
        do {
            let npubsJSONData = try JSONEncoder().encode(npubs)
            
            guard let npubsJSONString = String(data: npubsJSONData, encoding: .utf8) else {
                print("ICloudKeychain: Error converting npubs JSON Data to String")
                return false
            }
            
            try keychain.set(Self.savedNpubsKey, key: npubsJSONString)
            try keychain.set(nsec, key: npub)
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
}
