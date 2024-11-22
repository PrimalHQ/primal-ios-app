//
//  DatabaseManager+NoteDraft.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.10.24..
//

import Combine
import GRDB

extension DatabaseManager {
    func getCompletedDrafts(userPubkey: String) -> AnyPublisher<[NoteDraft], Never> {
        ValueObservation.tracking { db in
            try NoteDraft.all().completed(userPubkey: userPubkey).fetchAll(db)
        }
        .publisher(in: dbWriter)
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
    
    func findDraft(replyingTo: String?) -> AnyPublisher<NoteDraft?, Never> {
        let userPubkey = IdentityManager.instance.userHexPubkey
        return dbWriter.readPublisher { db in
            try NoteDraft.all().findDraft(userPubkey: userPubkey, replyingTo).fetchOne(db)
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }
    
    func saveDraft(_ draft: NoteDraft) {
        performUpdates { db in
            var draft = draft
            try draft.save(db)
        }
    }
    
    func deleteDraft(replyingTo: String?) {
        let userPubkey = IdentityManager.instance.userHexPubkey
        performUpdates { db in
            try NoteDraft.all().findDraft(userPubkey: userPubkey, replyingTo).deleteAll(db)
        }
    }
    
    func deleteDraft(_ draft: NoteDraft) {
        performUpdates { db in
            try draft.delete(db)
        }
    }
}
