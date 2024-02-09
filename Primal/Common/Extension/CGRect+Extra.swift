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
