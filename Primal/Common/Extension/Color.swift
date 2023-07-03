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
    
    static let gradient: [UIColor] = [UIColor(rgb: 0xFA4343), UIColor(rgb: 0x5B12A4)]
}

extension Array where Element: UIColor {
    func withAlphaComponent(_ alpha: CGFloat) -> [UIColor] {
        map { $0.withAlphaComponent(alpha) }
    }
}
