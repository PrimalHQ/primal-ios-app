//
//  PremiumProfile.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.4.26..
//

import GRDB

struct PremiumProfile: Identifiable, Equatable {
    var id: String { pubkey }

    var pubkey: String
    var legendCustomization: String?
    var premiumInfo: String?
    var premiumName: String?
}

extension PremiumProfile: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let pubkey = Column(CodingKeys.pubkey)
        static let legendCustomization = Column(CodingKeys.legendCustomization)
        static let premiumInfo = Column(CodingKeys.premiumInfo)
        static let premiumName = Column(CodingKeys.premiumName)
    }
}
