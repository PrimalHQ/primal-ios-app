//
//  Color.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import SwiftUI

extension UIColor {
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
        //order of gradient colors
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
}

extension Array where Element: UIColor {
    func withAlphaComponent(_ alpha: CGFloat) -> [UIColor] {
        map { $0.withAlphaComponent(alpha) }
    }
}
