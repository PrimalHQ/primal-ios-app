//
//  PremiumCustomizationManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import Foundation
//{"style":"PURPLEHAZE","custom_badge":true,"avatar_glow":true}

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
    var premium_since: Double
}

extension LegendCustomization {
    var theme: LegendTheme? { .init(rawValue: style?.lowercased() ?? "") }
}

class PremiumCustomizationManager {
    static let instance = PremiumCustomizationManager()
    
    private var customizations: [String: LegendCustomization] = [:]
    private var infos: [String: PremiumUserInfo] = [:]
    private var names: [String: String] = [:]
    
    private init() { }
    
    @MainActor
    func addLegendCustomizations(_ customizations: [String: LegendCustomization]) {
        for custom in customizations {
            self.customizations[custom.key] = custom.value
        }
    }
    
    @MainActor
    func addPremiumInfo(_ infos: [String: PremiumUserInfo]) {
        for inf in infos {
            self.infos[inf.key] = inf.value
        }
    }
    
    @MainActor
    func addPremiumNames(_ info: [String: String]) {
        for inf in info {
            names[inf.key] = inf.value
        }
    }
    
    func getPremiumName(pubkey: String) -> String? { names[pubkey] }
    
    func getCustomization(pubkey: String) -> LegendCustomization? { customizations[pubkey] }
    
    func getPremiumInfo(pubkey: String) -> PremiumUserInfo? { infos[pubkey] }
}
