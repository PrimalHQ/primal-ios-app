//
//  MediaManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.8.24..
//

import Foundation

enum MediaSize: String {
    case small = "s"
    case large = "l"
    case medium = "m"
    case original = "o"
}

class MediaManager {
    private static let instance = MediaManager()
    
    private var cached: [String: MediaMetadata.Resource] = [:]
    
    static func add(_ mediaMetadata: MediaMetadata) {
        DispatchQueue.main.async {
            for resource in mediaMetadata.resources {
                instance.cached[resource.url] = resource
            }
        }
    }
    
    static func getCachedURL(_ url: String, size: MediaSize = .medium) -> URL? {
        guard let resource = instance.cached[url] else { return URL(string: url) }
        return resource.url(for: size)
    }
}
