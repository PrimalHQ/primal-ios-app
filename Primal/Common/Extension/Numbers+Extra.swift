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
    
    func shortenedLocalized() -> String {
        if self < 1000 {
            return "\(self)"
        }
        
        let multipliers: [(String, Int)] = [
            ("", 1),
            ("k", 1_000),
            ("m", 1_000_000),
            ("b", 1_000_000_000)
        ]
        
        let iSelf = Int(self)
        
        for ((oldShorten, oldMultiplier), (shorten, multiplier)) in zip(multipliers, multipliers.dropFirst()) {
            let total = iSelf / multiplier
            if total < 10 {
                let oldTotal = iSelf / oldMultiplier
                return "\(oldTotal.localized())\(oldShorten)"
            }
            if total < 1000 {
                return "\(total)\(shorten)"
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
    
    func satsToUsdAmountString(_ roundingStyle: RoundingStyle) -> String {
        switch roundingStyle {
        case .threeDecimals:
            return Double(self).satToUSD.nDecimalPoints(n: 3)
        case .twoDecimals:
            return Double(self).satToUSD.nDecimalPoints(n: 2)
        case .removeZeros:
            return Double(self).satToUSD.localized()
        }
    }
}

extension Double {
    static var BTC_TO_USD: Double { WalletManager.instance.btcToUsd }
    static let BTC_TO_SAT: Double = 100_000_000
    
    var satToUSD: Double {
        (self * .BTC_TO_USD) / .BTC_TO_SAT
    }
    
    var usdToSAT: Double {
        (self * .BTC_TO_SAT) / .BTC_TO_USD
    }
    
    func localized() -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf.string(from: self as NSNumber) ?? ""
    }
    
    func nDecimalPoints(n: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = n
        nf.minimumFractionDigits = n
        return nf.string(from: self as NSNumber) ?? ""
    }
}

extension CGFloat {
    func interpolatingBetween(start: CGFloat, end: CGFloat) -> CGFloat {
        start + (end - start) * self.clamp(0, 1)
    }
    
    func squareInterpolatingBetween(start: CGFloat, end: CGFloat) -> CGFloat {
        start + (end - start) * self.clamp(0, 1) * self.clamp(0, 1)
    }    
}
