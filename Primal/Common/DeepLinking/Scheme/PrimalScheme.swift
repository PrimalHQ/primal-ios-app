//
// Created by Nikola Lukovic on 23.8.23..
//

import Foundation

fileprivate let profileDeeplinkPrefix = "primal://p/"
fileprivate let noteDeeplinkPrefix = "primal://e/"

final class PrimalSchemeDeeplinkHandler: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: profileDeeplinkPrefix) ||
                url.absoluteString.starts(with: noteDeeplinkPrefix)
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }

        if url.absoluteString.starts(with: profileDeeplinkPrefix) {
            let npub: String = url.absoluteString.replacingOccurrences(of: profileDeeplinkPrefix, with: "")

            if NKeypair.isValidNpub(npub) {
                notify(.primalProfileLink, npub)
            }
        } else if url.absoluteString.starts(with: noteDeeplinkPrefix) {
            let note: String = url.absoluteString.replacingOccurrences(of: noteDeeplinkPrefix, with: "")
            guard let decoded = try? bech32_decode(note) else { return }
            let eventId = hex_encode(decoded.data)

            notify(.primalNoteLink, eventId)
        }
    }
}
