//
// Created by Nikola Lukovic on 23.8.23..
//

import Foundation

final class NostrSchemeDeeplinkHandler: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.scheme == "nostr"
    }

    func openURL(_ url: URL) {
        let destination = url.absoluteString.replacingOccurrences(of: "nostr:", with: "")
        
        if NKeypair.isValidNpub(destination) {
            notify(.primalProfileLink, destination)
            return
        }
    }
}
