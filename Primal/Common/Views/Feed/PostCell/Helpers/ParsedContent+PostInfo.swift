//
//  ParsedContent+NoteInfo.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.5.24..
//

struct PostInfo {
    var isBookmarked: Bool
    var isLiked: Bool
    var isMuted: Bool
    var isReplied: Bool
    var isReposted: Bool
    var isZapped: Bool
}

extension PrimalFeedPost {
    var universalID: String {
        guard
            kind == NostrKind.longForm.rawValue,
            let tagId = tags.first(where: { $0.first == "d" })?[safe: 1]
        else { return id }
        
        return "\(NostrKind.longForm.rawValue):\(pubkey):\(tagId)"
    }
    
    var referenceTagLetter: String {
        kind == NostrKind.longForm.rawValue ? "a" : "e"
    }
}

extension ParsedContent {
    var postInfo: PostInfo {
        .init(
            isBookmarked: BookmarkManager.instance.isBookmarked(self),
            isLiked: PostingManager.instance.hasLiked(post.universalID),
            isMuted: MuteManager.instance.isMuted(user.data.pubkey),
            isReplied: PostingManager.instance.hasReplied(post.universalID),
            isReposted: PostingManager.instance.hasReposted(post.universalID),
            isZapped: WalletManager.instance.hasZapped(post.universalID)
        )
    }
}
