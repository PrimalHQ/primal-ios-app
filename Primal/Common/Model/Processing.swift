//
//  Processing.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.5.23..
//

import Foundation
import LinkPresentation

extension LPLinkMetadata {
    static func loadingMetadata(_ url: URL) -> LPLinkMetadata {
        let metadata = LPLinkMetadata()
        metadata.title = "Loading preview..."
        metadata.url = url
        if let url = Bundle.main.url(forResource: "MainLogo", withExtension: "png") {
            metadata.imageProvider = .init(contentsOf: url)
        }
        return metadata
    }
    
    static func failedToLoad(_ url: URL) -> LPLinkMetadata {   
        let metadata = LPLinkMetadata()
        metadata.url = url
        metadata.title = "Failed to load preview..."
        if let url = Bundle.main.url(forResource: "MainLogo", withExtension: "png") {
            metadata.imageProvider = .init(contentsOf: url)
        }
        return metadata
    }
}

extension PostRequestResult {
    func createPrimalPost(content: NostrContent) -> (PrimalFeedPost, PrimalUser)? {
        guard
            let nostrUser = users[content.pubkey],
            let nostrPostStats = stats[content.id]
        else { return nil }
        
        let primalFeedPost = PrimalFeedPost(nostrPost: content, nostrPostStats: nostrPostStats)
        
        return (primalFeedPost, nostrUser)
    }
    
    func process() -> [ParsedContent] {
        let mentions: [ParsedContent] = mentions
            .compactMap({ createPrimalPost(content: $0) })
            .map { parse(post: $0.0, user: $0.1, mentions: [], removeExtractedLinks: false) }
        
        let reposts: [ParsedContent] = reposts
            .compactMap {
                guard let (post, user) = createPrimalPost(content: $0.post) else { return nil }
                return (post, user, $0)
            }
            .compactMap { (primalPost: PrimalFeedPost, user: PrimalUser, repost: NostrRepost) in
                let post = parse(post: primalPost, user: user, mentions: mentions, removeExtractedLinks: true)
                
                guard
                    let nostrUser = users[repost.pubkey]
                else {
                    return post
                }
                
                post.reposted = nostrUser
                return post
            }
        
        let normalPosts = posts.compactMap { createPrimalPost(content: $0) }
            .map { parse(post: $0.0, user: $0.1, mentions: mentions, removeExtractedLinks: true)}
        
        return (reposts + normalPosts).sorted(by: { $0.post.created_at > $1.post.created_at })
    }
    
    func parse(
        post: PrimalFeedPost,
        user: PrimalUser,
        mentions: [ParsedContent],
        removeExtractedLinks: Bool
    ) -> ParsedContent {
        let p = ParsedContent(post: post, user: user)
        
        var text: String = post.content
        let result: [String] = text.extractTagsMentionsAndURLs()
        let imageURLs: [URL] = result.filter({ $0.isValidURLAndIsImage }).compactMap { URL(string: $0) }
        var otherURLs = result.filter({ ($0.isValidURL && !$0.isImageURL) })
        var hashtags = result.filter({ $0.isHashtag })
        
        var itemsToRemove = result.filter { $0.isValidURLAndIsImage }
        var itemsToReplace = result.filter { $0.isNip08Mention || $0.isNip27Mention }
        var markedMentions: [String] = []
        
        if let index = otherURLs.firstIndex(where: { $0.isValidURL }) {
            let firstURL = otherURLs.remove(at: index)
            itemsToRemove.append(firstURL)
            
            if let url = URL(string: firstURL) {
                p.firstExtractedURL = url
                p.extractedMetadata = .loadingMetadata(url)
                
                let provider = LPMetadataProvider()
                provider.startFetchingMetadata(for: url) { metadata, error in
                    DispatchQueue.main.async {
                        guard let metadata else {
                            p.extractedMetadata = .failedToLoad(url)
                            return
                        }
                        
                        if let imageProvider = metadata.imageProvider {
                            imageProvider.loadObject(ofClass: UIImage.self) { image, error in
                                guard
                                    image == nil,
                                    let url = Bundle.main.url(forResource: "MainLogo", withExtension: "png")
                                else { return }

                                metadata.imageProvider = .init(contentsOf: url)
                                DispatchQueue.main.async {
                                    p.extractedMetadata = metadata

                                    _ = provider
                                }
                            }
                        } else if metadata.videoProvider == nil, let url = Bundle.main.url(forResource: "MainLogo", withExtension: "png") {
                            metadata.imageProvider = .init(contentsOf: url)
                        }
                        
                        p.extractedMetadata = metadata
                        
                        _ = provider
                    }
                }
            }
        }
        
        for mention in mentions {
            // It's slow to generate noteRef and searchString for every mention for every post, can be generated once and passed with the mentions
            guard let noteRef = bech32_note_id(mention.post.id) else { continue }
            let searchString = "nostr:\(noteRef)"
            if text.contains(searchString) {
                itemsToRemove.append(searchString)
                p.embededPost = mention
                break
            }
        }
        
        for r in result {
            if r.isNip08Mention || r.isNip27Mention {
                itemsToReplace.append(r)
            }
        }
        
        if removeExtractedLinks {
            for item in itemsToRemove {
                text = text.replacingOccurrences(of: item, with: "")
            }
        }
        
        for item in itemsToReplace {
            if item.isNip08Mention {
                if let index = Int(item[safe: 2]!.string) {
                    if let tag = post.tags[safe: index] {
                        if let pubkey = tag[safe: 1] {
                            if let user = users[pubkey] {
                                let mention = "@\(user.name)"
                                text = text.replacingOccurrences(of: item, with: mention)
                                markedMentions.append(mention)
                            }
                        }
                    }
                }
            } else if item.isNip27Mention {
                if let npub = item.split(separator: ":")[safe: 1]?.string {
                    guard let decoded = try? bech32_decode(npub) else { fatalError("Incorrect npub") }
                    let pubkey = hex_encode(decoded.data)
                    if let user = users[pubkey] {
                        let mention = "@\(user.name)"
                        text = text.replacingOccurrences(of: item, with: mention)
                        markedMentions.append(mention)
                    }
                }
            }
        }
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let nsText = text as NSString
        
        otherURLs.append(contentsOf: markedMentions)
        otherURLs.append(contentsOf: hashtags)
        p.imageUrls = imageURLs
        p.httpUrls = otherURLs.compactMap {
            let position = nsText.range(of: $0)
            
            if position.location != NSNotFound {
                return .init(position: position.location, length: position.length, text: $0)
            }
            return nil
        }
        p.text = text
        p.buildContentString()
        
        return p
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
