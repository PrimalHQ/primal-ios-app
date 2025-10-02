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
    
    static func articleZaps(identifier: String, pubkey: String, limit: Int) -> SocketRequest {
        .init(useHTTP: true, name: "event_zaps_by_satszapped", payload: .object([
            "identifier": .string(identifier),
            "pubkey": .string(pubkey),
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
    enum Kind {
        case note(String)
        case article(String, pubkey: String)
    }
    
    init(noteId: String, limit: Int) {
        self.kind = .note(noteId)
        self.limit = limit
    }
    
    init(articleId: String, pubkey: String, limit: Int) {
        self.kind = .article(articleId, pubkey: pubkey)
        self.limit = limit
    }
    
    let kind: Kind
    var limit: Int = 11
    
    func publisher() -> AnyPublisher<[ParsedZap], Never> {
        let request: SocketRequest
        let noteId: String
        switch kind {
        case .note(let id):
            request = .eventZaps(noteId: id, limit: limit)
            noteId = id
        case .article(let articleId, let pubkey):
            request = .articleZaps(identifier: articleId, pubkey: pubkey, limit: limit)
            noteId = "\(NostrKind.longForm.rawValue):\(pubkey):\(articleId)"
        }
        
        return request.publisher()
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
