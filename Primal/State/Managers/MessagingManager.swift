//
//  MessagingManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.9.23..
//

import Combine
import Foundation

final class MessagingManager {
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        getRecentMessages()
    }
    
    func getRecentMessages(){
        Connection.instance.$isConnected.filter { $0 }
            .first()
            .flatMap({ _ in
                SocketRequest(name: "get_directmsg_contacts", payload: .object([
                    "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
                ])).publisher()
            })
            .sink { result in
                print(result)
                print(result)
            }
            .store(in: &cancellables)
    }
}
