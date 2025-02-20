//
//  PrimalWebsiteScheme.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.2.25..
//

import Foundation

final class PrimalWebsiteScheme: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return (url.scheme == "https" || url.scheme == "http") && url.host() == "primal.net"
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }

        let path = url.path()
        let id = url.lastPathComponent
        
        if path.hasPrefix("/e/") {
            guard let decoded = try? bech32_decode(id) else {
                notify(.primalNoteLink, id)
                return
            }
            let eventId = hex_encode(decoded.data)

            notify(.primalNoteLink, eventId)
            return
        }
        
        if path.hasPrefix("/p/") {
            notify(.primalProfileLink, id)
            return
        }
        
        
        
//        if url.absoluteString.starts(with: profileDeeplinkPrefix) {
//            let npub: String = url.absoluteString.replacingOccurrences(of: profileDeeplinkPrefix, with: "")
//
//            notify(.primalProfileLink, npub)
//        } else if url.absoluteString.starts(with: noteDeeplinkPrefix) {
//            let note: String = url.absoluteString.replacingOccurrences(of: noteDeeplinkPrefix, with: "")
//            
//            guard let decoded = try? bech32_decode(note) else {
//                notify(.primalNoteLink, note)
//                return
//            }
//            let eventId = hex_encode(decoded.data)
//                
//            notify(.primalNoteLink, eventId)
//        }
    }
}
