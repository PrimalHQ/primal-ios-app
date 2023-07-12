//
//  UIStackView+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 6.7.23..
//

import UIKit

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis = .horizontal, _ subviews: [UIView]) {
        self.init(arrangedSubviews: subviews)
        self.axis = axis
    }
}
