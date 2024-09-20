//
//  Profile.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.9.24..
//

import GRDB

struct Profile: Identifiable, Equatable {
    var id: String { pubkey }
    
    var pubkey: String
    var npub: String
    var name: String
    var about: String
    var picture: String
    var nip05: String
    var banner: String
    var displayName: String
    var location: String
    var lud06: String
    var lud16: String
    var website: String
    
    var rawData: String
}

extension Profile: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let pubkey = Column(CodingKeys.pubkey)
        static let npub = Column(CodingKeys.npub)
        static let name = Column(CodingKeys.name)
        static let about = Column(CodingKeys.about)
        static let picture = Column(CodingKeys.picture)
        static let nip05 = Column(CodingKeys.nip05)
        static let banner = Column(CodingKeys.banner)
        static let displayName = Column(CodingKeys.displayName)
        static let location = Column(CodingKeys.location)
        static let lud06 = Column(CodingKeys.lud06)
        static let lud16 = Column(CodingKeys.lud16)
        static let website = Column(CodingKeys.website)
        
        static let rawData = Column(CodingKeys.rawData)
    }
}

extension Profile {
    static let lastVisit = hasOne(ProfileLastVisit.self)
    static let counts = hasOne(ProfileCounts.self)
    
    var countsRequest: QueryInterfaceRequest<ProfileCounts> {
        request(for: Profile.counts)
    }
}

extension DerivableRequest<Profile> {
    /// A request of players ordered by name.
    ///
    /// For example:
    ///
    ///     let profiles: [Player] = try dbWriter.read { db in
    ///         try Player.all().orderedByName().fetchAll(db)
    ///     }
    func orderedByName() -> Self {
        // Sort by name in a localized case insensitive fashion
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
        order(Profile.Columns.name.collating(.localizedCaseInsensitiveCompare))
    }
}
