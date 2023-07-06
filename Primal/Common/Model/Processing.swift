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
        guard
            let nostrUser = users[content.pubkey],
            let nostrPostStats = stats[content.id]
        else { return nil }
        
        let primalFeedPost = PrimalFeedPost(nostrPost: content, nostrPostStats: nostrPostStats)
        
        return (primalFeedPost, createParsedUser(nostrUser))
    }
    
    func createParsedUser(_ user: PrimalUser) -> ParsedUser { .init(
        data: user,
        profileImage: mediaMetadata.flatMap { $0.resources } .first(where: { $0.url == user.picture }),
        likes: userScore[user.pubkey]
    )}
    
    func process() -> [ParsedContent] {
        let mentions: [ParsedContent] = mentions
            .compactMap({ createPrimalPost(content: $0) })
            .map { parse(post: $0.0, user: $0.1, mentions: [], removeExtractedPost: false) }
        
        let reposts: [ParsedContent] = reposts
            .compactMap {
                guard let (post, user) = createPrimalPost(content: $0.post) else { return nil }
                return (post, user, $0)
            }
            .compactMap { (primalPost: PrimalFeedPost, user: ParsedUser, repost: NostrRepost) in
                let post = parse(post: primalPost, user: user, mentions: mentions, removeExtractedPost: true)
                
                guard
                    let nostrUser = users[repost.pubkey]
                else {
                    return post
                }
                
                post.reposted = createParsedUser(nostrUser)
                return post
            }
        
        let normalPosts = posts.compactMap { createPrimalPost(content: $0) }
            .map { parse(post: $0.0, user: $0.1, mentions: mentions, removeExtractedPost: true)}
  
        let all = reposts + normalPosts
        
        return order.compactMap { id in all.first(where: { $0.post.id == id }) }
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
        var otherURLs: [String] = []
        var hashtags: [String] = []
        var itemsToRemove: [String] = []
        var itemsToReplace: [String] = []
        var markedMentions: [String] = []
        
        for str in result {
            if str.isValidURLAndIsImage {
                imageURLs.append(str)
                itemsToRemove.append(str)
            } else if str.isValidURL && !str.isImageURL {
                otherURLs.append(str)
            } else if str.isNip08Mention || str.isNip27Mention {
                itemsToReplace.append(str)
            } else if str.isHashtag {
                hashtags.append(str)
            }
        }
        
        if let index = otherURLs.firstIndex(where: { $0.isValidURL && $0.isNotEmail }) {
            let firstURL = otherURLs.remove(at: index)
            itemsToRemove.append(firstURL)

            if let url = URL(string: firstURL.hasPrefix("http") ? firstURL : "https://\(firstURL)") {
                p.firstExtractedURL = url
                p.parsedMetadata = .loadingMetadata(url)

                let provider = LPMetadataProvider()
                provider.startFetchingMetadata(for: url) { metadata, error in
                    DispatchQueue.main.async {
                        _ = provider

                        guard let metadata else {
                            p.parsedMetadata = .failedToLoad(url)
                            return
                        }

                        var parsed: LinkMetadata = .init(url: url, lpMetadata: metadata, title: metadata.title)
                        p.parsedMetadata = parsed

                        DispatchQueue.global(qos: .background).async {
                            let imageKey = p.linkMetadataImageKey
                            if KingfisherManager.shared.cache.isCached(forKey: imageKey) {
                                DispatchQueue.main.async {
                                    p.parsedMetadata?.imageKey = imageKey
                                }
                            } else if let imageProvider = metadata.imageProvider {
                                imageProvider.loadObject(ofClass: UIImage.self) { image, error in
                                    DispatchQueue.main.async {
                                        guard let image = image as? UIImage else { return }
                                        
                                        KingfisherManager.shared.cache.store(image, forKey: imageKey)
                                        p.parsedMetadata?.imageKey =  imageKey
                                    }
                                }
                            }

                            let iconKey = p.linkMetadataIconKey
                            if KingfisherManager.shared.cache.isCached(forKey: iconKey) {
                                DispatchQueue.main.async {
                                    p.parsedMetadata?.iconKey = iconKey
                                }
                            } else if let iconProvider = metadata.iconProvider {
                                iconProvider.loadObject(ofClass: UIImage.self) { icon, error in
                                    DispatchQueue.main.async {
                                        guard let icon = icon as? UIImage else { return }
                                        
                                        KingfisherManager.shared.cache.store(icon, forKey: iconKey)
                                        p.parsedMetadata?.iconKey = iconKey
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for mention in mentions {
            // It's slow to generate noteRef and searchString for every mention for every post, can be generated once and passed with the mentions
            guard let noteRef = bech32_note_id(mention.post.id) else { continue }
            let searchString = "nostr:\(noteRef)"
            if text.contains(searchString) {
                if removeExtractedPost {
                    itemsToRemove.append(searchString)
                }
                p.embededPost = mention
                break
            }
        }
        
        for item in itemsToRemove {
            text = text.replacingOccurrences(of: item, with: "")
        }
        
        for media in mediaMetadata where media.event_id == post.id {
            p.imageResources = media.resources
        }
        
        for item in itemsToReplace {
            guard let user: PrimalUser = {
                if item.isNip08Mention {
                    guard
                        let index = Int(item[safe: 2]?.string ?? ""),
                        let tag = post.tags[safe: index],
                        let pubkey = tag[safe: 1]
                    else { return nil }
                                
                    return users[pubkey]
                }
                
                guard
                    item.isNip27Mention,
                    let npub = item.split(separator: ":")[safe: 1]?.string,
                    let decoded = try? bech32_decode(npub)
                else { return nil }
                let pubkey = hex_encode(decoded.data)
                return users[pubkey]
            }() else { continue }
            
            let mention = "@\(user.name)"
            text = text.replacingOccurrences(of: item, with: mention)
            markedMentions.append(mention)
        }
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let nsText = text as NSString
        
        if p.imageResources.isEmpty {
            p.imageResources = imageURLs.map { .init(url: $0, variants: []) }
        }
        p.hashtags = hashtags.compactMap { nsText.position(of: $0) }
        p.mentions = markedMentions.compactMap { nsText.position(of: $0) }
        p.httpUrls = otherURLs.compactMap { nsText.position(of: $0) }
        p.text = text
        p.buildContentString()
        
        return p
    }
}

extension NSString {
    func position(of substring: String) -> ParsedElement? {
        let position = range(of: substring)
        
        if position.location != NSNotFound {
            return .init(position: position.location, length: position.length, text: substring)
        }
        return nil
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
    
    var atIdentifier: String { "@" + atIdentifierWithoutAt }
    
    var atIdentifierWithoutAt: String {
        if !name.isEmpty {
            return name
        }
        if !displayName.isEmpty {
            return displayName
        }
        return npub
    }
    
    var secondIdentifier: String? {
        let identifiers = [displayName, name, nip05, npub]
        var didFindFirst = false
        for identifier in identifiers where !identifier.isEmpty {
            guard !didFindFirst else { return identifier }
            
            didFindFirst = true
        }
        return nil
    }
}
