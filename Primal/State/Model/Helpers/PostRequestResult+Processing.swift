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
import LightningDevKit

extension PostRequestResult: MetadataCoding {
    func getSortedUsers() -> [ParsedUser] {
        users.map { createParsedUser($0.value) }.sorted(by: {
            ($0.followers ?? 0) != ($1.followers ?? 0) ? 
                ($0.followers ?? 0) > ($1.followers ?? 0) :
                ($0.data.firstIdentifier > $1.data.firstIdentifier)
        } )
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
        followers: userFollowers[user.pubkey] ?? 0
    )}
    
    func process(contentStyle: ParsedContentTextStyle) -> [ParsedContent] {
        NoteProcessor(result: self, contentStyle: contentStyle).process()
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
        let nsString = (self as NSString)
        
        var referenceLinksText = ""
        if let refRegex = try? NSRegularExpression(pattern: #"^\s*\[([^\]]+)\]:\s*<?(\S+?)>?(?:\s+(?:"([^"]*)"|'([^']*)'|\(([^)]*)\)))?\s*$"#, options: .anchorsMatchLines) {
            refRegex.enumerateMatches(in: self, range: .init(startIndex..., in: self)) { match, _, _ in
                guard let matchRange = match?.range else { return }

                let mentionText = nsString.substring(with: matchRange)

                referenceLinksText +=  "\n" + mentionText
            }
        }
        
        let nevent1MentionPattern = "\\b(nostr:|@)((nevent|note)1\\w+)\\b|#\\[(\\d+)\\]"
        guard let postMentionRegex = try? NSRegularExpression(pattern: nevent1MentionPattern, options: []) else { return [.text(self)] }
        
        var segments = [LongFormContentSegment]()
        var prevRangeStart: Int = 0
        
        postMentionRegex.enumerateMatches(in: self, options: [], range: NSRange(startIndex..., in: self)) { match, _, _ in
            guard let matchRange = match?.range else { return }
                
            let mentionText = nsString.substring(with: matchRange)
            
            let naventString: String = {
                if mentionText.hasPrefix("nostr:") { return mentionText.dropFirst(6).string }
                if mentionText.hasPrefix("@") { return mentionText.dropFirst().string }
                return mentionText
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
                let regexPattern = #"\[(?:!\[[^\]]*\]\(([^)]+)\))\]\([^)]+\)|!\[[^\]]*\]\(([^)]+)\)"#
                guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
                    return [.text(text + referenceLinksText)]
                }
                
                var subSegments: [LongFormContentSegment] = []
                
                prevRangeStart = 0
                let nsString = (text as NSString)
                
                regex.enumerateMatches(in: text, options: [], range: NSRange(startIndex..., in: text)) { match, _, _ in
                    guard let match else { return }
                    
                    var nsRange = match.range(at: 1)
                    if nsRange.location == NSNotFound {
                        nsRange = match.range(at: 2)
                    }
                    
                    if nsRange.location != NSNotFound , let urlRange = Range(nsRange, in: text) {
                        var url = String(text[urlRange])
                        
                        if url.contains(" \""), let first = url.split(separator: " \"").first {
                            url = String(first)
                        }
                        
                        let prevTextRange = NSRange(location: prevRangeStart, length: match.range.location - prevRangeStart)
                        let prevText = nsString.substring(with: prevTextRange).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !prevText.isEmpty {
                            subSegments.append(.text(prevText + referenceLinksText))
                        }
                        
                        subSegments.append(.image(url))
                        prevRangeStart = match.range.endLocation
                    }
                }
                
                let finalText = text.dropFirst(prevRangeStart).trimmingCharacters(in: .whitespacesAndNewlines)
                if !finalText.isEmpty {
                    subSegments.append(.text(finalText + referenceLinksText))
                }
                
                return subSegments
            }
        }
        
        print(allSegments)
        return allSegments
    }
}

extension String: @retroactive MetadataCoding {
    func eventIdFromNEvent() -> String? {
        (try? decodedMetadata(from: self))?.eventId ?? self.noteIdToHex()
    }
    
    func invoiceFromString() -> Invoice? {
        guard let invoice = Bolt11Invoice.fromStr(s: self).getValue() else { return nil }
        return Invoice(description: "", amount: invoice.amountMilliSatoshis(), string: self, expiry: invoice.expiryTime(), created_at: invoice.timestamp())
    }
}
