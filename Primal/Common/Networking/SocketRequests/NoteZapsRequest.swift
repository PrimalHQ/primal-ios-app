//
//  NoteZapsRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.4.24..
//

import Foundation
import Combine

extension SocketRequest {
    static func eventZaps(noteId: String, limit: Int) -> SocketRequest {
        .init(useHTTP: true, name: "event_zaps_by_satszapped", payload: .object([
            "event_id": .string(noteId),
            "limit": .number(Double(limit)),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ]))
    }
    
    static func userInfo(pubkeys: [String]) -> SocketRequest {
        .init(name: "user_infos", payload: .object([
            "pubkeys": .array(pubkeys.map { .string($0) })
        ]))
    }
}

struct ParsedZap: Hashable {
    let receiptId: String
    let postId: String
    let amountSats: Int
    let message: String
    let createdAt: Double
    let user: ParsedUser
}

struct NoteZapsRequest {
    let noteId: String
    var limit: Int = 11
    
    func publisher() -> AnyPublisher<[ParsedZap], Never> {
        SocketRequest.eventZaps(noteId: noteId, limit: limit).publisher()
            .flatMap { result in
                Publishers.Zip(Just(result), SocketRequest.userInfo(pubkeys: result.postZaps.map { $0.sender }).publisher())
            }
            .map { (resultZaps, resultUsers) in
                let users = resultUsers.getSortedUsers()
                
                return resultZaps.postZaps.map { primalZapEvent in
                    ParsedZap(
                        receiptId: primalZapEvent.zap_receipt_id,
                        postId: noteId,
                        amountSats: primalZapEvent.amount_sats,
                        message: resultZaps.zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
                        createdAt: primalZapEvent.created_at,
                        user: users.first(where: { $0.data.pubkey == primalZapEvent.sender }) ?? ParsedUser(data: .init(pubkey: primalZapEvent.sender))
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
