//
//  Font+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

extension UIFont {
    static func appFont(withSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
