//
//  TextRepresenting.swift
//  Primal
//
//  Created by Pavle D Stevanović on 6.7.23..
//

import UIKit

protocol TextRepresenting: UIView {
    var contentColor: UIColor { get set }
    var contentFont: UIFont { get set }
}

extension UITextField: TextRepresenting {
    var contentColor: UIColor {
        get { textColor ?? .black }
        set { textColor = newValue }
    }
    
    var contentFont: UIFont {
        get { font ?? .appFont(withSize: 14, weight: .regular) }
        set { font = newValue }
    }
}

extension UITextView: TextRepresenting {
    var contentColor: UIColor {
        get { textColor ?? .black }
        set { textColor = newValue }
    }
    
    var contentFont: UIFont {
        get { font ?? .appFont(withSize: 14, weight: .regular) }
        set { font = newValue }
    }
}

extension UILabel: TextRepresenting {
    var contentColor: UIColor {
        get { textColor ?? .black }
        set { textColor = newValue }
    }
    
    var contentFont: UIFont {
        get { font ?? .appFont(withSize: 14, weight: .regular) }
        set { font = newValue }
    }
}
