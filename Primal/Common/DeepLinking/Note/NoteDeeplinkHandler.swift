//
//  NoteDeeplinkHandler.swift
//  Primal
//
//  Created by Nikola Lukovic on 25.7.23..
//

import Foundation
import UIKit

fileprivate let noteDeepLinkPrefix = "primal://e/"

final class NoteDeeplinkHandler : DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: noteDeepLinkPrefix)
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }
        
        let note: String = url.absoluteString.replacingOccurrences(of: noteDeepLinkPrefix, with: "")
        guard let decoded = try? bech32_decode(note) else { return }
        let eventId = hex_encode(decoded.data)
        
        notify(.primalNoteLink, eventId)
    }
}
