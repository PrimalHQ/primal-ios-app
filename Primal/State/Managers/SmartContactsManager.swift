//
//  SmartContactsManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.1.24..
//

import Foundation
import Combine

struct CodableParsedUser: Codable {
    let data: PrimalUser
    let profileImage: MediaMetadata.Resource
    let followers: Int?
    
    init(_ parsed: ParsedUser) {
        data = parsed.data
        profileImage = parsed.profileImage
        followers = parsed.followers
    }
    
    var parsed: ParsedUser { .init(data: data, profileImage: profileImage, followers: followers) }
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
    
    var cachedContactPubkeys: [String: [String]] = [:]
    var cachedDefaults: [String: [ParsedUser]] = [:]
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        ICloudKeychainManager.instance.$userPubkey
            .flatMap { pubkey in
                DatabaseManager.instance.lastVisitedProfilePubkeysPublisher(pubkey)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] pubkeys in
                self?.cachedContactPubkeys[IdentityManager.instance.userHexPubkey] = pubkeys
            }
            .store(in: &cancellables)
    }
    
    func userSearchPublisher(_ text: String) -> AnyPublisher<[ParsedUser], Never> {
        switch text {
        case "":
            let contactPubkeys = cachedContactPubkeys[IdentityManager.instance.userHexPubkey] ?? []
            let allPubkeys = contactPubkeys + Self.recommendedUsersNpubs.filter { !contactPubkeys.contains($0) }
            
            return DatabaseManager.instance.getProfilesPublisher(allPubkeys).first()
                .replaceError(with: [])
                .flatMap({ users in
                    let orderedUsers = allPubkeys.compactMap { pubkey in users.first(where: { $0.data.pubkey == pubkey }) }
                    return Publishers.Merge(Just(orderedUsers), {
                        let missingPubkeys = allPubkeys.filter { pubkey in !users.contains(where: { $0.data.pubkey == pubkey && $0.followers != nil }) }
                        
                        if missingPubkeys.isEmpty { return Just(orderedUsers).eraseToAnyPublisher() }
                        
                        return SocketRequest(name: "user_infos", payload: ["pubkeys": .array(missingPubkeys.map { .string($0) })])
                            .publisher()
                            .map {
                                let users = $0.getSortedUsers() + users
                                
                                return allPubkeys.compactMap { pubkey in users.first(where: { $0.data.pubkey == pubkey }) }
                            }
                            .eraseToAnyPublisher()
                    }())
                })
                .eraseToAnyPublisher()
        default:
            return Publishers.Merge(
                DatabaseManager.instance.searchProfilesPublisher(text).replaceError(with: []).first(),
                SocketRequest(name: "user_search", payload: .object([
                    "query": .string(text),
                    "limit": .number(15),
                ]))
                .publisher()
                .map { $0.getSortedUsers() }
            )
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
        }
    }
    
    func addContact(_ contact: ParsedUser) {
        if contact.data.pubkey == IdentityManager.instance.userHexPubkey { return }
        if MuteManager.instance.isMutedUser(contact.data.pubkey) { return }
        
        var cached = cachedContactPubkeys[IdentityManager.instance.userHexPubkey, default: []]
        cached.removeAll(where: { $0 == contact.data.pubkey })
        cached.insert(contact.data.pubkey, at: 0)
        cachedContactPubkeys[IdentityManager.instance.userHexPubkey] = cached
        
        DatabaseManager.instance.setVisitProfiles([contact.data])
    }
    
    func addContacts(_ contacts: [ParsedUser]) {
        let contacts = contacts.map { $0.data }
            .filter({ $0.pubkey != IdentityManager.instance.userHexPubkey && !MuteManager.instance.isMutedUser($0.pubkey) })
        
        if contacts.isEmpty { return }
        
        DatabaseManager.instance.setVisitProfiles(contacts)
    }
}
