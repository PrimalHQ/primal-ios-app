//
//  ProfileCounts.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.9.24..
//

import GRDB

struct ProfileCount: Identifiable, Equatable {
    var id: String { profilePubkey }
    
    var profilePubkey: String
    
    var follows: Int?
    var followers: Int?
    var replies: Int?
    var notes: Int?
    var articles: Int?
    var media: Int?
    
    var timeJoined: Int?
}

extension ProfileCount: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    enum Columns {
        static let profilePubkey = Column(CodingKeys.profilePubkey)
        static let follows = Column(CodingKeys.follows)
        static let replies = Column(CodingKeys.replies)
        static let followers = Column(CodingKeys.followers)
        static let notes = Column(CodingKeys.notes)
        static let articles = Column(CodingKeys.articles)
        static let media = Column(CodingKeys.media)
        static let timeJoined = Column(CodingKeys.timeJoined)
    }
    
    static let profile = belongsTo(Profile.self)
    
    
    init(row: Row) {
        // Use default values if columns are NULL
        profilePubkey = row[Columns.profilePubkey] ?? ""
        follows = row[Columns.follows]
        followers = row[Columns.followers]
        replies = row[Columns.replies]
        notes = row[Columns.notes]
        articles = row[Columns.articles]
        media = row[Columns.media]
        timeJoined = row[Columns.timeJoined]
    }
}

extension DerivableRequest<ProfileCount> {
    func orderedByFollowers() -> Self {
        order(ProfileCount.Columns.followers).reversed()
    }
    
    func filterPubkeys(_ pubkeys: [String]) -> Self {
        filter(pubkeys.contains(ProfileCount.Columns.profilePubkey))
    }
}
