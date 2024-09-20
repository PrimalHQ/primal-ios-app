//
//  DatabaseManager+Profile.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.9.24..
//

import GRDB
import Combine

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

extension DatabaseManager {
    func saveProfiles(_ profiles: [PrimalUser]) {
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
    
    func lastVisitedProfilesPublisher() -> AnyPublisher<[Profile], any Error> {

        ValueObservation.tracking { db in
            try Profile.fetchAll(db)
        }
        .publisher(in: dbWriter)
        .eraseToAnyPublisher()
    }
}
