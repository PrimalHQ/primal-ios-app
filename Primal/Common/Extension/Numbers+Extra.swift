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
    
    var digitCount: Int { numberOfDigits(in: Int(self)) }
    
    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number > -10 {
            return 1
        }
        return 1 + numberOfDigits(in: number/10)
    }
    
    func satsToBitcoinString() -> String {
        let string = String(self)
        
        if string.count > 8 {
            return string.prefix(string.count - 8) + "." + string.suffix(8)
        }
        if string.count == 8 {
            return "0." + string
        }
        
        let diff = 8 - string.count
        return "0." + (0..<diff).reduce("", { a, _ in a + "0" }) + string
    }
}

extension Int {
    static let BTC_TO_USD: Int = 27439
    static let BTC_TO_SAT: Int = 100_000_000
}

extension Double {
    static let BTC_TO_USD: Double = 27439
    static let BTC_TO_SAT: Double = 100_000_000
    static let SAT_TO_USD: Double = BTC_TO_USD / BTC_TO_SAT
    
    func localized() -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf.string(from: self as NSNumber) ?? ""
    }
}
