//
//  Notification.swift
//  Primal
//
//  Created by Pavle D Stevanović on 27.6.23..
//

import Foundation
import GenericJSON

enum NotificationType: Int, CaseIterable {
    case NEW_USER_FOLLOWED_YOU = 1
    case USER_UNFOLLOWED_YOU = 2
    
    case YOUR_POST_WAS_ZAPPED = 3
    case YOUR_POST_WAS_LIKED = 4
    case YOUR_POST_WAS_REPOSTED = 5
    case YOUR_POST_WAS_REPLIED_TO = 6
    case YOU_WERE_MENTIONED_IN_POST = 7
    case YOUR_POST_WAS_MENTIONED_IN_POST = 8
    
    case POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED = 101
    case POST_YOU_WERE_MENTIONED_IN_WAS_LIKED = 102
    case POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED = 103
    case POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO = 104
    
    case POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED = 201
    case POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED = 202
    case POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED = 203
    case POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO = 204
}

struct PrimalNotification {
    var date: Date
    var type: NotificationType
    var data: NostrNotification
    
    static func fromJSON(_ json: JSON) -> PrimalNotification? {
        guard
            let object = json.objectValue,
            let created_at = object["created_at"]?.doubleValue,
            let typeD = object["type"]?.doubleValue,
            let type = NotificationType(rawValue: Int(typeD)),
            let data = NostrNotification.fromJSON(object, kind: type)
        else { return nil }

        return .init(date: .init(timeIntervalSince1970: TimeInterval(created_at)), type: type, data: data)
    }
}

enum NostrNotification {
    case userFollowed(userId: String)
    case userUnfollowed(userId: String)
    
    case postZapped(postId: String, userId: String, amount: Int)
    case postLiked(postId: String, userId: String)
    case postReposted(postId: String, userId: String)
    case postReplied(postId: String, userId: String, reply: String)
    
    case userMention(postId: String)
    case postMention(postId: String, myPostId: String)
    
    case userMentionZapped(postId: String, userId: String, amount: Int)
    case userMentionLiked(postId: String, userId: String)
    case userMentionReposted(postId: String, userId: String)
    case userMentionReplied(postId: String, userId: String, reply: String)
    
    case postMentionZapped(postId: String, userId: String, amount: Int)
    case postMentionLiked(postId: String, userId: String)
    case postMentionReposted(postId: String, userId: String)
    case postMentionReplied(postId: String, userId: String, reply: String)
    
    static func fromJSON(_ object: [String: JSON], kind: NotificationType) -> NostrNotification? {
        switch kind {
        case .NEW_USER_FOLLOWED_YOU:
            guard let follower = object["follower"]?.stringValue else { return nil }
            return .userFollowed(userId: follower)
        case .USER_UNFOLLOWED_YOU:
            guard let follower = object["follower"]?.stringValue else { return nil }
            return .userUnfollowed(userId: follower)
        case .YOUR_POST_WAS_ZAPPED:
            guard
                let your_post = object["your_post"]?.stringValue,
                let who_zapped_it = object["who_zapped_it"]?.stringValue,
                let satszapped = object["satszapped"]?.doubleValue
            else { return nil }
            return .postZapped(postId: your_post, userId: who_zapped_it, amount: Int(satszapped))
        case .YOUR_POST_WAS_LIKED:
            guard
                let your_post = object["your_post"]?.stringValue,
                let who_liked_it = object["who_liked_it"]?.stringValue
            else { return nil }
            return .postLiked(postId: your_post, userId: who_liked_it)
        case .YOUR_POST_WAS_REPOSTED:
            guard
                let your_post = object["your_post"]?.stringValue,
                let who_reposted_it = object["who_reposted_it"]?.stringValue
            else { return nil }
            return .postReposted(postId: your_post, userId: who_reposted_it)
        case .YOUR_POST_WAS_REPLIED_TO:
            guard
                let your_post = object["your_post"]?.stringValue,
                let who_replied_to_it = object["who_replied_to_it"]?.stringValue,
                let reply = object["reply"]?.stringValue
            else { return nil }
            return .postReplied(postId: your_post, userId: who_replied_to_it, reply: reply)
        case .YOU_WERE_MENTIONED_IN_POST:
            guard let you_were_mentioned_in = object["you_were_mentioned_in"]?.stringValue else { return nil }
            return .userMention(postId: you_were_mentioned_in)
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            guard
                let your_post = object["your_post"]?.stringValue,
                let your_post_were_mentioned_in = object["your_post_were_mentioned_in"]?.stringValue
            else { return nil }
            return .postMention(postId: your_post_were_mentioned_in, myPostId: your_post)
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            guard
                let post_you_were_mentioned_in = object["post_you_were_mentioned_in"]?.stringValue,
                let who_zapped_it = object["who_zapped_it"]?.stringValue,
                let satszapped = object["satszapped"]?.doubleValue
            else { return nil }
            return .userMentionZapped(postId: post_you_were_mentioned_in, userId: who_zapped_it, amount: Int(satszapped))
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            guard
                let post_you_were_mentioned_in = object["post_you_were_mentioned_in"]?.stringValue,
                let who_liked_it = object["who_liked_it"]?.stringValue
            else { return nil }
            return .postMentionLiked(postId: post_you_were_mentioned_in, userId: who_liked_it)
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            guard
                let post_you_were_mentioned_in = object["post_you_were_mentioned_in"]?.stringValue,
                let who_reposted_it = object["who_reposted_it"]?.stringValue
            else { return nil }
            return .postMentionReposted(postId: post_you_were_mentioned_in, userId: who_reposted_it)
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            guard
                let post_you_were_mentioned_in = object["post_you_were_mentioned_in"]?.stringValue,
                let who_replied_to_it = object["who_replied_to_it"]?.stringValue,
                let reply = object["reply"]?.stringValue
            else { return nil }
            return .postMentionReplied(postId: post_you_were_mentioned_in, userId: who_replied_to_it, reply: reply)
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            guard
                let post_your_post_was_mentioned_in = object["post_your_post_was_mentioned_in"]?.stringValue,
                let who_zapped_it = object["who_zapped_it"]?.stringValue,
                let satszapped = object["satszapped"]?.doubleValue
            else { return nil }
            return .postMentionZapped(postId: post_your_post_was_mentioned_in, userId: who_zapped_it, amount: Int(satszapped))
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            guard
                let post_your_post_was_mentioned_in = object["post_your_post_was_mentioned_in"]?.stringValue,
                let who_liked_it = object["who_liked_it"]?.stringValue
            else { return nil }
            return .postMentionLiked(postId: post_your_post_was_mentioned_in, userId: who_liked_it)
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            guard
                let post_your_post_was_mentioned_in = object["post_your_post_was_mentioned_in"]?.stringValue,
                let who_reposted_it = object["who_reposted_it"]?.stringValue
            else { return nil }
            return .postReposted(postId: post_your_post_was_mentioned_in, userId: who_reposted_it)
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            guard
                let post_your_post_was_mentioned_in = object["post_your_post_was_mentioned_in"]?.stringValue,
                let who_replied_to_it = object["who_replied_to_it"]?.stringValue,
                let reply = object["reply"]?.stringValue
            else { return nil }
            return .postReplied(postId: post_your_post_was_mentioned_in, userId: who_replied_to_it, reply: reply)
        }
    }
}

extension NostrNotification {
    var mainUserId: String? {
        switch self {
        case .userFollowed(let userId), .userUnfollowed(let userId), .postZapped(_, let userId, _), .postLiked(_, let userId), .postReposted(_, let userId), .postReplied(_, let userId, _), .userMentionZapped(_, let userId, _), .userMentionLiked(_, let userId), .userMentionReposted(_, let userId), .userMentionReplied(_, let userId, _), .postMentionZapped(_, let userId, _), .postMentionLiked(_, let userId), .postMentionReposted(_, let userId), .postMentionReplied(_, let userId, _):
            
            return userId
        case .postMention, .userMention:
            return nil
        }
    }
    
    var mainPostId: String? {
        switch self {
        case    .postZapped(let postId, _, _),
                .postLiked(let postId, _),
                .postReposted(let postId, _),
                .userMention(let postId),
                .postMention(let postId, _),
                .userMentionZapped(let postId, _, _),
                .userMentionLiked(let postId, _),
                .userMentionReposted(let postId, _),
                .postMentionZapped(let postId, _, _),
                .postMentionLiked(let postId, _),
                .postMentionReposted(let postId, _):
            
            return postId
            
        case    .userMentionReplied(_, _, reply: let reply),
                .postReplied(_, _, reply: let reply),
                .postMentionReplied(_, _, reply: let reply):
            
            return reply
        case    .userFollowed(_),
                .userUnfollowed(_):
            
            return nil
        }
    }
}
