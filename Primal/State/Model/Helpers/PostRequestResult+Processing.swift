//
//  Processing.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.5.23..
//

import Foundation
import LinkPresentation
import Kingfisher
import NostrSDK

extension PostRequestResult: MetadataCoding {
    func getSortedUsers() -> [ParsedUser] {
        users.map { createParsedUser($0.value) }.sorted(by: { ($0.likes ?? 0) > ($1.likes ?? 0) } )
    }
    
    func createPrimalPost(content: NostrContent) -> (PrimalFeedPost, ParsedUser)? {
        let nostrUser = users[content.pubkey] ?? .init(pubkey: content.pubkey)
        let nostrPostStats = stats[content.id] ?? .empty(content.id)
        
        let primalFeedPost = PrimalFeedPost(nostrPost: content, nostrPostStats: nostrPostStats)
        
        if primalFeedPost.isEmpty { return nil }
        
        return (primalFeedPost, createParsedUser(nostrUser))
    }
    
    func createParsedUser(_ user: PrimalUser) -> ParsedUser { .init(
        data: user,
        profileImage: mediaMetadata.flatMap { $0.resources } .first(where: { $0.url == user.picture }),
        likes: userScore[user.pubkey],
        followers: userFollowers[user.pubkey]
    )}
    
    func process() -> [ParsedContent] {
        let mentions: [ParsedContent] = mentions
            .compactMap({ createPrimalPost(content: $0) })
            .map { parse(post: $0.0, user: $0.1, mentions: [], removeExtractedPost: false) }
        
        let parsedUsers = getSortedUsers()
        let parsedZaps = postZaps.map { primalZapEvent in
            ParsedZap(
                receiptId: primalZapEvent.zap_receipt_id,
                postId: primalZapEvent.event_id,
                amountSats: primalZapEvent.amount_sats,
                message: zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
                user: parsedUsers.first(where: { $0.data.pubkey == primalZapEvent.sender }) ?? ParsedUser(data: .init(pubkey: primalZapEvent.sender))
            )
        }
        
        let reposts: [ParsedContent] = reposts
            .compactMap { repost -> ParsedContent? in
                guard let (primalPost, user) = createPrimalPost(content: repost.post) else { return nil }
                
                let post = parse(post: primalPost, user: user, mentions: mentions, removeExtractedPost: true, parsedZaps: parsedZaps)
                
                guard let nostrUser = users[repost.pubkey] else { return post }
                
                post.reposted = .init(users: [createParsedUser(nostrUser)], date: repost.date, id: repost.id)
                
                return post
            }
        
        let normalPosts = posts.compactMap { createPrimalPost(content: $0) }
            .map { parse(post: $0.0, user: $0.1, mentions: mentions, removeExtractedPost: true, parsedZaps: parsedZaps) }
        
        if order.isEmpty {
            return normalPosts
        }
        
        let all = normalPosts + reposts
        return order.compactMap { id in
            all.first(where: { $0.post.id == id }) ?? reposts.first(where: { $0.reposted?.id == id})
        }
    }
    
    func parse(
        post: PrimalFeedPost,
        user: ParsedUser,
        mentions: [ParsedContent],
        removeExtractedPost: Bool,
        parsedZaps: [ParsedZap] = []
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
        
        for preview in webPreviews.first(where: { $0.event_id == post.id })?.resources ?? [] {
            let urlString = preview.url
            guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)") else { continue }
            
            guard preview.md_title?.isEmpty == false || preview.md_description?.isEmpty == false else { continue }
            
            if p.linkPreview != nil {
                p.linkPreview = nil
                break // Leave the loop as we don't show the preview if there is more than one url preview
            }
            
            p.linkPreview = LinkMetadata(
                url: url,
                imagesData: mediaMetadata.filter { $0.event_id == post.id }.flatMap { $0.resources },
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
        var highlights: [(String, ParsedContent)] = []
        
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
                    if mention.post.kind == NostrKind.highlight.rawValue  {
                        let content = mention.post.content.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        text = text.replacingOccurrences(of: mentionText, with: content)
                        highlights.append((content, mention))
                    } else {
                        referencedPosts.append((mentionText, mention))
                    }
                }
            }
        }
        
        // MARK: - Finding and extracting mentioned notes without "nostr:" or "@" prefix
        let nevent1WildcardMentionPattern = "\\b((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
        
        if let postMentionRegex = try? NSRegularExpression(pattern: nevent1WildcardMentionPattern, options: []) {
            postMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                let naventString: String = "nostr:\(mentionText)"
                    
                if !referencedPosts.contains(where: { $0.0.hasSuffix(mentionText) }), let mentionId = naventString.eventIdFromNEvent(), let mention = mentions.first(where: { $0.post.id == mentionId }) {
                    referencedPosts.append((mentionText, mention))
                }
            }
        }
        
        let articleMentionPattern = "\\bnostr:(naddr1\\w+)\\b|#\\[(\\d+)\\]"
        if let articleMentionRegex = try? NSRegularExpression(pattern: articleMentionPattern, options: []) {
            articleMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard p.article == nil, let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)

                guard
                    let address = mentionText.split(separator: ":").last,
                    let metadata = try? decodedMetadata(from: String(address)),
                    let id = metadata.identifier,
                    let mention = self.mentions.first(where: {
                        $0.kind == NostrKind.longForm.rawValue && $0.tags.contains(["d", id])
                    })
                else { return }
                
                itemsToRemove.append(mentionText)
               
                p.article = Article(
                    id: id,
                    title: mention.tags.first(where: { $0.first == "title" })?[safe: 1] ?? "",
                    image: mention.tags.first(where: { $0.first == "image" })?[safe: 1],
                    summary: mention.tags.first(where: { $0.first == "summary" })?[safe: 1],
                    words: nil,
                    zaps: [],
                    replies: [],
                    stats: stats[mention.id] ?? .empty(mention.id),
                    event: mention,
                    user: createParsedUser(users[mention.pubkey] ?? PrimalUser(pubkey: mention.pubkey))
                )
            }
        }
        
        if removeExtractedPost && referencedPosts.count == 1, let (mentionText, mention) = referencedPosts.first {
            p.embededPost = mention
            itemsToRemove.append(mentionText)
        }
        
        if removeExtractedPost, referencedPosts.isEmpty {
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
        
        for media in mediaMetadata where media.event_id == post.id {
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
                    for mentionedPub in users.keys {
                        if pubkey.contains(mentionedPub) {
                            return mentionedPub
                        }
                    }
                    return pubkey
                }(),
                let user = users[pubkey]
            else { continue }
            
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
        p.highlights = highlights.flatMap { nsText.positions(of: $0.0, reference: $0.1.post.id)}
        p.highlightEvents = highlights.map { $0.1 }
        p.text = text
        p.buildContentString()
        
        return p
    }
}

extension NSString {
    func positions(of substring: String, reference: String) -> [ParsedElement] {
        var position = range(of: substring)
        var parsed = [ParsedElement]()
        while position.location != NSNotFound {
            parsed.append(.init(position: position.location, length: position.length, text: substring, reference: reference))
            position = range(of: substring, range: .init(location: position.endLocation, length: length - position.endLocation))
        }
        return parsed
    }
}

extension PrimalUser {
    var firstIdentifier: String {
        if !displayName.isEmpty {
            return displayName
        }
        if !name.isEmpty {
            return name
        }
        return npub
    }
    
    var atIdentifier: String { "@" + atIdentifierWithoutAt.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    var atIdentifierWithoutAt: String {
        if !name.isEmpty {
            return name
        }
        if !displayName.isEmpty {
            return displayName
        }
        return npub
    }
    
    var parsedNip: String { nip05.hasPrefix("_@") ? nip05.replacingOccurrences(of: "_@", with: "") : nip05 }
    
    var secondIdentifier: String? { [parsedNip, name].filter { !$0.isEmpty && $0 != firstIdentifier } .first }
    
    var isCurrentUser: Bool { pubkey == IdentityManager.instance.userHexPubkey }
}

extension String {
    func splitLongFormParts(mentions: [ParsedContent]) -> [LongFormContentSegment] {
        let nevent1MentionPattern = "\\b(nostr:|@)((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
        guard let postMentionRegex = try? NSRegularExpression(pattern: nevent1MentionPattern, options: []) else { return [.text(self)] }
        
        var segments = [LongFormContentSegment]()
        var prevRangeStart: Int = 0
        let nsString = (self as NSString)
        
        postMentionRegex.enumerateMatches(in: self, options: [], range: NSRange(startIndex..., in: self)) { match, _, _ in
            guard let matchRange = match?.range else { return }
                
            let mentionText = nsString.substring(with: matchRange)
            
            let naventString: String = {
                if mentionText.hasPrefix("nostr:") { return mentionText }
                if mentionText.hasPrefix("@") { return "nostr:\(mentionText.dropFirst())" }
                return "nostr:\(mentionText)"
            }()
                
            if let mentionId = naventString.eventIdFromNEvent(), let mention = mentions.first(where: { $0.post.id == mentionId }) {
                let prevTextRange = NSRange(location: prevRangeStart, length: matchRange.location - prevRangeStart)
                let prevText = nsString.substring(with: prevTextRange).trimmingCharacters(in: .whitespacesAndNewlines)
                if !prevText.isEmpty {
                    segments.append(.text(prevText))
                }
                
                segments.append(.post(mention))
                prevRangeStart = matchRange.endLocation
            }
        }
        
        let finalText = dropFirst(prevRangeStart).trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalText.isEmpty {
            segments.append(.text(finalText))
        }
        
        // Now look for images
        let allSegments = segments.flatMap {
            switch $0 {
            case .image, .post: return [$0]
            case .text(let text):
                let regexPattern = #"!\[([^\]]*)\]\(([^)]+)\)"#
                guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
                    return [$0]
                }
                
                var subSegments: [LongFormContentSegment] = []
                
                prevRangeStart = 0
                let nsString = (text as NSString)
                
                regex.enumerateMatches(in: text, options: [], range: NSRange(startIndex..., in: text)) { match, _, _ in
                    guard let match else { return }
                                        
                    if let urlRange = Range(match.range(at: 2), in: text) {
                        let url = String(text[urlRange])
                        
                        let prevTextRange = NSRange(location: prevRangeStart, length: match.range.location - prevRangeStart)
                        let prevText = nsString.substring(with: prevTextRange).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !prevText.isEmpty {
                            subSegments.append(.text(prevText))
                        }
                        
                        subSegments.append(.image(url))
                        prevRangeStart = match.range.endLocation
                    }
                }
                
                let finalText = text.dropFirst(prevRangeStart).trimmingCharacters(in: .whitespacesAndNewlines)
                if !finalText.isEmpty {
                    subSegments.append(.text(finalText))
                }
                
                return subSegments
            }
        }
        
        print(allSegments)
        return allSegments
    }
}

private extension String {
    func eventIdFromNEvent() -> String? {
        guard case .mention(let mention) = parse_mentions().first else { return nil }
            
        return mention.ref.id
    }
    
    func invoiceFromString() -> Invoice? {
        guard case .invoice(let invoice) = parse_mentions().first else { return nil }
        return invoice
    }
    
    func parse_mentions() -> [Block] {
        var out: [Block] = []
        
        var bs = blocks()
        bs.num_blocks = 0;
        
        blocks_init(&bs)
        
        let bytes = self.utf8CString
        let _ = bytes.withUnsafeBufferPointer { p in
            damus_parse_content(&bs, p.baseAddress)
        }
        
        var i = 0
        while (i < bs.num_blocks) {
            let block = bs.blocks[i]
            
            if let converted = convert_block(block, tags: []) {
                out.append(converted)
            }
            
            i += 1
        }
        
        blocks_free(&bs)
        
        return out
    }
}
