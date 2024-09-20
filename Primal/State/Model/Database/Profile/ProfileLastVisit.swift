//
//  ProfileLastVisit.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.9.24..
//

import Foundation
import GRDB

struct ProfileLastVisit: Identifiable, Equatable {
    var id: String { profilePubkey}
    
    var profilePubkey: String
    var userPubkey: String
    var lastVisit: Date
}

extension ProfileLastVisit: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let profilePubkey = Column(CodingKeys.profilePubkey)
        static let userPubkey = Column(CodingKeys.userPubkey)
        static let lastVisit = Column(CodingKeys.lastVisit)
    }
}

extension ProfileLastVisit {
    static let profile = belongsTo(Profile.self)
    var profile: QueryInterfaceRequest<Profile> {
        request(for: ProfileLastVisit.profile)
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
    func current() -> Self {
        self
    }
}
