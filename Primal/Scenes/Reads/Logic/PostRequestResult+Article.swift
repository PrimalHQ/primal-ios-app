//
//  PostRequestResult+Article.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.7.24..
//

import Foundation

class Article: Hashable {
    let title: String
    let image: String?
    let summary: String?
    let words: Int?
    
    let identifier: String
    
    var zaps: [ParsedZap]
    
    var replies: [ParsedContent]
    
    var stats: NostrContentStats
    
    let event: NostrContent
    let user: ParsedUser
    
    var mentions: [ParsedContent] = []
    var mentionedUsers: [ParsedUser] = []
    
    init(
        id: String,
        title: String,
        image: String? = nil,
        summary: String? = nil,
        words: Int? = nil,
        zaps: [ParsedZap] = [],
        replies: [ParsedContent] = [],
        stats: NostrContentStats? = nil,
        event: NostrContent,
        user: ParsedUser
    ) {
        identifier = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.image = image
        self.summary = summary
        self.words = words
        self.zaps = zaps
        self.replies = replies
        self.stats = stats ?? .empty(id)
        self.event = event
        self.user = user
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(user)
        hasher.combine(identifier)
        hasher.combine(event)
    }
}

class Highlight {
    var content: String { event.content }
    let user: ParsedUser
    let event: NostrContent
    
    init(user: ParsedUser, event: NostrContent) {
        self.user = user
        self.event = event
    }
}

struct PrimalFeed: Codable {
    var name: String
    var spec: String
    var description: String = ""
    var feedkind: String = ""
    var enabled: Bool = true
}

extension PostRequestResult {
    var readFeeds: [PrimalFeed] {
        guard let event = events.first(where: {
            Int($0["kind"]?.doubleValue ?? 0) == NostrKind.feedsSettings.rawValue
        }) else { return [] }
        
        return event["content"]?.stringValue?.decode() ?? []
    }
}

extension PostRequestResult {
    func getArticles() -> [Article] {
        let posts = process(contentStyle: .threadChildren)
        
        let mentions: [ParsedContent] = NoteProcessor(result: self, contentStyle: .embedded).secondLevelMentions
        
        let parsedUsers = getSortedUsers()
        
        return longFormPosts.sorted(by: { $0.event.created_at > $1.event.created_at }).compactMap { post -> Article? in
            guard let id = post.event.tags.first(where: { $0.first == "d" })?[safe: 1] else { return nil }
            
            let aTag = "\(NostrKind.longForm.rawValue):\(post.event.pubkey):\(id)"
            
            let longForm  = Article(
                id: id,
                title: post.title ?? "",
                image: post.image,
                summary: post.summary,
                words: longFormWordCount[post.event.id],
                zaps: postZaps.compactMap { primalZapEvent -> ParsedZap? in
                    guard
                        primalZapEvent.event_id == post.event.id,
                        let user = users[primalZapEvent.sender]
                    else { return nil }
                    
                    return ParsedZap(
                        receiptId: primalZapEvent.zap_receipt_id,
                        postId: primalZapEvent.event_id,
                        amountSats: primalZapEvent.amount_sats,
                        message: zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
                        createdAt: primalZapEvent.created_at,
                        user: createParsedUser(user)
                    )
                },
                replies: posts.compactMap({
                    if $0.replyingTo?.post.id == post.event.id {
                        return $0
                    }
                    if $0.post.tags.contains(where: { tags in tags.first == "a" && tags.dropFirst().first == aTag}) {
                        return $0
                    }
                    return nil
                }),
                stats: stats[post.event.id] ?? .empty(post.event.id),
                event: post.event,
                user: createParsedUser(users[post.event.pubkey] ?? PrimalUser(pubkey: post.event.pubkey))
            )
            
            longForm.mentionedUsers = parsedUsers
            longForm.mentions = mentions
            
            return longForm
        }
    }
    
    func getHighlights() -> [Highlight] {
        return highlights.map { obj in .init(
            user: createParsedUser(users[obj.pubkey] ?? .init(pubkey: obj.pubkey)),
            event: obj
        ) }
    }
    
    func getHighlightComments() -> [String: [ParsedContent]] {
        return process(contentStyle: .threadChildren).reduce(into: [:]) { partialResult, comment in
            guard let content = comment.replyingTo?.post.content else { return }

            partialResult[content] = partialResult[content, default: []] + [comment]
        }
    }
}
