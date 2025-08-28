//
//  CheckNip05Manager.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import Foundation
import Combine

class CheckNip05Manager {
    static let instance = CheckNip05Manager()
    
    var checkedNips: [String: String] = [:]
    
    var dontCheckAgain: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        DatabaseManager.instance.getCheckedNips()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] checkedNips in
                self?.checkedNips = checkedNips
            }
            .store(in: &cancellables)
    }
    
    func isVerified(_ user: PrimalUser) -> Bool {
        if let custom = PremiumCustomizationManager.instance.getCustomization(pubkey: user.pubkey), custom.custom_badge {
            return true
        }
        
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.checkedNips[nip] == nil {
                    self?.dontCheckAgain.insert(nip)
                }
            } receiveValue: { [weak self] json in
                guard let names = json.objectValue?["names"]?.objectValue else { return }
                
                var result: [String: String] = [:]
                
                for (key, value) in names {
                    guard let pubkey = value.stringValue else { continue }
                    self?.checkedNips["\(key)@\(domain)"] = pubkey
                    result["\(key)@\(domain)"] = pubkey
                }
                
                DatabaseManager.instance.saveCheckedNips05(result)
            }
            .store(in: &cancellables)
    }
}
