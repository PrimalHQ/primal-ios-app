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
    
    func getAllChats(_ relation: Relation, callback: @escaping ([Chat]) -> Void) {
        SocketRequest(name: "get_directmsg_contacts", payload: .object([
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "relation": .string(relation.rawValue),
            "limit": 100
        ]))
        .publisher()
        .map { $0.processChats() }
        .receive(on: DispatchQueue.main)
        .sink { result in
            callback(result)
        }
        .store(in: &cancellables)
    }
    
    func getRecentChats(_ relation: Relation, until: Int? = nil, callback: @escaping ([Chat]) -> Void) {
        var payload: [String: JSON] = [
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "relation": .string(relation.rawValue),
            "limit": until == nil ? 20 : 40
        ]
        
        if let until {
            payload["until"] = .number(Double(until))
        }
        
        SocketRequest(name: "get_directmsg_contacts", payload: .object(payload)).publisher()
            .map { $0.processChats() }
            .receive(on: DispatchQueue.main)
            .sink { result in
                callback(result)
            }
            .store(in: &cancellables)
    }
    
    func getChatMessagesHistory(pubkey: String, until: Double, _ callback: @escaping ([ProcessedMessage]) -> Void) {
        SocketRequest(name: "get_directmsgs", payload: .object([
            "limit": .number(20),
            "until": .number(until),
            "receiver": .string(pubkey),
            "sender": .string(IdentityManager.instance.userHexPubkey)
        ])).publisher()
        .map { $0.processMessages()}
        .receive(on: DispatchQueue.main)
        .sink { result in
            callback(result)
        }
        .store(in: &cancellables)
    }
    
    func getChatMessages(pubkey: String, since: Double = 0, _ callback: @escaping ([ProcessedMessage]) -> Void) {
        SocketRequest(name: "get_directmsgs", payload: .object([
            "limit": .number(20),
            "since": .number(since),
            "receiver": .string(pubkey),
            "sender": .string(IdentityManager.instance.userHexPubkey)
        ])).publisher()
        .map { $0.processMessages()}
        .receive(on: DispatchQueue.main)
        .sink { result in
            callback(result)
        }
        .store(in: &cancellables)
    }
    
    func updateChatCount() {
        Connection.regular.isConnectedPublisher.filter { $0 }.sink { [weak self] _ in
            self?.continousConnection = Connection.regular.requestCacheContinous(name: "directmsg_count", request: .object([
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
