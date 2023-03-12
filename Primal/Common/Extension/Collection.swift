//
//  Collection.swift
//  Primal
//
//  Created by Nikola Lukovic on 6.3.23..
//
// https://stackoverflow.com/a/37225027/3248293
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element == NostrContent {
    mutating func append(_ element: Element, callback: (Element)->Void) {
        self.append(element)
        callback(element)
    }
}
