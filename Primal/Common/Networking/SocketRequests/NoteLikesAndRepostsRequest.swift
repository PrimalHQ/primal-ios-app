//
//  NoteLikesAndRepostsRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.4.24..
//

import Foundation
import Combine

extension SocketRequest {
    static func eventLikes(noteId: String, limit: Int) -> SocketRequest {
        .init(name: "event_actions", payload: .object([
            "event_id": .string(noteId),
            "kind": .number(7),
            "limit": .number(Double(limit))
        ]))
    }
    
    static func articleLikes(identifier: String, pubkey: String, limit: Int) -> SocketRequest {
        .init(name: "event_actions", payload: .object([
            "identifier": .string(identifier),
            "pubkey": .string(pubkey),
            "kind": .number(7),
            "limit": .number(Double(limit))
        ]))
    }
    
    static func eventReposts(noteId: String, limit: Int) -> SocketRequest {
        .init(name: "event_actions", payload: .object([
            "event_id": .string(noteId),
            "kind": .number(6),
            "limit": .number(Double(limit))
        ]))
    }
    
    static func articleReposts(identifier: String, pubkey: String, limit: Int) -> SocketRequest {
        .init(name: "event_actions", payload: .object([
            "identifier": .string(identifier),
            "pubkey": .string(pubkey),
            "kind": .number(6),
            "limit": .number(Double(limit))
        ]))
    }
}

struct NoteLikesRequest {
    enum Kind {
        case note(String)
        case article(String, pubkey: String)
    }
    
    init(noteId: String, limit: Int = 200) {
        self.kind = .note(noteId)
        self.limit = limit
    }
    
    init(articleId: String, pubkey: String, limit: Int = 200) {
        self.kind = .article(articleId, pubkey: pubkey)
        self.limit = limit
    }
    
    let kind: Kind
    var limit: Int = 200
    
    func publisher() -> AnyPublisher<[ParsedUser], Never> {
        let request: SocketRequest
        switch kind {
        case .note(let id):
            request = .eventLikes(noteId: id, limit: limit)
        case .article(let articleId, let pubkey):
            request = .articleLikes(identifier: articleId, pubkey: pubkey, limit: limit)
        }
        
        return request.publisher()
            .map { $0.getSortedUsers() }
            .eraseToAnyPublisher()
    }
}

struct NoteRepostsRequest {
    enum Kind {
        case note(String)
        case article(String, pubkey: String)
    }
    
    init(noteId: String, limit: Int = 200) {
        self.kind = .note(noteId)
        self.limit = limit
    }
    
    init(articleId: String, pubkey: String, limit: Int = 200) {
        self.kind = .article(articleId, pubkey: pubkey)
        self.limit = limit
    }
    
    let kind: Kind
    var limit: Int = 200
    
    func publisher() -> AnyPublisher<[ParsedUser], Never> {
        let request: SocketRequest
        let noteId: String
        switch kind {
        case .note(let id):
            request = .eventReposts(noteId: id, limit: limit)
        case .article(let articleId, let pubkey):
            request = .articleReposts(identifier: articleId, pubkey: pubkey, limit: limit)
        }
        
        return request.publisher()
            .map { $0.getSortedUsers() }
            .eraseToAnyPublisher()
    }
}
