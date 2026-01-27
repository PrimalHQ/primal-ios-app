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

extension String {
    static let icloudRemindUsersKey = "icloudRemindUsersKey"
}

extension Keychain {
    private static let savedNpubsKey = "primal-saved-npubs"
    
    fileprivate func getSavedNpubs() -> [String] {
        let all = allKeys().filter { $0.hasPrefix("npub") }
        
        guard let npubsJSON = try? getString(Self.savedNpubsKey) else {
            print("ICloudKeychain: There are no saved npubs in ICloud Keychain")
            return all
        }
        
        guard let npubs: [String] = npubsJSON.decode() else {
            print("ICloudKeychain: Error converting npubs JSON string to [String] type")
            return all
        }
        
        return npubs + all.filter { !npubs.contains($0) }
    }
    
    func hasSavedNpubs() -> Bool { (try? contains(Self.savedNpubsKey)) ?? false }
    
    func saveNpubs(_ npubs: [String]) throws {
        guard let npubsJSONString = npubs.encodeToString() else {
            print("ICloudKeychain: Error converting npubs JSON Data to String")
            return
        }
        
        try set(npubsJSONString, key: Self.savedNpubsKey)
    }
    
    func getSavedNsec(_ npub: String) -> String? {
        guard let nsec = try? getString(npub) else {
            print("ICloudKeychain: There is no nsec saved to ICloud Keychain associated with npub: \(npub)")
            return nil
        }
        return nsec
    }
}

final class ICloudKeychainManager {
    private let keychain: Keychain = Keychain(service: "net.primal.iosapp.Primal").synchronizable(false)
    private let onlineKeychain: Keychain = Keychain(service: "net.primal.iosappOnline.Primal").synchronizable(true)
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        _ = getLoginInfo()
    }
    
    static let instance: ICloudKeychainManager = ICloudKeychainManager()
    
    @Published var userPubkey: String = ""
    
    lazy var localNpubs: [String] = keychain.getSavedNpubs()
    var onlineNpubs: [String] { onlineKeychain.getSavedNpubs() }
    
    func hasSavedNpub(_ npub: String) -> Bool { localNpubs.contains(where: { $0 == npub }) }
    
    func hasSavedNpubOnline(_ npub: String) -> Bool {
        onlineKeychain.getSavedNpubs().contains(npub)
    }
    
    func hasSavedNsecOline(_ npub: String) -> Bool {
        onlineKeychain.getSavedNsec(npub) != nil
    }
    
    func getOnlineKey(_ npub: String) -> String {
        onlineKeychain.getSavedNsec(npub) ?? npub
    }
    
    func toggleOnlineSyncForNpub(_ npub: String, on: Bool) {
        var npubs = onlineNpubs
        npubs.remove(object: npub)
        
        if on {
            npubs.insert(npub, at: 0)
            if let nsec = keychain.getSavedNsec(npub) {
                try? onlineKeychain.set(nsec, key: npub)
            }
        } else {
            try? onlineKeychain.remove(npub)
        }
        
        try? onlineKeychain.saveNpubs(npubs)
    }
    
    var onlineNpubsThatAreNotInUse: [String] {
        onlineNpubs.filter { !localNpubs.contains($0) }
    }
    
    func saveKeypair(npub: String, nsec: String? = nil, online: Bool = false) -> Bool {
        userPubkey = ""
        
        if let index = localNpubs.firstIndex(where: { $0 == npub }) {
            localNpubs.remove(at: index)
        }
        
        localNpubs.insert(npub, at: 0)
        
        do {
            try keychain.saveNpubs(localNpubs)
            
            if let nsec {
                try keychain.set(nsec, key: npub)
            }
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        
        if online {
            return onlineSaveNpub(npub, nsec: nsec)
        }
        
        return true
    }
    
    func onlineSaveNpub(_ npub: String, nsec: String? = nil) -> Bool {
        var onlineNpubs = onlineKeychain.getSavedNpubs()
        if let index = onlineNpubs.firstIndex(where: { $0 == npub }) {
            onlineNpubs.remove(at: index)
        }
        onlineNpubs.insert(npub, at: 0)
        
        do {
            try onlineKeychain.saveNpubs(onlineNpubs)
            if let nsec = nsec ?? keychain.getSavedNsec(npub) {
                try onlineKeychain.set(nsec, key: npub)
            }
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        return true
    }
    
    // Used until we get to support multiple accounts
    func getLoginInfo() -> NostrKeypair? {
        guard let npub = localNpubs.first else { return nil }
        
        let keypair = NKeypair.nostrKeypair(npub: npub, nsec: keychain.getSavedNsec(npub))
        userPubkey = keypair?.hexVariant.pubkey ?? ""
        return keypair
    }
    
    func nsec(_ npub: String) -> String? { keychain.getSavedNsec(npub) }
    
    func hasNsec(_ npub: String) -> Bool { keychain.getSavedNsec(npub) != nil }
    
    @discardableResult
    func logoutCurrentUser() -> Bool {
        guard let npub = localNpubs.first else { return false }
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
        localNpubs.remove(object: npub)
    
        do {
            try keychain.saveNpubs(localNpubs)
            try keychain.remove(npub)
        } catch let error {
            print("ICloudKeychain: \(error)")
            return false
        }
        
        return true
    }
    
    func setupForIcloudNewUsers() {
        let ud = UserDefaults.standard
        
        guard !ud.bool(forKey: "icloud_setup_done1") else {
            return
        }
        
        let npubsToRemind = localNpubs.filter { hasNsec($0) }
        
        if !npubsToRemind.isEmpty {
            ud.set(npubsToRemind, forKey: .icloudRemindUsersKey)
        }
        ud.set(true, forKey: "icloud_setup_done1")
    }
}
