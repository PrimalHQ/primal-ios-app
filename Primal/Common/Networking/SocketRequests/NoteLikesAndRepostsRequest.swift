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
    
    static func eventReposts(noteId: String, limit: Int) -> SocketRequest {
        .init(name: "event_actions", payload: .object([
            "event_id": .string(noteId),
            "kind": .number(6),
            "limit": .number(Double(limit))
        ]))
    }
}

struct NoteLikesRequest {
    let noteId: String
    var limit: Int = 200
    
    func publisher() -> AnyPublisher<[ParsedUser], Never> {
        SocketRequest.eventLikes(noteId: noteId, limit: limit).publisher()
            .map { $0.getSortedUsers() }
            .eraseToAnyPublisher()
    }
}

struct NoteRepostsRequest {
    let noteId: String
    var limit: Int = 200
    
    func publisher() -> AnyPublisher<[ParsedUser], Never> {
        SocketRequest.eventReposts(noteId: noteId, limit: limit).publisher()
            .map { $0.getSortedUsers() }
            .eraseToAnyPublisher()
    }
}
