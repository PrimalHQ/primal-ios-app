//
//  SecretsManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.2.26..
//

import Foundation

class SecretsManager {
    static let instance = SecretsManager()

    private let secrets: [String: Any]

    private init() {
        guard let url = Bundle.main.url(forResource: "secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            fatalError("Missing secrets.plist")
        }
        secrets = dict
    }

    var breezApiKey: String {
        guard let key = secrets["BreezApiKey"] as? String else {
            fatalError("Missing BreezApiKey in secrets.plist")
        }
        return key
    }

    var klipyApiKey: String {
        guard let key = secrets["KlipyApiKey"] as? String else {
            fatalError("Missing KlipyApiKey in secrets.plist")
        }
        return key
    }
}
