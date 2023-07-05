//
//  Array+Extra.swift
//  Primal
//
//  Created by Nikola Lukovic on 5.7.23..
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
