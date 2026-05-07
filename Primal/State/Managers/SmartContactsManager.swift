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

    var cachedContactPubkeys: [String: [String]] = [:]
    var cachedDefaults: [String: [ParsedUser]] = [:]
    private var cachedRecommendedUsers: [ParsedUser]?

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

            let contactsPublisher = DatabaseManager.instance.getProfilesPublisher(contactPubkeys)
                .replaceError(with: [])
                .map { users in
                    contactPubkeys.compactMap { pubkey in users.first(where: { $0.data.pubkey == pubkey }) }
                }

            return contactsPublisher
                .combineLatest(recommendedUsersPublisher())
                .map { contacts, recommended in
                    let seen = Set(contacts.map { $0.data.pubkey })
                    return contacts + recommended.filter { !seen.contains($0.data.pubkey) }
                }
                .eraseToAnyPublisher()
        default:
            return Publishers.Merge(
                DatabaseManager.instance.searchProfilesPublisher(text).replaceError(with: []).first(),
                SocketRequest(name: "user_search", payload: .object([
                    "query": .string(text),
                    "limit": .number(15)
                ]))
                .publisher()
                .map { $0.getSortedUsers() }
            )
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
        }
    }
    
    private func recommendedUsersPublisher() -> AnyPublisher<[ParsedUser], Never> {
        if let cached = cachedRecommendedUsers {
            return Just(cached).eraseToAnyPublisher()
        }
        return SocketRequest(name: "get_recommended_users", payload: nil)
            .publisher()
            .map { $0.getSortedUsers() }
            .handleEvents(receiveOutput: { [weak self] users in
                self?.cachedRecommendedUsers = users
            })
            .prepend([])
            .eraseToAnyPublisher()
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
