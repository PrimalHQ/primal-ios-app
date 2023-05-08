//
//  Numbers+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.5.23..
//

import Foundation

extension FloatingPoint {
    func clamp(_ minimum: Self, _ maximum: Self) -> Self {
        min(maximum, max(minimum, self))
    }
}
