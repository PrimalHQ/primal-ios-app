//
//  ProcessingNotes.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.11.24..
//

import Foundation
import NostrSDK

class NoteProcessor: MetadataCoding {
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
    
    lazy var parsedZaps = response.postZaps.map { primalZapEvent in
        ParsedZap(
            receiptId: primalZapEvent.zap_receipt_id,
            postId: primalZapEvent.event_id,
            amountSats: primalZapEvent.amount_sats,
            message: response.zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
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
        
        return response.postZaps.map { primalZapEvent in
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
                    user: user
                ),
                zappedObject: zappedObject
            )
        }        
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
        let result: [String] = text.extractTagsMentionsAndURLs()
        var imageURLs: [String] = []
        var videoURLS: [String] = []
        var otherURLs: [String] = []
        var hashtags: [String] = []
        var itemsToRemove: [String] = []
        var itemsToReplace: [String] = []
        var markedMentions: [(String, ref: String)] = []
        
        for str in result {
            if str.isValidURL {
                if str.isImageURL {
                    imageURLs.append(str)
                    itemsToRemove.append(str)
                } else if str.isVideoURL {
                    videoURLS.append(str)
                    itemsToRemove.append(str)
                } else {
                    otherURLs.append(str)
                }
            } else if str.isNip08Mention || str.isNip27Mention {
                itemsToReplace.append(str)
            } else if str.isHashtag {
                hashtags.append(str)
            }
        }
        
        for preview in response.webPreviews.first(where: { $0.event_id == post.id })?.resources ?? [] {
            let urlString = preview.url
            guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)") else { continue }
            
            guard preview.md_title?.isEmpty == false || preview.md_description?.isEmpty == false else { continue }
            
            if p.linkPreview != nil {
                p.linkPreview = nil
                break // Leave the loop as we don't show the preview if there is more than one url preview
            }
            
            p.linkPreview = LinkMetadata(
                url: url,
                imagesData: response.mediaMetadata.filter { $0.event_id == post.id }.flatMap { $0.resources },
                data: preview
            )
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
        
        if p.replyingTo == nil {
            for tagArray in post.tags {
                guard
                    tagArray.count >= 2, tagArray[0] == "a" || tagArray[0] == "e",
                    let parentNote = mentions.first(where: { $0.post.id == tagArray[1] || $0.post.universalID == tagArray[1] })
                else { continue }
                
                p.replyingTo = parentNote
                break
            }
        }
        
        // MARK: - Finding and extracting mentioned notes
        let nevent1MentionPattern = "\\b(nostr:|@)((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
        
        var referencedPosts: [(String, ParsedContent)] = []
        var highlights: [(reference: String, replacement: String, highlight: ParsedContent)] = []
        
        let tmpText = text as NSString
        if let postMentionRegex = try? NSRegularExpression(pattern: nevent1MentionPattern, options: []) {
            postMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = tmpText.substring(with: matchRange)
                
                let naventString: String = {
                    if mentionText.hasPrefix("nostr:") { return mentionText }
                    if mentionText.hasPrefix("@") { return "nostr:\(mentionText.dropFirst())" }
                    return "nostr:\(mentionText)"
                }()
                    
                if let mentionId = naventString.eventIdFromNEvent(), let mention = mentions.first(where: { $0.post.id == mentionId }) {
                    if mention.post.kind == NostrKind.zapReceipt.rawValue {
                        if let feedZap = parsedFeedZaps.first(where: { $0.zap.receiptId == mentionId}) {
                            p.embeddedZap = feedZap
                        } else {
                            p.customEvent = mention
                        }
                        itemsToRemove.append(mentionText)
                    } else if mention.post.kind == NostrKind.highlight.rawValue  {
                        let content = mention.post.content.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        highlights.append((mentionText, content, mention))
                    } else if mention.post.kind == post.kind {
                        referencedPosts.append((mentionText, mention))
                    } else {
                        p.customEvent = mention
                        itemsToRemove.append(mentionText)
                    }
                } else {
                    itemsToRemove.append(mentionText)
                    p.notFound = .note
                }
            }
        }
        
        // MARK: - Finding and extracting mentioned notes without "nostr:" or "@" prefix
        let nevent1WildcardMentionPattern = "\\b((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
        
        if let postMentionRegex = try? NSRegularExpression(pattern: nevent1WildcardMentionPattern, options: []) {
            postMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                if referencedPosts.contains(where: { $0.0.hasSuffix(mentionText) }) { return } // Already slated for removal
                
                let naventString: String = "nostr:\(mentionText)"
                
                if let mentionId = naventString.eventIdFromNEvent(), let mention = mentions.first(where: { $0.post.id == mentionId }) {
                    if mention.post.kind == NostrKind.highlight.rawValue  {
                        let content = mention.post.content.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        highlights.append((mentionText, content, mention))
                    } else if mention.post.kind == post.kind {
                        referencedPosts.append((mentionText, mention))
                    } else {
                        p.customEvent = mention
                        itemsToRemove.append(mentionText)
                    }
                } else {
                    itemsToRemove.append(mentionText)
                    p.notFound = .note
                }
            }
        }
        
        let articleMentionPattern = "\\bnostr:(naddr1\\w+)\\b|#\\[(\\d+)\\]"
        if let articleMentionRegex = try? NSRegularExpression(pattern: articleMentionPattern, options: []) {
            articleMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard p.article == nil, let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                itemsToRemove.append(mentionText)

                guard
                    let address = mentionText.split(separator: ":").last,
                    let metadata = try? decodedMetadata(from: String(address)),
                    let id = metadata.identifier,
                    let mention = self.response.mentions.first(where: {
                        ($0.kind == NostrKind.longForm.rawValue || $0.kind == NostrKind.shortenedArticle.rawValue) && $0.tags.contains(["d", id])
                    })
                else {
                    p.notFound = .article
                    return
                }
               
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
            }
        }
        
        if referencedPosts.count == 1, let (mentionText, mention) = referencedPosts.first {
            p.embededPost = mention
            itemsToRemove.append(mentionText)
        }
        
        if referencedPosts.isEmpty && highlights.isEmpty {
            let flatTags = post.tags.flatMap { $0 }
            for mention in mentions {
                if flatTags.contains(mention.post.id) {
                    var stringFound = false
                    if let profileMentionRegex = try? NSRegularExpression(pattern: nevent1MentionPattern, options: []) {
                        profileMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                            if !stringFound, let matchRange = match?.range {
                                itemsToRemove.append((text as NSString).substring(with: matchRange))
                                stringFound = true
                            }
                        }
                    }
                    
                    if stringFound {
                        p.embededPost = mention
                        break
                    }
                }
                
                if let noteRef = bech32_note_id(mention.post.id), text.contains(noteRef) {
                    let searchString = "nostr:\(noteRef)"
                    itemsToRemove.append(searchString)
                    p.embededPost = mention
                    break
                }
            }
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
        
        // Don't show link preview if post contains media gallery
        if !p.mediaResources.isEmpty { p.linkPreview = nil }
        
        let blocks = text.parse_mentions()
        for block in blocks {
            if case .invoice(let invoice) = block {
                p.invoice = invoice
                itemsToRemove.append(invoice.string)
                break
            }
        }
        
        // MARK: - Editing text
        
        for item in itemsToRemove {
            text = text.replacingOccurrences(of: item, with: "")
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Only remove url from text if
        if p.mediaResources.isEmpty, // there are no images or video (no media preview)
            otherURLs.count == 1,    // there is only one url in text
            p.linkPreview != nil,    // link preview exists
            let onlyURL = otherURLs.first,
            text.hasSuffix(onlyURL) // the URL is on the end of the post
        {
            otherURLs = []
            text = text.replacingOccurrences(of: onlyURL, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        for (reference, replacement, _) in highlights {
            text = text.replacingOccurrences(of: reference, with: replacement)
        }
        
        // Remove empty lines
        text = text.removingDoubleEmptyLines()
        
        for item in itemsToReplace {
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
                        let npub = item.split(separator: ":").last?.string,
                        let decoded = try? bech32_decode(npub)
                    else { return nil }
                    let pubkey = hex_encode(decoded.data)
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
        p.notes = referencedPosts.flatMap { nsText.positions(of: $0.0, reference: $0.1.post.id) }
        p.httpUrls = otherURLs.flatMap { nsText.positions(of: $0, reference: $0) }
        p.highlights = highlights.flatMap { nsText.positions(of: $0.replacement, reference: $0.highlight.post.id)}
        p.highlightEvents = highlights.map { $0.highlight }
        p.text = text
        p.buildContentString(style: contentStyle)
        
        return p
    }
}
