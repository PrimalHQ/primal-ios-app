//
//  ProfileCounts.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.9.24..
//

import GRDB

struct ProfileCounts: Identifiable, Equatable {
    var id: String { profilePubkey }
    
    var profilePubkey: String
    
    var follows: Int
    var followers: Int
    var replies: Int
    var notes: Int
    var articles: Int
    var media: Int
    
    var timeJoined: Int
}

extension ProfileCounts: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let profilePubkey = Column(CodingKeys.profilePubkey)
        static let follows = Column(CodingKeys.follows)
        static let replies = Column(CodingKeys.replies)
        static let followers = Column(CodingKeys.followers)
        static let notes = Column(CodingKeys.notes)
        static let articles = Column(CodingKeys.articles)
        static let media = Column(CodingKeys.media)
        static let timeJoined = Column(CodingKeys.timeJoined)
    }
}

extension DerivableRequest<ProfileCounts> {
    /// A request of players ordered by name.
    ///
    /// For example:
    ///
    ///     let profiles: [Player] = try dbWriter.read { db in
    ///         try Player.all().orderedByName().fetchAll(db)
    ///     }
    func orderedByFollowers() -> Self {
        // Sort by name in a localized case insensitive fashion
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
        order(ProfileCounts.Columns.followers.collating(.localizedCaseInsensitiveCompare))
    }
}
