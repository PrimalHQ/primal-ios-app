//
//  Numbers+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.5.23..
//

import Foundation

extension Comparable {
    func clamp(_ minimum: Self, _ maximum: Self) -> Self {
        min(maximum, max(minimum, self))
    }
}

extension FixedWidthInteger {
    func shortened() -> String {
        if self < 1000 {
            return "\(self)"
        }
        
        let multipliers: [(String, Float)] = [
            ("k", 1_000),
            ("m", 1_000_000),
            ("b", 1_000_000_000)
        ]
        
        for (shorten, multiplier) in multipliers {
            let total = Float(self) / multiplier
            if total < 10 {
                guard let string = String(format: "%.1f", total).split(separator: ".0").first else {
                    return String(format: "%.1f\(shorten)", total)
                }
                return string + shorten
            }
            if total < 1000 {
                return "\(Int(total))\(shorten)"
            }
        }
        
        return "1t+"
    }
    
    func localized() -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: Int(self) as NSNumber) ?? ""
    }
}

