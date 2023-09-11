//
//  ProcessingMessages.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.9.23..
//

import Foundation

struct ProcessedMessage {
    var user: ParsedUser
    var date: Date
    var message: String
}

struct Chat {
    var user: ParsedUser
    var newMessagesCount: Int
    
    var latest: ProcessedMessage
}

extension PostRequestResult {
    func processChats() -> [Chat] {
        guard
            let loginInfo = ICloudKeychainManager.instance.getLoginInfo()?.hexVariant,
            let privkey = loginInfo.privkey,
            !chatsMetadata.isEmpty
        else { return [] }
        
        return chatsMetadata.compactMap { pubkey, info -> Chat? in
            guard
                let user = users[pubkey],
                let latest = encryptedMessages.first(where: { $0.id == info.latest_event_id }),
                let messageUser = users[latest.pubkey]
            else { return nil }
            
            let parsed = createParsedUser(user)

            return .init(
                user: parsed,
                newMessagesCount: info.cnt,
                latest: .init(
                    user: latest.pubkey == pubkey ? parsed : createParsedUser(messageUser),
                    date: latest.date,
                    message: decryptDirectMessage(latest.message, privkey: privkey, pubkey: latest.pubkey == pubkey ? pubkey : latest.recipientPubkey) ?? ""
                )
            )
        }
        .sorted(by: { $0.latest.date > $1.latest.date })
    }
    
    func processMessages() -> [ProcessedMessage] {
        guard
            let loginInfo = ICloudKeychainManager.instance.getLoginInfo()?.hexVariant,
            let privkey = loginInfo.privkey
        else { return [] }
        
        return encryptedMessages.compactMap {
            guard let user = users[$0.pubkey] else { return nil }
            
            return .init(
                user: createParsedUser(user),
                date: $0.date,
                message: decryptDirectMessage($0.message, privkey: privkey, pubkey: $0.pubkey == loginInfo.pubkey ? $0.recipientPubkey : $0.pubkey) ?? ""
            )
        }
        .sorted { $0.date > $1.date }
    }
}
