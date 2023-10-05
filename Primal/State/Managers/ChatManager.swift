//
//  ChatManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.9.23..
//

import Combine
import Foundation
import GenericJSON

final class ChatManager {
    
    enum Relation: String {
        case follows
        case other
    }
    
    let idJsonID: JSON = .string(IdentityManager.instance.userHexPubkey)
    var continousConnection: ContinousConnection? {
        didSet {
            oldValue?.end()
        }
    }    
    
    @Published var newMessagesCount = 0
    
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
    
    func getChatMessagesHistory(pubkey: String, until: Double, _ callback: @escaping ([ProcessedMessage]) -> Void) {
        Connection.instance.$isConnected.filter { $0 }
            .first()
            .flatMap { _ in
                SocketRequest(name: "get_directmsgs", payload: .object([
                    "limit": .number(20),
                    "until": .number(until),
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
    
    func getChatMessages(pubkey: String, since: Double = 0, _ callback: @escaping ([ProcessedMessage]) -> Void) {
        Connection.instance.$isConnected.filter { $0 }
            .first()
            .flatMap { _ in
                SocketRequest(name: "get_directmsgs", payload: .object([
                    "limit": .number(20),
                    "since": .number(since),
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
    
    func updateChatCount() {
        Connection.instance.$isConnected.filter { $0 }.sink { [weak self] _ in
            self?.continousConnection = Connection.instance.requestCacheContinous(name: "directmsg_count", request: .object([
                "pubkey": self?.idJsonID ?? .string("")
            ])) { response in
                guard let resDict = response.arrayValue?.last?.objectValue else { return }
                
                let count = Int(resDict["cnt"]?.doubleValue ?? 0)
                
                DispatchQueue.main.async {
                    self?.newMessagesCount = count
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func notifyReadStatus(pubkey: String) {
        guard let event = NostrObject.chatRead(pubkey) else { return }
        
        SocketRequest(name: "reset_directmsg_count", payload: .object([
            "event_from_user": event.toJSON(),
            "sender": .string(pubkey)
        ]))
        .publisher()
        .sink { _ in }
        .store(in: &cancellables)
    }
    
    func markAllChatsAsRead() {
        guard let event = NostrObject.markAllChatRead() else { return }
        
        SocketRequest(name: "reset_directmsg_counts", payload: .object([
            "event_from_user": event.toJSON()
        ]))
        .publisher()
        .sink { _ in }
        .store(in: &cancellables)   
    }
}
