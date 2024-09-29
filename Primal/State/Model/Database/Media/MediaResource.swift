//
//  MediaMetadata.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.9.24..
//

import Foundation
import GRDB

struct MediaResource: Identifiable, Equatable {
    var id: String { url }
    
    static func == (lhs: MediaResource, rhs: MediaResource) -> Bool {
        lhs.url == rhs.url &&
        lhs.variants.encodeToString() == rhs.variants.encodeToString()
    }
    
    var url: String
    var variants: [MediaMetadata.Resource.Variant]
}

extension MediaResource: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let url = Column(CodingKeys.url)
        static let variants = Column(CodingKeys.variants)
    }
}
