//
//  CheckNip05Manager.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import Foundation
import Combine

private extension String {
    static let checkedNipsKey = "checkedNipsKey"
}

private extension UserDefaults {
    var checkedNips: [String: String] {
        get { string(forKey: .checkedNipsKey)?.decode() ?? [:] }
        set { set(newValue.encodeToString(), forKey: .checkedNipsKey)}
    }
}

class CheckNip05Manager {
    static let instance = CheckNip05Manager()
    
    var checkedNips: [String: String] = UserDefaults.standard.checkedNips {
        didSet {
            UserDefaults.standard.checkedNips = checkedNips
        }
    }
    
    var dontCheckAgain: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    func isVerified(_ user: PrimalUser) -> Bool {
        guard !user.nip05.isEmpty else { return false }
        
        if let pubkey = checkedNips[user.nip05] {
            return user.pubkey == pubkey
        }
        
        if dontCheckAgain.contains(user.nip05) {
            return false
        }
        
        checkNip(user.nip05)
        return false
    }
    
    func checkNip(_ nip: String) {
        let segments = nip.split(separator: "@")
        guard let name = segments.first, let domain = segments.dropFirst().first else { return }
        
        CheckNip05Request(domain: String(domain), name: String(name)).publisher()
            .sink { [weak self] _ in
                if self?.checkedNips[nip] == nil {
                    self?.dontCheckAgain.insert(nip)
                }
            } receiveValue: { [weak self] json in
                guard let names = json.objectValue?["names"]?.objectValue else { return }
                
                for (key, value) in names {
                    guard let pubkey = value.stringValue else { continue }
                    self?.checkedNips["\(key)@\(domain)"] = pubkey
                }
            }
            .store(in: &cancellables)
    }
}
