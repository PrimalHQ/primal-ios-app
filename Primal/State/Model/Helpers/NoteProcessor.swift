//
//  ProcessingNotes.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.11.24..
//

import Foundation
import NostrSDK
import GenericJSON

public extension String {
    static let lightningInvoicePattern = "(?i)lnbc[a-z0-9]{40,}"
    static let articleMentionPattern = "(?<!\\S)(nostr:|(https://)?(www.)?njump.me/)?naddr1\\w+\\b|#\\[(\\d+)\\]"
    static let noteMentionPattern = "\\b(((https://)?(primal.net/e/|njump.me/))|nostr:|@)?((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
    static let nip08MentionPattern = "\\#\\[([0-9]*)\\]"
    static let nip27MentionPattern = "\\b(((https://)?primal.net/p/)|nostr:)?((npub|nprofile)1\\w+)\\b"
}

class NoteProcessor: MetadataCoding {
    
    typealias ProcessingHighlight = (reference: String, replacement: String, highlight: ParsedContent)
    
    let response: PostRequestResult
    let contentStyle: ParsedContentTextStyle
    init(result: PostRequestResult, contentStyle: ParsedContentTextStyle) {
        self.response = result
        self.contentStyle = contentStyle
    }
    
    private lazy var parsedMentions = response.mentions.compactMap { response.createPrimalPost(content: $0) }
    
    lazy var secondLevelMentions: [ParsedContent] = parsedMentions.map { parse(post: $0.0, user: $0.1, mentions: []) }

    lazy var mentions: [ParsedContent] = parsedMentions.map { parse(post: $0.0, user: $0.1, mentions: secondLevelMentions) }

    lazy var parsedUsers: [ParsedUser] = response.getSortedUsers()
    
    lazy var parsedZaps = response.postZaps.uniqueByFilter({ $0.zap_receipt_id }).map { primalZapEvent in
        ParsedZap(
            receiptId: primalZapEvent.zap_receipt_id,
            postId: primalZapEvent.event_id,
            amountSats: primalZapEvent.amount_sats,
            message: response.zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
            createdAt: primalZapEvent.created_at,
            user: parsedUsers.first(where: { $0.data.pubkey == primalZapEvent.sender }) ?? ParsedUser(data: .init(pubkey: primalZapEvent.sender))
        )
    }
    
    lazy var articles: [Article] = response.longFormPosts.compactMap { post -> Article? in
        guard let id = post.event.tags.first(where: { $0.first == "d" })?[safe: 1] else { return nil }
        
        let aTag = "\(NostrKind.longForm.rawValue):\(post.event.pubkey):\(id)"
        
        let longForm  = Article(
            id: id,
            title: post.title ?? "",
            image: post.image,
            summary: post.summary,
            words: response.longFormWordCount[post.event.id],
            zaps: response.postZaps.compactMap { primalZapEvent -> ParsedZap? in
                guard
                    primalZapEvent.event_id == post.event.id,
                    let user = response.users[primalZapEvent.sender]
                else { return nil }
                
                return ParsedZap(
                    receiptId: primalZapEvent.zap_receipt_id,
                    postId: primalZapEvent.event_id,
                    amountSats: primalZapEvent.amount_sats,
                    message: response.zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
                    createdAt: primalZapEvent.created_at,
                    user: response.createParsedUser(user)
                )
            },
            replies: [],
            stats: response.stats[post.event.id] ?? .empty(post.event.id),
            event: post.event,
            user: response.createParsedUser(response.users[post.event.pubkey] ?? PrimalUser(pubkey: post.event.pubkey))
        )
        
        longForm.mentionedUsers = parsedUsers
        longForm.mentions = secondLevelMentions // must be secondLevelMentions to avoid a infinite recursion
        
        return longForm
    }
    
    lazy var parsedFeedZaps: [ParsedFeedZap] = {
        let notes = secondLevelMentions // must be secondLevelMentions to avoid a infinite recursion
        
        let coolZaps: [ParsedFeedZap] = response.postZaps.map({ primalZapEvent in
            let user = parsedUsers.first(where: { $0.data.pubkey == primalZapEvent.sender }) ?? ParsedUser(data: .init(pubkey: primalZapEvent.sender))
            
            let referencedNote: ZappableReferenceObject? = notes.first(where: { $0.zaps.contains(where: { zap in zap.receiptId == primalZapEvent.zap_receipt_id })})
            let referencedArticle: ZappableReferenceObject? = articles.first(where: { $0.zaps.contains { zap in zap.receiptId == primalZapEvent.zap_receipt_id }})
            
            let zappedObject: ZappableReferenceObject = referencedNote ?? referencedArticle ?? user
            
            return ParsedFeedZap(
                zap: ParsedZap(
                    receiptId: primalZapEvent.zap_receipt_id,
                    postId: primalZapEvent.event_id,
                    amountSats: primalZapEvent.amount_sats,
                    message: response.zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
                    createdAt: primalZapEvent.created_at,
                    user: user
                ),
                zappedObject: zappedObject
            )
        })
        
        let uncoolZaps: [ParsedFeedZap] = response.zapReceipts.compactMap({ (id, event) in
            guard
                !coolZaps.contains(where: { $0.zap.receiptId == id }),
                let pubkey = event["pubkey"]?.stringValue
            else { return nil }

            let user = parsedUsers.first(where: { $0.data.pubkey == pubkey }) ?? ParsedUser(data: .init(pubkey: pubkey))
                
            var otherUserPubkey = user.data.pubkey
            var amount: Int = 0
            for tags in event["tags"]?.arrayValue ?? [] {
                guard
                    let tagsArray = tags.arrayValue,
                    let firstValue = tagsArray.first?.stringValue,
                    let secondValue = tagsArray[safe: 1]?.stringValue
                else { continue }

                switch firstValue {
                case "amount":
                    if let tagAmount = Int(secondValue) {
                        amount = tagAmount / 1000
                    }
                case "p":
                    otherUserPubkey = secondValue
                default:
                    break
                }
            }
            
            let otherUser = parsedUsers.first(where: { $0.data.pubkey == otherUserPubkey }) ?? ParsedUser(data: .init(pubkey: pubkey))
            
            let postId: String = event["id"]?.stringValue ?? ""
            let message: String = event["content"]?.stringValue ?? ""
                    
            return ParsedFeedZap(
                zap: ParsedZap(
                    receiptId: id,
                    postId: postId,
                    amountSats: amount,
                    message: message,
                    createdAt: event["created_at"]?.doubleValue ?? 0,
                    user: user
                ),
                zappedObject: otherUser
            )
        })
        
        return coolZaps + uncoolZaps
    }()
    
    lazy var reposts: [ParsedContent] = response.reposts
        .compactMap { repost -> ParsedContent? in
            guard let (primalPost, user) = response.createPrimalPost(content: repost.post) else { return nil }
            
            let post = parse(post: primalPost, user: user, mentions: secondLevelMentions) // Must be second level mentions to avoid a infinite recursion
            
            guard let nostrUser = response.users[repost.pubkey] else { return post }
            
            post.reposted = .init(users: [response.createParsedUser(nostrUser)], date: repost.date, id: repost.id)
            
            return post
        }
    
    func process() -> [ParsedContent] {
        let normalPosts = response.posts.compactMap { response.createPrimalPost(content: $0) }
            .map { parse(post: $0.0, user: $0.1, mentions: mentions) }
        
        if response.order.isEmpty {
            return normalPosts
        }
        
        let all = normalPosts + reposts
        return response.order.compactMap { id in
            all.first(where: { $0.post.id == id }) ?? reposts.first(where: { $0.reposted?.id == id})
        }
    }
    
    func parse(
        post: PrimalFeedPost,
        user: ParsedUser,
        mentions: [ParsedContent]
    ) -> ParsedContent {
        let p = ParsedContent(post: post, user: user)
        
        var text: String = post.content
                
        var imageURLs: [String] = []
        var videoURLS: [String] = []
        var otherURLs: [String] = []
        let textMentions: [String] = text.extractMentions()
        var markedMentions: [(String, ref: String)] = []
        let hashtags: [String] = text.extractHashtags()
        var itemsToRemove: [String] = []
        
        for str in text.extractURLs() {
            if str.isImageURL {
                imageURLs.append(str)
                itemsToRemove.append(str)
            } else if str.isVideoURL {
                videoURLS.append(str)
                itemsToRemove.append(str)
            } else {
                if str.contains("primal.net/e/") || str.contains("primal.net/p/") {
                    continue
                }
                otherURLs.append(str)
            }
        }
        
        for preview in response.webPreviews.first(where: { $0.event_id == post.id })?.resources ?? [] {
            let urlString = preview.url
            guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)") else { continue }
            
            guard preview.md_title?.isEmpty == false || preview.md_description?.isEmpty == false else { continue }
            
            p.linkPreviews.append(LinkMetadata(
                url: url,
                imagesData: response.mediaMetadata.filter { $0.event_id == post.id }.flatMap { $0.resources },
                data: preview
            ))
        }
        
        // MARK: - Finding parent note
        let findReply = { (tag: String) -> ParsedContent? in
            for tagArray in post.tags {
                guard
                    tagArray.count >= 4, tagArray[3] == tag,
                    let parentNote = mentions.first(where: { $0.post.id == tagArray[1] || $0.post.universalID == tagArray[1] })
                else { continue }
                
                return parentNote
            }
            return nil
        }
        
        p.replyingTo = findReply("reply") ?? findReply("root")
        
        // MARK: - Finding and extracting mentioned notes
        var referencedPosts: [(String, ParsedContent)] = []
        var highlights: [ProcessingHighlight] = []
        
        let tmpText = text as NSString
        if let postMentionRegex = try? NSRegularExpression(pattern: .noteMentionPattern, options: []) {
            postMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = tmpText.substring(with: matchRange)
                
                let naventString: String = {
                    if mentionText.hasPrefix("nostr:") { return mentionText.dropFirst(6).string }
                    if mentionText.hasPrefix("@") { return mentionText.dropFirst().string }
                    if mentionText.contains("primal.net/e/") {
                        return String(mentionText.split(separator: "primal.net/e/").last ?? "")
                    }
                    if mentionText.contains("njump.me/") {
                        return String(mentionText.split(separator: "njump.me/").last ?? "")
                    }
                    return mentionText
                }()
                    
                if let mentionId = naventString.eventIdFromNEvent(), let mention = mentions.first(where: { $0.post.id == mentionId }) {
                    extractNote(p: p, post: post, mention: mention, mentionText: mentionText, mentionId: mentionId, highlights: &highlights, itemsToRemove: &itemsToRemove, referencedPosts: &referencedPosts, otherURLs: otherURLs)
                } else {
                    itemsToRemove.append(mentionText)
                    p.notFound = .note
                }
            }
        }
        
        if let articleMentionRegex = try? NSRegularExpression(pattern: .articleMentionPattern, options: []) {
            articleMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard p.article == nil, let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                itemsToRemove.append(mentionText)

                guard
                    let address = mentionText.split(separator: ":").last?.split(separator: "/").last,
                    let metadata = try? decodedMetadata(from: String(address))
                else {
                    p.notFound = .note
                    return
                }
                
                let kind = Int32(metadata.kind ?? 80081337)
            
                guard
                    let id = metadata.identifier,
                    let mention = self.response.mentions.first(where: {
                        ($0.kind == kind) && $0.tags.contains(["d", id])
                    })
                else {
                    if kind == NostrKind.longForm.rawValue {
                        p.notFound = .article
                    } else {
                        p.notFound = .note
                    }
                    return
                }
                
                if kind == NostrKind.live.rawValue, let event: [String: JSON] = mention.encodeToString()?.decode(), let processed = ProcessedLiveEvent.fromEvent(event) {
                    p.embeddedLive = ParsedLiveEvent(event: processed, user: response.createParsedUser(response.users[processed.pubkey] ?? PrimalUser(pubkey: processed.pubkey)))
                } else if kind == NostrKind.longForm.rawValue || kind == NostrKind.shortenedArticle.rawValue {
                    p.article = Article(
                        id: id,
                        title: mention.tags.first(where: { $0.first == "title" })?[safe: 1] ?? "",
                        image: mention.tags.first(where: { $0.first == "image" })?[safe: 1],
                        summary: mention.tags.first(where: { $0.first == "summary" })?[safe: 1],
                        words: nil,
                        zaps: [],
                        replies: [],
                        stats: response.stats[mention.id] ?? .empty(mention.id),
                        event: mention,
                        user: response.createParsedUser(response.users[mention.pubkey] ?? PrimalUser(pubkey: mention.pubkey))
                    )
                } else if let mention = response.createPrimalPost(content: mention) {
                    p.customEvent = .init(post: mention.0, user: mention.1)
                } else {
                    p.notFound = .note
                }
            }
        }
        
        for (mentionText, mention) in referencedPosts {
            p.embeddedPosts.append(mention)
            itemsToRemove.append(mentionText)
        }
        
        for media in response.mediaMetadata where media.event_id == post.id {
            p.mediaResources = media.resources.filter { text.contains($0.url) }
            p.videoThumbnails = media.thumbnails ?? p.videoThumbnails
        }
        
        if p.mediaResources.isEmpty {
            p.mediaResources = imageURLs.map { .init(url: $0, variants: []) }
        }
        
        for string in videoURLS {
            if !p.mediaResources.contains(where: { string.hasPrefix($0.url) }) {
                p.mediaResources.append(.init(url: string, variants: []))
            }
        }
        
        p.mediaResources.sort(by: {
            text.range(of: $0.url)?.lowerBound ?? text.startIndex < text.range(of: $1.url)?.lowerBound ?? text.startIndex
        })
        
        if let invoiceMentionRegex = try? NSRegularExpression(pattern: .lightningInvoicePattern, options: []) {
            invoiceMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard p.invoice == nil, let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                if let invoice = mentionText.invoiceFromString() {
                    p.invoice = invoice
                    itemsToRemove.append(mentionText)
                }
            }
        }
        
        // MARK: - Editing text
        
        for item in itemsToRemove {
            text = text.replacingOccurrences(of: item, with: "")
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Only remove url from text if preview exists, only show preview if url exists
        let allPreviews = p.linkPreviews
        p.linkPreviews = []
        otherURLs = otherURLs.filter { url in
            if let preview = allPreviews.first(where: { $0.url.absoluteString == url }) {
                if !p.linkPreviews.contains(preview) { // Having duplicate identical webpreviews will cause crashes
                    p.linkPreviews.append(preview)
                }
                text = text.replacingOccurrences(of: url, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                return false
            }
            return true
        }
        
        let shortenedUrls: [(String, String)] = otherURLs.map {
            let removedHTTPS = $0.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
            
            if removedHTTPS.count <= 40 {
                text = text.replacingOccurrences(of: $0, with: removedHTTPS)
                return (removedHTTPS, $0)
            }
            
            let newText = removedHTTPS.prefix(30) + "..."
            text = text.replacingOccurrences(of: $0, with: newText)
            return (String(newText), $0)
        }
        
        for (reference, replacement, _) in highlights {
            text = text.replacingOccurrences(of: reference, with: replacement)
        }
        
        // Remove empty lines
        text = text.removingDoubleEmptyLines()
        
        for item in textMentions {
            guard
                let pubkey: String = {
                    if item.isNip08Mention {
                        guard
                            let index = Int(item[safe: 2]?.string ?? ""),
                            let tag = post.tags[safe: index]
                        else { return nil }
                                    
                        return tag[safe: 1]
                    }
                    
                    guard
                        item.isNip27Mention,
                        let mention = item.split(separator: "/").last?.split(separator: ":").last?.string,
                        let pubkey = (try? decodedMetadata(from: mention).pubkey) ?? mention.npubToPubkey()
                    else { return nil }
                    for mentionedPub in response.users.keys {
                        if pubkey.contains(mentionedPub) {
                            return mentionedPub
                        }
                    }
                    return pubkey
                }()
            else { continue }
            
            let user = response.users[pubkey] ?? .init(pubkey: pubkey)
            
            let mention = user.atIdentifier
            text = text.replacingOccurrences(of: item, with: mention)
            markedMentions.append((mention, ref: pubkey))
            p.mentionedUsers.append(user)
        }
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let nsText = text as NSString
        
        p.zaps = parsedZaps.filter { $0.postId == post.id || $0.postId == post.universalID }
        p.hashtags = hashtags.flatMap { nsText.positions(of: $0, reference: $0) }
        p.mentions = markedMentions.flatMap { nsText.positions(of: $0.0, reference: $0.ref) }
//        p.notes = referencedPosts.flatMap { nsText.positions(of: $0.0, reference: $0.1.post.id) }
        p.httpUrls = shortenedUrls.flatMap { nsText.positions(of: $0.0, reference: $0.1) }
        p.highlights = highlights.flatMap { nsText.positions(of: $0.replacement, reference: $0.highlight.post.id)}
        p.highlightEvents = highlights.map { $0.highlight }
        p.text = text
        p.buildContentString(style: contentStyle)
        
        return p
    }
    
    private func extractNote(
        p: ParsedContent,
        post: PrimalFeedPost,
        mention: ParsedContent,
        mentionText: String,
        mentionId: String,
        highlights: inout [ProcessingHighlight],
        itemsToRemove: inout [String],
        referencedPosts: inout [(String, ParsedContent)],
        otherURLs: [String]
    ) {
        if mention.post.kind == NostrKind.zapReceipt.rawValue {
            if let feedZap = parsedFeedZaps.first(where: { $0.zap.receiptId == mentionId }) {
                p.embeddedZap = feedZap
                itemsToRemove.append(mentionText)
            } else if !otherURLs.contains(where: { $0.hasSuffix(mentionText) }) {
                p.customEvent = mention
                itemsToRemove.append(mentionText)
            }
        } else if mention.post.kind == NostrKind.highlight.rawValue  {
            let content = mention.post.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            highlights.append((mentionText, content, mention))
        } else if mention.post.kind == post.kind {
            referencedPosts.append((mentionText, mention))
        } else if mention.post.kind == NostrKind.mediaPost.rawValue, let urlTag = mention.post.tags.first(where: { $0.first == "imeta" })?[safe: 1], urlTag.hasPrefix("url ") {
            let url = String(urlTag.dropFirst(4))
            let media = response.mediaMetadata.first(where: { $0.event_id == mentionId })?.resources.uniqueByFilter({ $0.url })
            mention.mediaResources.append(contentsOf: media ?? [.init(url: url, variants: [])])
            mention.mediaResources = mention.mediaResources.uniqueByFilter({ $0.url })
            referencedPosts.append((mentionText, mention))
        } else if !otherURLs.contains(where: { $0.hasSuffix(mentionText) }) {
            p.customEvent = mention
            itemsToRemove.append(mentionText)
        }
    }
}
