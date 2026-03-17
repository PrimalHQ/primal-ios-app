//
//  Color.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import SwiftUI

extension UIColor {
    static let pro = UIColor(rgb: 0xE47C00)
    static let gold = UIColor(rgb: 0xFFA02F)
    static let live = UIColor(rgb: 0xEE0000)
    static let delete = UIColor(rgb: 0xFA3C3C)
    static let onboarding = UIColor(rgb: 0x252628)
    
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func gradientColor(
        _ colors: [UIColor] = gradient,
        bounds: CGSize,
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)
    ) -> UIColor? {
        let gradient = CAGradientLayer()
        gradient.frame = .init(origin: .zero, size: bounds)
        // order of gradient colors
        gradient.colors = colors.map { $0.cgColor }
        
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        UIGraphicsBeginImageContextWithOptions(bounds, false, UIScreen.main.scale)

        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let image else { return nil }
        return UIColor(patternImage: image)
    }
    
    static func mix(_ color1: UIColor, _ color2: UIColor, fraction: CGFloat = 0.5) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = min(max(fraction, 0), 1)
        return UIColor(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            alpha: a1 + (a2 - a1) * t
        )
    }
}

extension Array where Element: UIColor {
    func withAlphaComponent(_ alpha: CGFloat) -> [UIColor] {
        map { $0.withAlphaComponent(alpha) }
    }
}
