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

/*
 ["REQ","msg_reset_ 363917480",
 
 {"cache":["reset_directmsg_count",{"event_from_user":{"content":"{ \"description\": \"reset messages from '88cc134b1a65f54ef48acc1df3665063d3ea45f04eab8af4646e561c5ae99079'\"}","kind":30078,"tags":[["d","Primal-Web App"]],"created_at":1695729580,"pubkey":"dd9b989dfe5e0840a92538f3e9f84f674e5f17ab05932efbacb4d8e6c905f302","id":"282a7832a7d2116066c14a33906fb693b15fd955162260954b5644b9619ae3cc","sig":"f26167e2d49d5adbfb96e250e48a8f924237c0b4581676238d9a5a73f36db53c0fd7a32354eefce7449d2cdc2e0f348730e1f3af24b6c6e48993b9d8db798e0f"},"sender":"88cc134b1a65f54ef48acc1df3665063d3ea45f04eab8af4646e561c5ae99079"}]}]


 */
