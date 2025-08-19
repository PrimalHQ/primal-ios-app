//
//  CGRect+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.1.24..
//

import Foundation

extension CGRect {
    func enlarge(_ size: CGFloat) -> CGRect {
        var rect = self
        rect.origin.x -= size / 2
        rect.origin.y -= size / 2
        rect.size.width += size
        rect.size.height += size
        return rect
    }
}

extension CGPoint {
    func translated(by point: CGPoint) -> CGPoint {
        return CGPoint(x: x + point.x, y: y + point.y)
    }
    
    /// Mutating version: translates this point in place.
    mutating func translate(by point: CGPoint) {
        x += point.x
        y += point.y
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx * dx + dy * dy)
    }
}
