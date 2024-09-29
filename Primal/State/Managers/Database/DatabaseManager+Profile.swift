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
    
    func setVisitProfile(_ profile: PrimalUser) {
        var profileVisit = ProfileLastVisit(profilePubkey: profile.pubkey, userPubkey: IdentityManager.instance.userHexPubkey, lastVisit: .now)
        performUpdates { db in
            try profileVisit.save(db)
        }
    }
    
    func lastVisitedProfilePubkeysPublisher() -> AnyPublisher<[String], any Error> {
        ValueObservation.tracking { db in
            try ProfileLastVisit.lastVisitedProfilePubkeysRequest().fetchAll(db)
        }
        .publisher(in: dbWriter)
        .map { $0.map { $0.profilePubkey } }
        .eraseToAnyPublisher()
    }
    
    func getProfilePublisher(_ pubkey: String) -> AnyPublisher<ParsedUser, any Error> {
        ValueObservation.tracking { db in
            try Profile.all().filterPubkeys([pubkey]).fetchOne(db)
        }
        .publisher(in: dbWriter)
        .map { profile in
            if let profile {
                return ParsedUser(profile: profile)
            }
            return ParsedUser(data: .init(pubkey: pubkey), profileImage: nil)
        }
        .eraseToAnyPublisher()
    }
    
    func getProfilesPublisher(_ pubkeys: [String]) -> AnyPublisher<[ParsedUser], any Error> {
        ValueObservation.tracking { db in
            try Profile.all().filterPubkeys(pubkeys).including(optional: Profile.profileCount).fetchAll(db)
        }
        .publisher(in: dbWriter)
        .map { $0.map({ ParsedUser(profile: $0) }) }
        .eraseToAnyPublisher()
    }
    
    func searchProfilesPublisher(_ search: String) -> AnyPublisher<[ParsedUser], any Error> {
        ValueObservation.tracking { db in
            try Profile.all()
                .searchUsers(search)
                .including(optional: Profile.profileCount.orderedByFollowers())
                .limit(20)
                .fetchAll(db)
        }
        .publisher(in: dbWriter)
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
        self.init(data: profile.primalUser, followers: profile.profileCount?.followers)
    }
}
