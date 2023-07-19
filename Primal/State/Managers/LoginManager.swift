//
//  LoginManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 18.7.23..
//

import Foundation

enum LoginState {
    case notLoggedIn
    case nsecLoggedIn
    case npubLoggedIn
}

final class LoginManager {
    static let instance: LoginManager = LoginManager()
    
    var state: LoginState {
        get {
            return loginState()
        }
    }
    
    func login(_ key: String) -> Bool {
        guard let type = NKeypair.type(key) else { return false }
        
        switch type {
        case .npub:
            return login(npub: key)
        case .nsec:
            return login(nsec: key)
        }
    }
    
    private func login(npub: String) -> Bool {
        return ICloudKeychainManager.instance.upsertLogin(npub: npub)
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
        
        return ICloudKeychainManager.instance.upsertLogin(npub: npub, nsec: nsec)
    }
    
    private var _loginState: LoginState? = nil
    private func loginState() -> LoginState {
        if let loginState = _loginState {
            return loginState
        }
        
        if !ICloudKeychainManager.instance.hasSavedNpubs() {
            _loginState = .notLoggedIn
            return .notLoggedIn
        }
        
        let npubs = ICloudKeychainManager.instance.getSavedNpubs()
        
        if npubs.count <= 0 {
            _loginState = .notLoggedIn
            return .notLoggedIn
        }
        
        // assume only one saved npub until multiple accounts feature is implemented
        if let nsec = ICloudKeychainManager.instance.getSavedNsec(npubs[0]) {
            _loginState = .nsecLoggedIn
            return .nsecLoggedIn
        } else {
            _loginState = .npubLoggedIn
            return .npubLoggedIn
        }
    }
}
