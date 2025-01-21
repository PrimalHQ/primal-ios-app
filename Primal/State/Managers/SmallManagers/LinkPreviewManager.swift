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
    
    var preloading: [String: LPMetadataProvider] = [:]
    
    func getMetadata(url: String) -> LPLinkMetadata? {
        return cache[url]
    }
    
    func cacheMetadata(url: String, metadata: LPLinkMetadata) {
        cache[url] = metadata
    }
    
    func preload(_ url: URL) {
        let urlStr = url.absoluteString
        guard preloading[urlStr] == nil, cache[urlStr] == nil else { return }
        
        let metadataProvider = LPMetadataProvider()
        preloading[url.absoluteString] = metadataProvider
        metadataProvider.startFetchingMetadata(for: url) { [weak self] (metadata, error) in
            guard let metadata, let self else { return }
            DispatchQueue.main.async {
                self.preloading[urlStr] = nil
                self.cacheMetadata(url: urlStr, metadata: metadata)
            }
        }
    }
}
