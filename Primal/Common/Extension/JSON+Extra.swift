//
//  JSON+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 7. 2025..
//

import GenericJSON

extension Array where Element == JSON {
    func tagArrayWithKey(_ key: String) -> [String]? {
        first(where: { $0.arrayValue?.first?.stringValue == key })
            .map { $0.arrayValue?.compactMap { $0.stringValue } ?? [] }
    }
    
    func tagValueForKey(_ key: String) -> String? {
        tagArrayWithKey(key)?[safe: 1]
    }
    
    func tagValueForKeyWithRole(_ key: String, role: String) -> String? {
        let res = first(where: {
            let array = $0.arrayValue
            return array?.first?.stringValue == key && array?[safe: 3]?.stringValue == role
        })
        .map { $0.arrayValue?.compactMap { $0.stringValue } ?? [] }
        return res?[safe: 1]
    }
}
