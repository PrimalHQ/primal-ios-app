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
