//
//  DatabaseManager+Nip05Check.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.10.24..
//

import Combine
import Foundation

extension DatabaseManager {
    func saveCheckedNips05(_ info: [String: String]) {
        if info.isEmpty { return }
        
        let nip05s = Array(info.keys)
        
        performUpdates { db in
            let allCheckedNip05s = try ProfileNip05Check.all().filterNip05s(nip05s).fetchAll(db)
            
            for (nip05, pubkey) in info {
                if var old = allCheckedNip05s.first(where: { $0.nip05 == nip05 }) {
                    old.pubkey = pubkey
                    old.lastChecked = .now
                    try old.save(db)
                } else {
                    var new = ProfileNip05Check(nip05: nip05, pubkey: pubkey, lastChecked: .now)
                    try new.save(db)
                }
            }
        }
    }
    
    func getCheckedNips() -> AnyPublisher<[String: String], Never> {
        dbWriter.readPublisher { db in
            try ProfileNip05Check.all().filterLastChecked(since: Date.now.addingTimeInterval(-14 * 60 * 60 * 24)).fetchAll(db)
        }
        .replaceError(with: [])
        .map {
            $0.reduce(into: [:], { $0[$1.nip05] = $1.pubkey })
        }
        .eraseToAnyPublisher()
    }
}
