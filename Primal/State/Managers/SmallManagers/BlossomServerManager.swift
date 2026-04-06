//
//  BlossomServerManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.1.25..
//

import Foundation
import GenericJSON

class BlossomServerManager {
    static let instance = BlossomServerManager()

    private let defaults = UserDefaults.standard
    private let defaultsKey = "blossomServerInfo"

    var info: [String: [String]] = [:]

    init() {
        if let persisted = defaults.dictionary(forKey: defaultsKey) as? [String: [String]] {
            info = persisted
        }
    }

    @MainActor
    func addBlossomInfo(_ infos: [String: JSON]) {
        guard
            let pubkey = infos["pubkey"]?.stringValue,
            let tags: [[JSON]] = infos["tags"]?.arrayValue?.compactMap({ $0.arrayValue })
        else { return }

        var serverURLs: [String] = []

        for tag in tags {
            guard
                tag.first?.stringValue == "server",
                let url = tag[safe: 1]?.stringValue
            else { continue }
            serverURLs.append(url)
        }

        if serverURLs.isEmpty { return }
        info[pubkey] = serverURLs
        defaults.set(info, forKey: defaultsKey)
    }

    func serversForUser(pubkey: String) -> [String]? { info[pubkey] }
}
