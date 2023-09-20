//
//  Collection+Extra.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.9.23..
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
