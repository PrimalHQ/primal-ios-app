//
//  SmartContactsManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.1.24..
//

import Foundation
import Combine

private extension String {
    static let smartContactListKey = "smartContactListKey"
    static let smartContactDefaultListKey = "smartContactDefaultListKey"
}

struct CodableParsedUser: Codable {
    let data: PrimalUser
    let profileImage: MediaMetadata.Resource
    let likes: Int?
    let followers: Int?
    
    init(_ parsed: ParsedUser) {
        data = parsed.data
        profileImage = parsed.profileImage
        likes = parsed.likes
        followers = parsed.followers
    }
    
    var parsed: ParsedUser { .init(data: data, profileImage: profileImage, likes: likes, followers: followers) }
}

private extension UserDefaults {
    var smartContactLists: [String: [CodableParsedUser]] {
        get { string(forKey: .smartContactListKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .smartContactListKey) }
    }
    
    var smartContactDefaultList: [String: [CodableParsedUser]] {
        get { string(forKey: .smartContactDefaultListKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .smartContactDefaultListKey) }
    }
}

final class SmartContactsManager {
    static let instance = SmartContactsManager()
    
    static private var recommendedUsersNpubs: [String] { [
        "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2", // jack
        "bf2376e17ba4ec269d10fcc996a4746b451152be9031fa48e74553dde5526bce", // carla
        "c48e29f04b482cc01ca1f9ef8c86ef8318c059e0e9353235162f080f26e14c11", // walker
        "85080d3bad70ccdcd7f74c29a44f55bb85cbcd3dd0cbb957da1d215bdb931204", // preston
        "eab0e756d32b80bcd464f3d844b8040303075a13eabc3599a762c9ac7ab91f4f", // lyn
        "04c915daefee38317fa734444acee390a8269fe5810b2241e5e6dd343dfbecc9", // odell
        "472f440f29ef996e92a186b8d320ff180c855903882e59d50de1b8bd5669301e", // marty
        "e88a691e98d9987c964521dff60025f60700378a4879180dcbbb4a5027850411", // nvk
        "91c9a5e1a9744114c6fe2d61ae4de82629eaaa0fb52f48288093c7e7e036f832", // rockstar
        "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52", // pablo
    ] }
    
    func userSearchPublisher(_ text: String) -> AnyPublisher<[ParsedUser], Never> {
        switch text {
        case "":
            let contacts = getContacts()
            let contactPubkeys = contacts.map { $0.data.pubkey }
            
            let searchContacts = Set((contactPubkeys + Self.recommendedUsersNpubs))
            
            let defaultContacts = getDefaultContacts()
            
            return Publishers.Merge(
                Just((contacts + defaultContacts).map { $0 }),
                
                SocketRequest(name: "user_infos", payload: .object([
                    "pubkeys": .array(searchContacts.map { .string($0) })
                ]))
                .publisher()
                .map {
                    let users = $0.getSortedUsers()
                    
                    let myContacts = contacts.map({ contact in users.first(where: { $0.data.pubkey == contact.data.pubkey }) ?? contact })
                    let other = users.filter { user in !myContacts.contains(where: { $0.data.npub == user.data.npub }) }
                    
                    SmartContactsManager.instance.setDefaultContacts(users)
                    SmartContactsManager.instance.setContacts(myContacts)
                    
                    return myContacts + other
                }
            ).eraseToAnyPublisher()
        default:
            return SocketRequest(name: "user_search", payload: .object([
               "query": .string(text),
               "limit": .number(15),
            ]))
            .publisher()
            .map { $0.getSortedUsers() }
            .eraseToAnyPublisher()
        }
    }
    
    func getDefaultContacts() -> [ParsedUser] {
        let contacts = getContacts()
        let defaults = UserDefaults.standard.smartContactDefaultList[IdentityManager.instance.userHexPubkey] ?? []
        
        return defaults.filter({ defaultC in !contacts.contains(where: { defaultC.data.pubkey == $0.data.pubkey })}).map { $0.parsed }
    }
    
    func setDefaultContacts(_ contacts: [ParsedUser]) {
        let contacts = contacts.filter { Self.recommendedUsersNpubs.contains($0.data.pubkey) }
        UserDefaults.standard.smartContactDefaultList[IdentityManager.instance.userHexPubkey] = contacts.map { .init($0) }
    }
    
    func setContacts(_ contacts: [ParsedUser]) {
        UserDefaults.standard.smartContactLists[IdentityManager.instance.userHexPubkey] = contacts.map { .init($0) }
    }
    
    func getContacts() -> [ParsedUser] {
        (UserDefaults.standard.smartContactLists[IdentityManager.instance.userHexPubkey] ?? []).map { $0.parsed }
    }
    
    func addContact(_ contact: ParsedUser) {
        if contact.isCurrentUser {
            // Can't add self as contact
            return
        }
        
        var contacts = getContacts()
        if let old = contacts.first(where: { $0.data.pubkey == contact.data.pubkey }) {
            contact.followers = contact.followers ?? old.followers
            contact.likes = contact.likes ?? old.likes
        }
        contacts.removeAll(where: { $0.data.pubkey == contact.data.pubkey })
        contacts.insert(contact, at: 0)
        if contacts.count > 10 {
            contacts.removeLast(contacts.count - 10)
        }
        UserDefaults.standard.smartContactLists[IdentityManager.instance.userHexPubkey] = contacts.map { .init($0) }
    }
}
