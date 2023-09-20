//
//  ChatManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.9.23..
//

import Combine
import Foundation

final class ChatManager {
    
    enum Relation: String {
        case follows
        case other
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    func getRecentChats(_ relation: Relation, callback: @escaping ([Chat]) -> Void) {
        Connection.instance.$isConnected.filter { $0 }
            .first()
            .flatMap({ _ in
                SocketRequest(name: "get_directmsg_contacts", payload: .object([
                    "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
                    "relation": .string(relation.rawValue)
                ])).publisher()
            })
            .map { $0.processChats() }
            .receive(on: DispatchQueue.main)
            .sink { result in
                callback(result)
            }
            .store(in: &cancellables)
    }
    
    func getChatMessages(pubkey: String, _ callback: @escaping ([ProcessedMessage]) -> Void) {
        Connection.instance.$isConnected.filter { $0 }
            .first()
            .flatMap { _ in
                SocketRequest(name: "get_directmsgs", payload: .object([
                    "limit": .number(20),
                    "since": .number(0),
                    "receiver": .string(pubkey),
                    "sender": .string(IdentityManager.instance.userHexPubkey)
                ])).publisher()
            }
            .map { $0.processMessages()}
            .receive(on: DispatchQueue.main)
            .sink { result in
                callback(result)
            }
            .store(in: &cancellables)
    }
}
