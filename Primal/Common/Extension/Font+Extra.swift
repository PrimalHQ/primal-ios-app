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
            case .thin:             return UIFont(name: "RobotoFlex-Regular_Thin", size: size)
            case .ultraLight:       return UIFont(name: "RobotoFlex-Regular_ExtraLight", size: size)
            case .light:            return UIFont(name: "RobotoFlex-Regular_Light", size: size)
            case .regular:          return UIFont(name: "RobotoFlex-Regular", size: size)
            case .medium:           return UIFont(name: "RobotoFlex-Regular_Medium", size: size)
            case .semibold:         return UIFont(name: "RobotoFlex-Regular_SemiBold", size: size)
            case .bold:             return UIFont(name: "RobotoFlex-Regular_Bold", size: size)
            case .heavy:            return UIFont(name: "RobotoFlex-Regular_ExtraBold", size: size)
            case .black:            return UIFont(name: "RobotoFlex-Regular_Black", size: size)
            default:                return nil
            }
        }() ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
