//
//  PremiumCustomizationManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import Combine
import Foundation
// {"style":"PURPLEHAZE","custom_badge":true,"avatar_glow":true}

struct LegendCustomization: Codable {
    var style: String?
    var custom_badge: Bool
    var avatar_glow: Bool
    var in_leaderboard: Bool
    var current_shoutout: String
    var edited_shoutout: String?
}

struct PremiumUserInfo: Codable {
    var tier: String
    var cohort_1: String
    var cohort_2: String
    var expires_on: Double?
    var legend_since: Double?
    var premium_since: Double?
}

extension LegendCustomization {
    var theme: LegendTheme? { .init(rawValue: style?.lowercased() ?? "") }
}

class PremiumCustomizationManager {
    static let instance = PremiumCustomizationManager()

    private var customizations: [String: LegendCustomization] = [:]
    private var infos: [String: PremiumUserInfo] = [:]
    private var names: [String: String] = [:]

    private var hydrationCancellable: AnyCancellable?

    private init() {
        hydrationCancellable = DatabaseManager.instance.loadAllPremiumProfilesPublisher()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] rows in
                guard let self else { return }
                for row in rows {
                    if self.customizations[row.pubkey] == nil,
                       let json = row.legendCustomization,
                       let value: LegendCustomization = json.decode() {
                        self.customizations[row.pubkey] = value
                    }
                    if self.infos[row.pubkey] == nil,
                       let json = row.premiumInfo,
                       let value: PremiumUserInfo = json.decode() {
                        self.infos[row.pubkey] = value
                    }
                    if self.names[row.pubkey] == nil, let name = row.premiumName {
                        self.names[row.pubkey] = name
                    }
                }
            })
    }

    @MainActor
    func addLegendCustomizations(_ customizations: [String: LegendCustomization]) {
        for custom in customizations {
            self.customizations[custom.key] = custom.value
        }
        DatabaseManager.instance.saveLegendCustomizations(customizations)
    }

    @MainActor
    func addPremiumInfo(_ infos: [String: PremiumUserInfo]) {
        for inf in infos {
            self.infos[inf.key] = inf.value
        }
        DatabaseManager.instance.savePremiumInfos(infos)
    }

    @MainActor
    func addPremiumNames(_ info: [String: String]) {
        for inf in info {
            names[inf.key] = inf.value
        }
        DatabaseManager.instance.savePremiumNames(info)
    }

    func getPremiumName(pubkey: String) -> String? { names[pubkey] }

    func getCustomization(pubkey: String) -> LegendCustomization? { customizations[pubkey] }

    func getPremiumInfo(pubkey: String) -> PremiumUserInfo? { infos[pubkey] }
}
