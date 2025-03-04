//
//  DatabaseManager+MediaMetadata.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.3.25..
//

import Foundation

extension DatabaseManager {
    func saveMediaResources(_ resources: [MediaMetadata.Resource]) {
        if resources.isEmpty { return }
        
        let resources = resources.map { $0.toData() }
        
        performUpdates { db in
            for var resource in resources {
                try resource.save(db)
            }
        }
    }
}

extension MediaMetadata.Resource {
    func toData() -> MediaResource {
        .init(url: url, variants: variants)
    }
}
