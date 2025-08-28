//
//  ParsedContent.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.5.23..
//

import Combine
import Foundation
import UIKit
import LinkPresentation
import NostrSDK
import GenericJSON

class ParsedElement: Equatable {
    static func == (lhs: ParsedElement, rhs: ParsedElement) -> Bool {
        lhs.position == rhs.position && lhs.length == rhs.length && lhs.text == rhs.text
    }
    
    var position: Int
    let length: Int
    let text: String
    let reference: String
    
    init(position: Int, length: Int, text: String, reference: String) {
        self.position = position
        self.length = length
        self.text = text
        self.reference = reference
    }
}

final class ParsedUser: Hashable {
    var data: PrimalUser
    var profileImage: MediaMetadata.Resource
    var followers: Int?
    
    init(data: PrimalUser, profileImage: MediaMetadata.Resource? = nil, followers: Int? = nil) {
        self.data = data
        self.profileImage = profileImage ?? .init(url: data.picture, variants: [])
        self.followers = followers
    }
    
    init(imageURL: String) {
        self.data = .init(pubkey: "empty")
        self.profileImage = .init(url: imageURL, variants: [])
    }
    
    static func == (lhs: ParsedUser, rhs: ParsedUser) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
        hasher.combine(profileImage)
    }
}

extension PrimalFeedPost {
    var isArticle: Bool { kind == NostrKind.longForm.rawValue || kind == NostrKind.shortenedArticle.rawValue }
}

enum NotFoundContent: Hashable {
    case note, article
}

final class ParsedContent: Hashable {
    let uniqueID: String = UUID().uuidString
    
    var post: PrimalFeedPost
    let user: ParsedUser
    
    init(post: PrimalFeedPost, user: ParsedUser) {
        self.post = post
        self.user = user
    }
    
    var hashtags: [ParsedElement] = []
    var mentions: [ParsedElement] = []
//    var notes: [ParsedElement] = []
    var httpUrls: [ParsedElement] = []
    var highlights: [ParsedElement] = []
    var zaps: [ParsedZap] = []
    
    var highlightEvents: [ParsedContent] = []
    
    var mediaResources: [MediaMetadata.Resource] = []
    var videoThumbnails: [String: String] = [:]
    var linkPreviews: [LinkMetadata] = []
    var article: Article?
    
    var invoice: Invoice?
    
    var text: String = ""
    var attributedText: NSAttributedString = NSAttributedString(string: "")
    var attributedTextShort: NSAttributedString = NSAttributedString(string: "")
    
    var embeddedPosts: [ParsedContent] = []
    var embeddedZap: ParsedFeedZap?
    var embeddedLive: ParsedLiveEvent?
    var reposted: ParsedRepost?
    
    var mentionedUsers: [PrimalUser] = []
    
    var replyingTo: ParsedContent?
    
    var notFound: NotFoundContent?
    
    var customEvent: ParsedContent?
    
    static func == (lhs: ParsedContent, rhs: ParsedContent) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(post)
        hasher.combine(user)
        hasher.combine(reposted)
        hasher.combine(uniqueID)
    }
}

struct ParsedRepost: Hashable {
    var users: [ParsedUser]
    var date: Date
    var id: String
    
    var user: ParsedUser? { users.first }
}

extension ParsedUser: MetadataCoding {
    func webURL() -> String {
        if let name = PremiumCustomizationManager.instance.getPremiumName(pubkey: data.pubkey) {
            return "https://primal.net/\(name)"
        }
        
        var metadata = Metadata()
        metadata.pubkey = data.pubkey
        if let identifier = try? encodedIdentifier(with: metadata, identifierType: .profile) {
            return "https://primal.net/p/\(identifier)"
        }

        return "https://primal.net/p/\(data.npub)"
    }
    
    var isCurrentUser: Bool { data.isCurrentUser }
    
    var followersSafe: Int { followers ?? 0 }
}

enum ParsedContentTextStyle {
    case regular, enlarged, threadChildren, notifications, embedded
    
    var maximumLineHeight: CGFloat {
        switch self {
        case .regular, .threadChildren, .notifications, .embedded:
            return FontSizeSelection.current.contentLineHeight
        case .enlarged:
            return FontSizeSelection.current.contentLineHeight + 2
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .regular, .threadChildren, .notifications, .embedded:
            return FontSizeSelection.current.contentFontSize
        case .enlarged:
            return FontSizeSelection.current.contentFontSize + 2
        }
    }
    
    var color: UIColor {
        switch self {
        case .regular, .enlarged, .threadChildren, .embedded:
            return .foreground
        case .notifications:
            return .foreground2
        }
    }
}

extension ParsedContent {
    func buildContentString(style: ParsedContentTextStyle = .regular) {
        attributedText = contentStringForText(text: text, style: style)
        if attributedText.length > 550 {
            attributedTextShort = attributedText.attributedSubstring(from: .init(location: 0, length: 500))
        } else {
            attributedTextShort = attributedText
        }
    }
    
    func contentStringForText(text: String, style: ParsedContentTextStyle = .regular) -> NSAttributedString {
        let specialStyle: Bool = ContentDisplaySettings.hugeFonts && {
            switch style {
            case .threadChildren, .notifications, .embedded:
                return false
            default:
                break
            }
            
            if !highlights.isEmpty {
                let highlightLengthCount = highlights.reduce(0, { $0 + $1.length })
                
                if text.count - highlightLengthCount > 42 {
                    return false
                }
                return text.filter({ $0.isNewline }).count < 2
            }
            
            if text.count > 42 {
                return false
            }
            
            return !text.contains(where: { $0.isNewline })
        }()
        
        let fs = FontSizeSelection.current
        let paragraph = NSMutableParagraphStyle()
        
        var fontSize = style.fontSize
        if specialStyle {
            switch FontSizeSelection.current {
            case .small:
                fontSize = 20
                paragraph.maximumLineHeight = 25
            case .standard:
                fontSize = 21
                paragraph.maximumLineHeight = 26
            case .large:
                fontSize = 24
                paragraph.maximumLineHeight = 28
            case .huge:
                fontSize = 26
                paragraph.maximumLineHeight = 30
            }
        } else {
            paragraph.lineSpacing = fs.contentLineSpacing
            paragraph.maximumLineHeight = style.maximumLineHeight
        }
        
        let result = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: style.color,
            .font: UIFont.appFont(withSize: fontSize, weight: .regular),
            .paragraphStyle: paragraph,
            .baselineOffset: specialStyle ? 4 : 0
        ])
        
        for element in httpUrls where element.position + element.length <= result.length {
            guard let url = URL(string: element.reference) else {
                result.addAttributes([
                    .foregroundColor: UIColor.accent2.withAlphaComponent(0.5),
                ], range: .init(location: element.position, length: element.length))
                continue
            }
            result.addAttributes([
                .foregroundColor: UIColor.accent2,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
//        for element in notes where element.position + element.length <= result.length {
//            guard let url = URL(string: "note://\(element.reference)") else {
//                result.addAttributes([
//                    .foregroundColor: UIColor.accent2.withAlphaComponent(0.5)
//                ], range: .init(location: element.position, length: element.length))
//                continue
//            }
//            result.addAttributes([
//                .foregroundColor: UIColor.accent2,
//                .link: url
//            ], range: .init(location: element.position, length: element.length))
//        }
        
        for element in mentions where element.position + element.length <= result.length {
            guard let url = URL(string: "mention://\(element.reference)") else {
                result.addAttributes([
                    .foregroundColor: UIColor.accent2.withAlphaComponent(0.5)
                ], range: .init(location: element.position, length: element.length))
                continue
            }
            result.addAttributes([
                .foregroundColor: UIColor.accent2,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
        for element in hashtags where element.position + element.length <= result.length {
            guard let url = URL(string: "hashtag://\(element.text)") else {
                result.addAttributes([
                    .foregroundColor: UIColor.accent2.withAlphaComponent(0.5)
                ], range: .init(location: element.position, length: element.length))
                continue
            }
            result.addAttributes([
                .foregroundColor: UIColor.accent2,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
        for element in highlights where element.position + element.length <= result.length {
            let newParagraph = NSMutableParagraphStyle()
            newParagraph.lineSpacing = 0
            newParagraph.minimumLineHeight = 28
            newParagraph.maximumLineHeight = 28
            
            result.addAttributes([
                .font: UIFont.appFont(withSize: style.fontSize, weight: .regular),
                .foregroundColor: UIColor.foreground,
                .backgroundColor: UIColor.highlight,
                .link: URL(string: "highlight://\(element.reference)"),
                .paragraphStyle: newParagraph
            ], range: .init(location: element.position, length: element.length))
        }
        
//        for (index, element) in notes.reversed().enumerated() where element.position + element.length <= result.length {
//            result.replaceCharacters(in: .init(location: element.position, length: element.length), with: "Mentioned Note \(index + 1)")
//        }
     
        return result
    }
    
    func noteId(extended: Bool) -> String {
        var metadata = Metadata()
        let hint = RelayHintManager.instance.getRelayHint(post.id)
        if extended && !hint.isEmpty {
            metadata.relays = [hint]
        }
        
        if post.kind == NostrKind.longForm.rawValue {
            metadata.kind = UInt32(post.kind)
            metadata.pubkey = user.data.pubkey
            metadata.identifier = post.tags.first(where: { $0.first == "d" })?[safe: 1]
            
            if let identifier = try? encodedIdentifier(with: metadata, identifierType: .address) {
                return identifier
            }
        }
        
        metadata.eventId = post.id
        if let identifier = try? encodedIdentifier(with: metadata, identifierType: .event) {
            return identifier
        }
        return (post.kind == NostrKind.longForm.rawValue ? getATagID() : nil) ?? bech32_note_id(post.id) ?? post.id
    }
    
    func webURL() -> String {
        guard
            post.kind == NostrKind.longForm.rawValue,
            let name = PremiumCustomizationManager.instance.getPremiumName(pubkey: user.data.pubkey),
            let dTag = post.tags.first(where: { $0.first == "d" })?[safe: 1]
        else {
            return "https://primal.net/e/\(noteId(extended: false))"
        }
        return "https://primal.net/\(name)/\(dTag)"
    }
    
    var isEmpty: Bool {
        post.isEmpty || user.data.id.isEmpty
    }
}

extension ParsedContent: MetadataCoding {
    func getATagID() -> String? {
        guard
            post.kind == NostrKind.longForm.rawValue,
            let tagId = post.tags.first(where: { $0.first == "d" })?[safe: 1]
        else { return bech32_note_id(post.id) }
        
        var metadata = Metadata(identifier: tagId)
        metadata.pubkey = post.pubkey
        metadata.kind = UInt32(NostrKind.longForm.rawValue)

        return try? encodedIdentifier(with: metadata, identifierType: .address)
    }
}

extension NostrContent: MetadataCoding {
    func getNevent() -> String? {
        try? encodedIdentifier(with: Metadata(pubkey: pubkey, eventId: id, kind: UInt32(kind)), identifierType: .event)
    }
}

extension ParsedContent {
    func copy() -> ParsedContent {
        let new = ParsedContent(post: post, user: user)
        new.hashtags = hashtags
        new.mentions = mentions
//        new.notes = notes
        new.httpUrls = httpUrls
        
        new.mediaResources = mediaResources
        new.videoThumbnails = videoThumbnails
        new.linkPreviews = linkPreviews
        
        new.invoice = invoice
        
        new.text = text
        new.attributedText = attributedText
        new.attributedTextShort = attributedTextShort
        
        new.zaps = zaps
        
        new.embeddedPosts = embeddedPosts
        new.reposted = reposted
        new.embeddedZap = embeddedZap
        new.customEvent = customEvent
        
        new.mentionedUsers = mentionedUsers
        
        new.replyingTo = replyingTo        
        return new
    }
}
