//
//  Processing.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.5.23..
//

import Foundation
import LinkPresentation
import Kingfisher

extension PostRequestResult {
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
        
        let reposts: [ParsedContent] = reposts
            .compactMap { repost in
                guard let (primalPost, user) = createPrimalPost(content: repost.post) else { return nil }
                
                let post = parse(post: primalPost, user: user, mentions: mentions, removeExtractedPost: true)
                
                guard let nostrUser = users[repost.pubkey] else { return post }
                
                post.reposted = .init(users: [createParsedUser(nostrUser)], date: repost.date, id: repost.id)
                
                return post
            }
        
        let normalPosts = posts.compactMap { createPrimalPost(content: $0) }
            .map { parse(post: $0.0, user: $0.1, mentions: mentions, removeExtractedPost: true)}
  
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
        removeExtractedPost: Bool
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
        for tagArray in post.tags {
            guard
                tagArray.count >= 4, tagArray[0] == "e", tagArray[3] == "root" || tagArray[3] == "reply",
                let parentNote = mentions.first(where: { $0.post.id == tagArray[1] })
            else { continue }
            
            p.replyingTo = parentNote
        }
        
        if p.replyingTo == nil {
            for tagArray in post.tags {
                guard
                    tagArray.count >= 2, tagArray[0] == "e",
                    let parentNote = mentions.first(where: { $0.post.id == tagArray[1] })
                else { continue }
                
                p.replyingTo = parentNote
            }
        }
        
        // MARK: - Finding and extracting mentioned notes
        let nevent1MentionPattern = "\\bnostr:((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
        
        var referencedPosts: [(String, ParsedContent)] = []
        
        if let profileMentionRegex = try? NSRegularExpression(pattern: nevent1MentionPattern, options: []) {
            profileMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                    
                if let mentionId = mentionText.eventIdFromNEvent(), let mention = mentions.first(where: { $0.post.id == mentionId }) {
                    referencedPosts.append((mentionText, mention))
                }
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
        
        for string in videoURLS.reversed() {
            if !p.mediaResources.contains(where: { string.hasPrefix($0.url) }) {
                p.mediaResources.insert(.init(url: string, variants: []), at: 0)
            }
        }
        
        // Don't show link preview if post contains media gallery
        if !p.mediaResources.isEmpty { p.linkPreview = nil }
        
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
                        let npub = item.split(separator: ":")[safe: 1]?.string,
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
        
        p.hashtags = hashtags.flatMap { nsText.positions(of: $0, reference: $0) }
        p.mentions = markedMentions.flatMap { nsText.positions(of: $0.0, reference: $0.ref) }
        p.notes = referencedPosts.flatMap { nsText.positions(of: $0.0, reference: $0.1.post.id) }
        p.httpUrls = otherURLs.flatMap { nsText.positions(of: $0, reference: $0) }
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
}

private extension String {
    func eventIdFromNEvent() -> String? {
        guard case .mention(let mention) = parse_mentions().first else { return nil }
            
        return mention.ref.id
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
