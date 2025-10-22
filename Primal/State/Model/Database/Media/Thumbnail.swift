//
//  Thumbnail.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.9.24..
//

import Foundation
import GRDB

struct Thumbnail: Identifiable, Equatable {
    var id: String { url }
    
    var url: String
    var image: String
}

extension Thumbnail: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    internal enum Columns {
        static let url = Column(CodingKeys.url)
        static let image = Column(CodingKeys.image)
    }
}
