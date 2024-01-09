//
//  SmartContactsManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.1.24..
//

import Foundation

private extension String {
    static let smartContactListKey = "smartContactListKey"
}

extension UserDefaults {
    var smartContactLists: [String: [PrimalUser]] {
        get { string(forKey: .smartContactListKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .smartContactListKey) }
    }
}

final class SmartContactsManager {
    static let instance = SmartContactsManager()
    
    func getContacts() -> [PrimalUser] {
        UserDefaults.standard.smartContactLists[IdentityManager.instance.userHexPubkey] ?? []
    }
    
    func addContact(_ contact: PrimalUser) {
        var contacts = getContacts()
        contacts.removeAll(where: { $0.pubkey == contact.pubkey })
        contacts.insert(contact, at: 0)
        if contacts.count > 20 {
            contacts.removeLast(contacts.count - 20)
        }
        UserDefaults.standard.smartContactLists[IdentityManager.instance.userHexPubkey] = contacts
    }
}
