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

public extension Array {
    subscript(safe i: Int?) -> Element? {
        guard let i else { return nil }
        if isEmpty || i < 0 || i >= count { return nil }
        return self[i]
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension Sequence {
    func uniqueByFilter<T: Hashable>(_ filter: (Element) -> T) -> [Element] {
        var seen: [T: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: filter($0)) == nil }
    }
}
