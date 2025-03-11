//
//  DatabaseManager+Profile.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.9.24..
//

import GRDB
import Combine

extension DatabaseManager {
    func saveProfiles(_ profiles: [PrimalUser]) {
        if profiles.isEmpty { return }
        
        let profiles = profiles.map { $0.toProfile() }
        
        performUpdates { db in
            for var profile in profiles {
                try profile.save(db)
            }
        }
    }
    
    func setVisitProfiles(_ profiles: [PrimalUser]) {
        performUpdates { db in
            for profile in profiles {
                var profileVisit = ProfileLastVisit(profilePubkey: profile.pubkey, userPubkey: IdentityManager.instance.userHexPubkey, lastVisit: .now)
                try profileVisit.save(db)
            }
        }
    }
    
    func lastVisitedProfilePubkeysPublisher(_ pubkey: String) -> AnyPublisher<[String], any Error> {
        dbWriter.readPublisher  { db in
            try ProfileLastVisit.lastVisitedProfilePubkeysRequest(pubkey).fetchAll(db)
        }
        .map { $0.map { $0.profilePubkey } }
        .eraseToAnyPublisher()
    }
    
    
    func getProfilePublisher(_ pubkey: String) -> AnyPublisher<ParsedUser, any Error> {
        dbWriter.readPublisher { db in
            let sql = "SELECT \"profile\".*, \"mediaResource\".* FROM \"profile\" LEFT JOIN \"mediaResource\" ON \"mediaResource\".\"url\" = \"profile\".\"picture\" WHERE \"profile\".\"pubkey\" = ?"
            return try Row.fetchOne(db, sql: sql, arguments: [pubkey])
        }
        .map { (row: Row?) in
            guard let row = row, var profile = try? Profile(row: row) else {
                // No profile found, return a default ParsedUser
                return ParsedUser(data: .init(pubkey: pubkey), profileImage: nil)
            }
            profile.pictureMedia = .initFromRow(row)
            return ParsedUser(profile: profile)
        }
        .eraseToAnyPublisher()
    }
    
    func getProfilesPublisher(_ pubkeys: [String]) -> AnyPublisher<[ParsedUser], any Error> {
        dbWriter.readPublisher { db in
            let sql = """
                SELECT "profile".*, "profileCount".*, "mediaResource".*
                FROM "profile"
                LEFT JOIN "profileCount" ON "profileCount"."profilePubkey" = "profile"."pubkey"
                LEFT JOIN "mediaResource" ON "mediaResource"."url" = "profile"."picture"
                WHERE "profile"."pubkey" IN (\(Array(repeating: "?", count: pubkeys.count).joined(separator: ",")))
                """
            return try Row.fetchAll(db, sql: sql, arguments: .init(pubkeys))
        }
        
        .map { (rows: [Row]) in
            return rows.compactMap { row in
                guard var profile = try? Profile(row: row) else {
                    return nil
                }
                profile.pictureMedia = .initFromRow(row)
                profile.profileCount = .init(row: row)
                return .init(profile: profile)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func searchProfilesPublisher(_ search: String) -> AnyPublisher<[ParsedUser], any Error> {
        dbWriter.readPublisher { db in
            try Profile.all()
                .searchUsers(search)
                .including(optional: Profile.profileCount.orderedByFollowers())
                .limit(20)
                .fetchAll(db)
        }
        .map { $0.map({ ParsedUser(profile: $0) }) }
        .eraseToAnyPublisher()
    }
}

extension PrimalUser {
    func toProfile() -> Profile {
        Profile(
            pubkey: pubkey,
            npub: npub,
            name: name,
            about: about,
            picture: picture,
            nip05: nip05,
            banner: banner,
            displayName: displayName,
            location: location,
            lud06: lud06,
            lud16: lud16,
            website: website,
            rawData: rawData ?? ""
        )
    }
}

extension ParsedUser {
    convenience init(profile: Profile) {
        self.init(data: profile.primalUser, profileImage: profile.pictureMedia?.toNativeForm(), followers: profile.profileCount?.followers)
    }
}
