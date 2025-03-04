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
    
    enum CodingKeys: String, CodingKey {
        case url, variants
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(variants.encodeToString(), forKey: .variants)
    }
    
    init(row: Row) {
        url = row[Columns.url]
        let json: String = row[Columns.variants]
        variants = json.decode() ?? []
    }
}

extension MediaResource {
    static let profiles = hasMany(Profile.self, using: ForeignKey(["url"], to: ["picture"]))

    func toNativeForm() -> MediaMetadata.Resource {
        .init(url: url, variants: variants)
    }
}
