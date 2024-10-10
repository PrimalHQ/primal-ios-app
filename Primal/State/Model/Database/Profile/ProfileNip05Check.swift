//
//  ProfileNip05Check.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.10.24..
//

import Foundation
import GRDB

struct ProfileNip05Check: Identifiable, Equatable {
    var id: String { nip05 }
    
    var nip05: String
    var pubkey: String
    var lastChecked: Date
}

extension ProfileNip05Check: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    enum Columns {
        static let pubkey = Column(CodingKeys.pubkey)
        static let nip05 = Column(CodingKeys.nip05)
        static let lastChecked = Column(CodingKeys.lastChecked)
    }
    
    static let profile = belongsTo(Profile.self)
    
    init(row: Row) {
        // Use default values if columns are NULL
        nip05 = row[Columns.nip05] ?? ""
        pubkey = row[Columns.pubkey] ?? ""
        lastChecked = row[Columns.lastChecked] ?? .distantPast
    }
}

extension DerivableRequest<ProfileNip05Check> {
    func filterLastChecked(since date: Date) -> Self {
        filter(date < ProfileNip05Check.Columns.lastChecked)
    }
    
    func filterNip05s(_ nip05s: [String]) -> Self {
        filter(nip05s.contains(ProfileNip05Check.Columns.nip05))
    }
}
