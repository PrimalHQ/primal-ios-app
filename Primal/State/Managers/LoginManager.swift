//
//  LoginManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 18.7.23..
//

import Combine
import Foundation
import Kingfisher
import GenericJSON

enum LoginMethod {
    case nsec
    case npub
}

final class LoginManager {
    static let instance: LoginManager = LoginManager()
    
    @Published var cachedMethod: LoginMethod?
    @Published var loadedProfiles: [ParsedUser] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        loadProfiles()
        
        $loadedProfiles.debounce(for: 2, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadProfiles()
            }
            .store(in: &cancellables)
    }
    
    func loggedInNpubs() -> [String] { ICloudKeychainManager.instance.npubs }
    
    func login(_ key: String) -> Bool {
        guard let type = NKeypair.type(key) else { return false }
        
        defer {
            resetState()
        }
        
        switch type {
        case .npub:
            return login(npub: key)
        case .nsec:
            return login(nsec: key)
        }
    }
    
    func loginReset(_ key: String) -> Bool {
        defer {
            RootViewController.instance.reset()
        }
        return login(key)
    }
    
    func logout() {
        ICloudKeychainManager.instance.logoutCurrentUser()
        
        resetState()
        
        RootViewController.instance.reset()
    }
    
    func resetState() {
        loadProfiles()
        cachedMethod = nil
        IdentityManager.instance.clear()
        
        PostingManager.instance.reset()
        WalletManager.instance.reset(IdentityManager.instance.userHexPubkey)
        KingfisherManager.shared.cache.clearMemoryCache()
        RelaysPostbox.instance.disconnect()
        FollowManager.instance.pubkeysToFollow = []
        FollowManager.instance.pubkeysToUnfollow = []
    }
    
    func method() -> LoginMethod? { cachedMethod ?? loginMethod() }
    
    private func login(npub: String) -> Bool {
        defer { loadProfiles() }
        return ICloudKeychainManager.instance.saveKeypair(npub: npub)
    }
    
    private func login(nsec: String) -> Bool {
        defer { loadProfiles() }
        guard
            let hexPrivkey = HexKeypair.nsecToHexPrivkey(nsec),
            let hexPubkey = HexKeypair.privkeyToPubkey(hexPrivkey),
            let keypair = HexKeypair.nostrKeypair(hexPubkey: hexPubkey, hexPrivkey: hexPrivkey)
        else {
            return false
        }
        
        let npub = keypair.nVariant.npub
        let nsec = keypair.nVariant.nsec
        
        return ICloudKeychainManager.instance.saveKeypair(npub: npub, nsec: nsec)
    }
    
    private func loginMethod() -> LoginMethod? {
        guard let npub = ICloudKeychainManager.instance.npubs.first else { return nil }
        
        if let _ = ICloudKeychainManager.instance.getSavedNsec(npub) {
            cachedMethod = .nsec
            return .nsec
        } 
        
        cachedMethod = .npub
        return .npub
    }
}

extension LoginManager {
    func loadProfiles() {
        let allPubkeys: [String] = loggedInNpubs().compactMap {
            guard let decoded = try? bech32_decode($0) else { return nil }
            return hex_encode(decoded.data)
        }
        
        DatabaseManager.instance.getProfilesPublisher(allPubkeys)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] users in
                guard let self else { return }
                loadedProfiles = users
                
                let missing = allPubkeys.filter { pubkey in !self.loadedProfiles.contains(where: { $0.data.pubkey == pubkey })}
        
                if missing.isEmpty { return }
        
                let payload: [String: JSON] = [
                    "pubkeys": .array(allPubkeys.map { .string($0) })
                ]
        
                SocketRequest(name: "user_infos", payload: .object(payload)).publisher()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] res in
                        guard let self else { return }
                        
                        let allProfiles = res.getSortedUsers() + loadedProfiles
                        
                        loadedProfiles = allPubkeys.compactMap { pubkey in allProfiles.first(where: { $0.data.pubkey == pubkey })}
                    }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
    }
}
