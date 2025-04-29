//
//  ProcessingMessages.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.9.23..
//

import Foundation

enum MessageStatus: String {
    case sent
    case sending
    case failed
}

enum MessageContent {
    case text(String)
    case invoice(Invoice)
    
    var text: String {
        switch self {
        case .text(let string):
            return string
        case .invoice(let invoice):
            return invoice.string
        }
    }
}

struct ProcessedMessage {
    var id: String
    var user: ParsedUser
    var date: Date
    var message: MessageContent
    var status: MessageStatus
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
                let latest = encryptedMessages.first(where: { $0.id == info.latest_event_id })
            else { return nil }
            
            let messageUser = users[latest.pubkey] ?? .init(pubkey: latest.pubkey)
            
            let parsed = createParsedUser(user)

            return .init(
                user: parsed,
                newMessagesCount: info.cnt,
                latest: .init(
                    id: latest.id,
                    user: latest.pubkey == pubkey ? parsed : createParsedUser(messageUser),
                    date: latest.date,
                    message: .text(decryptDirectMessage(latest.message, privkey: privkey, pubkey: latest.pubkey == pubkey ? pubkey : latest.recipientPubkey) ?? ""),
                    status: .sent
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
        
        return encryptedMessages.flatMap { encMessage -> [ProcessedMessage] in
            guard let user = users[encMessage.pubkey] else { return [] }
            
            var message = decryptDirectMessage(encMessage.message, privkey: privkey, pubkey: encMessage.pubkey == loginInfo.pubkey ? encMessage.recipientPubkey : encMessage.pubkey) ?? ""
            
            let invoices = message.extractInvoices()
            
            for invoice in invoices {
                message = message.replacingOccurrences(of: invoice.string, with: "")
            }
            
            message = message.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var result: [ProcessedMessage] = invoices.map { 
                .init(
                    id: encMessage.id,
                    user: createParsedUser(user),
                    date: encMessage.date,
                    message: .invoice($0),
                    status: .sent
                )
            }
            
            if !message.isEmpty {
                result.insert(
                    .init(
                        id: encMessage.id,
                        user: createParsedUser(user),
                        date: encMessage.date,
                        message: .text(message),
                        status: .sent
                    ), 
                    at: 0
                )
            }
            
            return result
        }
        .sorted { $0.date < $1.date }
    }
}

struct NewInvoice {
    let amount: Int
    let string: String
    let expiry: UInt64
    let payment_hash: Data
    let created_at: UInt64
}

extension String {
    func extractInvoices() -> [Invoice] {
        var invoices: [Invoice] = []
        let text = self
        if let invoiceMentionRegex = try? NSRegularExpression(pattern: .lightningInvoicePattern, options: []) {
            invoiceMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                if let invoice = mentionText.invoiceFromString() {
                    invoices.append(invoice)
                }
            }
        }
        
        return invoices
    }
}
