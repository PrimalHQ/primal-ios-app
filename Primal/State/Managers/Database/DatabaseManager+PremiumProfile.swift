//
//  DatabaseManager+PremiumProfile.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.4.26..
//

import GRDB
import Combine

extension DatabaseManager {
    func saveLegendCustomizations(_ dict: [String: LegendCustomization]) {
        if dict.isEmpty { return }

        let encoded: [(String, String)] = dict.compactMap { pubkey, value in
            guard let json = value.encodeToString() else { return nil }
            return (pubkey, json)
        }

        performUpdates { db in
            for (pubkey, json) in encoded {
                try db.execute(sql: """
                    INSERT INTO \(PremiumProfile.databaseTableName) (pubkey, legendCustomization)
                    VALUES (?, ?)
                    ON CONFLICT(pubkey) DO UPDATE SET legendCustomization = excluded.legendCustomization
                    """, arguments: [pubkey, json])
            }
        }
    }

    func savePremiumInfos(_ dict: [String: PremiumUserInfo]) {
        if dict.isEmpty { return }

        let encoded: [(String, String)] = dict.compactMap { pubkey, value in
            guard let json = value.encodeToString() else { return nil }
            return (pubkey, json)
        }

        performUpdates { db in
            for (pubkey, json) in encoded {
                try db.execute(sql: """
                    INSERT INTO \(PremiumProfile.databaseTableName) (pubkey, premiumInfo)
                    VALUES (?, ?)
                    ON CONFLICT(pubkey) DO UPDATE SET premiumInfo = excluded.premiumInfo
                    """, arguments: [pubkey, json])
            }
        }
    }

    func savePremiumNames(_ dict: [String: String]) {
        if dict.isEmpty { return }

        performUpdates { db in
            for (pubkey, name) in dict {
                try db.execute(sql: """
                    INSERT INTO \(PremiumProfile.databaseTableName) (pubkey, premiumName)
                    VALUES (?, ?)
                    ON CONFLICT(pubkey) DO UPDATE SET premiumName = excluded.premiumName
                    """, arguments: [pubkey, name])
            }
        }
    }

    func loadAllPremiumProfilesPublisher() -> AnyPublisher<[PremiumProfile], any Error> {
        dbWriter.readPublisher { db in
            try PremiumProfile.fetchAll(db)
        }
        .eraseToAnyPublisher()
    }
}
