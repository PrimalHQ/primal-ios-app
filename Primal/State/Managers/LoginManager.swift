//
//  LoginManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 18.7.23..
//

import Foundation
import Kingfisher

enum LoginMethod {
    case nsec
    case npub
}

final class LoginManager {
    static let instance: LoginManager = LoginManager()
    
    func login(_ key: String) -> Bool {
        guard let type = NKeypair.type(key) else { return false }
        
        switch type {
        case .npub:
            return login(npub: key)
        case .nsec:
            return login(nsec: key)
        }
    }
    
    func logout() {
        KingfisherManager.shared.cache.clearMemoryCache()
        UserDefaults.standard.nwc = nil
        ICloudKeychainManager.instance.clearSavedKeys()
        UserDefaults.standard.homeFeedResultString = nil
        UserDefaults.standard.homeFeedSaveDate = nil
        UserDefaults.standard.synchronize()
        RelaysPostbox.instance.disconnect()
        Connection.disconnect()
        
        RootViewController.instance.reset()
    }
    
    func method() -> LoginMethod? { loginMethod() }
    
    private func login(npub: String) -> Bool {
        return ICloudKeychainManager.instance.upsertLoginInfo(npub: npub)
    }
    
    private func login(nsec: String) -> Bool {
        guard
            let hexPrivkey = HexKeypair.nsecToHexPrivkey(nsec),
            let hexPubkey = HexKeypair.privkeyToPubkey(hexPrivkey),
            let keypair = HexKeypair.nostrKeypair(hexPubkey: hexPubkey, hexPrivkey: hexPrivkey)
        else {
            return false
        }
        
        let npub = keypair.nVariant.npub
        let nsec = keypair.nVariant.nsec
        
        return ICloudKeychainManager.instance.upsertLoginInfo(npub: npub, nsec: nsec)
    }
    
    private func loginMethod() -> LoginMethod? {
        if !ICloudKeychainManager.instance.hasSavedNpubs() {
            return nil
        }
        
        let npubs = ICloudKeychainManager.instance.getSavedNpubs()
        
        if npubs.count <= 0 {
            return nil
        }
        
        // assume only one saved npub until multiple accounts feature is implemented
        if let _ = ICloudKeychainManager.instance.getSavedNsec(npubs[0]) {
            return .nsec
        } else {
            return .npub
        }
    }
}
