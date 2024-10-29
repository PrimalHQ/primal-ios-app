//
//  NoteDraft.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.10.24..
//

import GRDB

struct DatabaseRange: Codable, Equatable {
    var location: Int
    var length: Int
}

struct DatabaseUserToken: Codable, Equatable {
    var range: DatabaseRange
    var text: String
    var userPubkey: String
}

struct NoteDraft: Identifiable, Equatable {
    var id: String { userPubkey + replyingTo }
    
    var replyingTo: String
    var userPubkey: String
    
    var preparedEvent: NostrObject?
    
    var text: String
    var uploadedAssets: [String]
    var taggedUsers: [DatabaseUserToken]
}

extension NoteDraft {
    
}

extension NoteDraft: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    enum Columns {
        static let replyingTo = Column(CodingKeys.replyingTo)
        static let userPubkey = Column(CodingKeys.userPubkey)
        static let preparedEvent = Column(CodingKeys.preparedEvent)
        static let text = Column(CodingKeys.text)
        static let uploadedAssets = Column(CodingKeys.uploadedAssets)
        static let taggedUsers = Column(CodingKeys.taggedUsers)
    }
    
    static let profile = belongsTo(Profile.self)
    
    init(row: Row) {
        replyingTo = row[Columns.replyingTo]
        // Use default values if columns are NULL
        userPubkey = row[Columns.userPubkey] ?? ""
        text = row[Columns.text] ?? ""
        
        if let preparedEventString: String = row[Columns.preparedEvent] {
            preparedEvent = preparedEventString.decode()
        }
        
        if let assetString: String = row[Columns.uploadedAssets] {
            uploadedAssets = assetString.decode() ?? []
        } else {
            uploadedAssets = []
        }
        
        if let taggedString: String = row[Columns.taggedUsers] {
            taggedUsers = taggedString.decode() ?? []
        } else {
            taggedUsers = []
        }
    }
}

extension DerivableRequest<NoteDraft> {
    func completed(userPubkey: String) -> Self {
        filter(
            NoteDraft.Columns.preparedEvent != nil &&
            NoteDraft.Columns.userPubkey == userPubkey
        )
    }
    
    func findDraft(userPubkey: String, _ replyingTo: String?) -> Self {
        filter(
            NoteDraft.Columns.replyingTo == (replyingTo ?? "") &&
            NoteDraft.Columns.userPubkey == userPubkey
        )
    }
}
