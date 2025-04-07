//
//  PostCellEvent.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.5.24..
//

import Foundation

enum PostCellEvent {
    case url(URL?)
    case images(MediaMetadata.Resource)
    case embeddedImages(MediaMetadata.Resource)
    case profile
    case post
    case like
    case zap
    case longTapZap
    case repost
    case reply
    case embeddedPost
    case repostedProfile
    case article
    
    case articleTag(String)
    
    case payInvoice
    
    case zapDetails
    case likeDetails
    case repostDetails
    
    case share
    case copy(NoteCopiableProperty)
    case broadcast
    case report
    case mute
    case bookmark
    case unbookmark
}

enum NoteCopiableProperty {
    case link
    case content
    case rawData
    case noteID
    case userPubkey
    case invoice
}

extension ParsedContent {
    func propertyText(_ property: NoteCopiableProperty) -> String? {
        switch property {
        case .link:         return webURL()
        case .content:      return attributedText.string
        case .rawData:      return post.rawData ?? post.encodeToString()
        case .noteID:       return noteId(extended: true)
        case .userPubkey:   return user.data.pubkey
        case .invoice:      return invoice?.1
        }
    }
}
