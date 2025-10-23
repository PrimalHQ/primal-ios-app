//
//  ProfileLastVisit.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.9.24..
//

import Foundation
import GRDB

struct ProfileLastVisit: Identifiable, Equatable {
    var id: String { profilePubkey }
    
    var profilePubkey: String
    var userPubkey: String
    var lastVisit: Date
}

extension ProfileLastVisit: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    internal enum Columns {
        static let profilePubkey = Column(CodingKeys.profilePubkey)
        static let userPubkey = Column(CodingKeys.userPubkey)
        static let lastVisit = Column(CodingKeys.lastVisit)
    }
}

extension ProfileLastVisit {
    static let profile = belongsTo(Profile.self)
}

struct ProfileLastVisitInfo: Decodable, FetchableRecord {
    var profile: Profile
    var profileLastVisit: ProfileLastVisit
    var profileCount: ProfileCount
}

extension ProfileLastVisit {
    static func lastVisitedProfilePubkeysRequest(_ pubkey: String) -> QueryInterfaceRequest<ProfileLastVisit> {
        ProfileLastVisit
            .order(ProfileLastVisit.Columns.lastVisit).reversed()
            .filter(ProfileLastVisit.Columns.userPubkey == pubkey)
            .limit(10)
    }
}
