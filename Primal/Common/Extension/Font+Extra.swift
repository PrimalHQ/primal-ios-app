//
//  Font+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

extension UIFont {
    static func appFont(withSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        {
            switch weight {
            case .thin:             return UIFont(name: "Nacelle-Thin", size: size)
            case .ultraLight:       return UIFont(name: "Nacelle-UltraLight", size: size)
            case .light:            return UIFont(name: "Nacelle-Light", size: size)
            case .regular:          return UIFont(name: "Nacelle-Regular", size: size)
            case .medium:           return UIFont(name: "Nacelle-SemiBold", size: size)
            case .semibold:         return UIFont(name: "Nacelle-SemiBold", size: size)
            case .bold:             return UIFont(name: "Nacelle-Bold", size: size)
            case .heavy:            return UIFont(name: "Nacelle-Heavy", size: size)
            case .black:            return UIFont(name: "Nacelle-Black", size: size)
            default:                return nil
            }
        }() ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
