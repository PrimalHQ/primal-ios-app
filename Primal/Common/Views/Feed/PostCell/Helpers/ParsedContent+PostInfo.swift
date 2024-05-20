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
            isBookmarked: BookmarkManager.instance.isBookmarked(post.id),
            isLiked: LikeManager.instance.hasLiked(post.id),
            isMuted: MuteManager.instance.isMuted(user.data.pubkey),
            isReplied: PostManager.instance.hasReplied(post.id),
            isReposted: PostManager.instance.hasReposted(post.id),
            isZapped: WalletManager.instance.hasZapped(post.id)
        )
    }
}
