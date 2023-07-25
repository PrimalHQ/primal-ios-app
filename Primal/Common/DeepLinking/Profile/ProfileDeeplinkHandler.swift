//
//  NoteDeeplinkHandler.swift
//  Primal
//
//  Created by Nikola Lukovic on 25.7.23..
//

import Foundation

fileprivate let profileDeeplinkPrefix = "primal://p/"

final class ProfileDeeplinkHandler : DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: profileDeeplinkPrefix)
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        let npub: String = url.absoluteString.replacingOccurrences(of: profileDeeplinkPrefix, with: "")
        
        if NKeypair.isValidNpub(npub) {
            notify(.primalProfileLink, npub)
        }
    }
}
