//
//  NSRange+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import Foundation

public extension NSRange {
    var endLocation: Int {
        get { location + length }
        set { length = newValue - location }
    }
    
    func overlaps(_ range: NSRange) -> Bool {
        (range.location == location && range.length > 0 && length > 0) ||
        (range.location > location && range.location < endLocation) ||
        (range.endLocation > location && range.endLocation < endLocation) ||
        (location > range.location && location < range.endLocation) ||
        (endLocation > range.location && endLocation < range.endLocation)
    }
}
