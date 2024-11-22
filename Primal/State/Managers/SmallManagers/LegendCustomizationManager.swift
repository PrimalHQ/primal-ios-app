//
//  LegendCustomizationManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import Foundation
//{"style":"PURPLEHAZE","custom_badge":true,"avatar_glow":true}

struct LegendCustomization: Codable {
    var style: String
    var custom_badge: Bool
    var avatar_glow: Bool
}

extension LegendCustomization {
    var theme: LegendTheme? { .init(rawValue: style.lowercased()) }
}

class LegendCustomizationManager {
    
    static let instance = LegendCustomizationManager()
    
    private var customizations: [String: LegendCustomization] = [:]
    
    private init() { }
    
    @MainActor
    func addCustomizations(_ customizations: [String: LegendCustomization]) {
        for custom in customizations {
            self.customizations[custom.key] = custom.value
        }
    }
    
    func getCustomization(pubkey: String) -> LegendCustomization? { customizations[pubkey] }
}
