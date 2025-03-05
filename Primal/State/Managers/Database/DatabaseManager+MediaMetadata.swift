//
//  DatabaseManager+MediaMetadata.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.3.25..
//

import Foundation
import Combine

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
    
    func getMediaPublisher(_ url: String) -> AnyPublisher<MediaMetadata.Resource?, any Error> {
        dbWriter.readPublisher { db in
            try MediaResource.all()
                .filterURLS([url])
                .fetchOne(db)
        }
        .map { $0?.toNativeForm() }
        .eraseToAnyPublisher()
    }
    
    func getMediasPublisher(_ urls: [String]) -> AnyPublisher<[MediaMetadata.Resource], any Error> {
        dbWriter.readPublisher { db in
            try MediaResource.all()
                .filterURLS(urls)
                .fetchAll(db)
        }
        .map { $0.map({ $0.toNativeForm() }) }
        .eraseToAnyPublisher()
    }
}

extension MediaMetadata.Resource {
    func toData() -> MediaResource {
        .init(url: url, variants: variants)
    }
}
