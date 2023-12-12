//
//  StringProtocol.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public extension LosslessStringConvertible {
    var string: String { .init(self) }
}

public extension Array {
    subscript(safe i: Int) -> Element? {
        if isEmpty || i < 0 || i >= count { return nil }
        return self[i]
    }
}

public extension String {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
