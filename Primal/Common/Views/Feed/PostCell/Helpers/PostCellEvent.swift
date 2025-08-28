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
    case live
    
    case articleTag(String)
    
    case payInvoice
    
    case zapDetails
    case likeDetails
    case repostDetails
    
    case share
    case shareAsImage
    case copy(NoteCopiableProperty)
    case report
    case muteUser
    case toggleMutePost
    case bookmark
    case unbookmark
    case requestDelete
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
        case .content:      return post.content
        case .rawData:      return post.rawData ?? post.encodeToString()
        case .noteID:       return "nostr:" + noteId(extended: true)
        case .userPubkey:   return user.data.pubkey
        case .invoice:      return invoice?.string
        }
    }
}
