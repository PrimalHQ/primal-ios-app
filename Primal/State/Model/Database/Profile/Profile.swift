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
    
    var profileCount: ProfileCount? // Not column but association
    var pictureMedia: MediaResource? // Not column but association
}

extension Profile: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    internal enum Columns {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pubkey, forKey: .pubkey)
        try container.encode(npub, forKey: .npub)
        try container.encode(name, forKey: .name)
        try container.encode(about, forKey: .about)
        try container.encode(picture, forKey: .picture)
        try container.encode(nip05, forKey: .nip05)
        try container.encode(banner, forKey: .banner)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(location, forKey: .location)
        try container.encode(lud06, forKey: .lud06)
        try container.encode(lud16, forKey: .lud16)
        try container.encode(website, forKey: .website)
        try container.encode(rawData, forKey: .rawData)
        // Do not encode 'profileCount' to exclude it from database writes
        // Do not encode 'pictureMedia' to exclude it from database writes
    }
}

extension Profile {
    static let profileLastVisit = hasOne(ProfileLastVisit.self)
    static let profileCount = hasOne(ProfileCount.self)
    static let pictureMedia = belongsTo(MediaResource.self, using: ForeignKey(["picture"], to: ["url"]))
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
    
    func filterPubkeys(_ pubkeys: [String]) -> Self {
        filter(pubkeys.contains(Profile.Columns.pubkey))
    }
    
    func searchUsers(_ search: String) -> Self {
        let escapedSearchText = search.replacingOccurrences(of: "%", with: "\\%")
                                           .replacingOccurrences(of: "_", with: "\\_")
        let pattern = "%\(escapedSearchText)%"

        return filter(
            Profile.Columns.displayName.collating(.nocase).like(pattern, escape: "\\") ||
            Profile.Columns.name.collating(.nocase).like(pattern, escape: "\\") ||
//            Profile.Columns.about.collating(.nocase).like(pattern, escape: "\\") ||
            Profile.Columns.pubkey == search
        )
    }
}

extension Profile {
    var primalUser: PrimalUser {
        .init(id: id, pubkey: pubkey, npub: npub, name: name, about: about, picture: picture, nip05: nip05, banner: banner, displayName: displayName, location: location, lud06: lud06, lud16: lud16, website: website, tags: [[]], created_at: 0, sig: "", deleted: false)
    }
}
