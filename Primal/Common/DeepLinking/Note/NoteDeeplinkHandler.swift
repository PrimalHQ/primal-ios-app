//
//  NoteDeeplinkHandler.swift
//  Primal
//
//  Created by Nikola Lukovic on 25.7.23..
//

import Foundation
import UIKit

func eventIdFromNote(_ note: String) -> String? {
    let res = parse_mentions(content: note, tags: [])
    
    let block = res[0]
    
    guard case .mention(let mention) = block else {
        return nil
    }
    
    return mention.ref.id
}

func parse_mentions(content: String, tags: [[String]]) -> [Block] {
    var out: [Block] = []
    
    var bs = blocks()
    bs.num_blocks = 0;
    
    blocks_init(&bs)
    
    let bytes = content.utf8CString
    let _ = bytes.withUnsafeBufferPointer { p in
        damus_parse_content(&bs, p.baseAddress)
    }
    
    var i = 0
    while (i < bs.num_blocks) {
        let block = bs.blocks[i]
        
        if let converted = convert_block(block, tags: tags) {
            out.append(converted)
        }
        
        i += 1
    }
    
    blocks_free(&bs)
    
    return out
}

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
