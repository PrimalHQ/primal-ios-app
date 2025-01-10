//
//  LinkPreviewManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.1.25..
//

import Foundation
import LinkPresentation

class LinkPreviewManager {
    static let instance = LinkPreviewManager()
    
    var cache: [String: LPLinkMetadata] = [:]
    
    func getMetadata(url: String) -> LPLinkMetadata? {
        return cache[url]
    }
    
    func cacheMetadata(url: String, metadata: LPLinkMetadata) {
        cache[url] = metadata
    }
}
