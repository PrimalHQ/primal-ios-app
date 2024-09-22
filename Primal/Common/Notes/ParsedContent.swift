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

final class ParsedElement: Equatable {
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

final class ParsedUser {
    var data: PrimalUser
    var profileImage: MediaMetadata.Resource
    var likes: Int?
    var followers: Int?
    
    init(data: PrimalUser, profileImage: MediaMetadata.Resource? = nil, likes: Int? = nil, followers: Int? = nil) {
        self.data = data
        self.profileImage = profileImage ?? .init(url: data.picture, variants: [])
        self.likes = likes
        self.followers = followers
    }
    
    init(imageURL: String) {
        self.data = .init(pubkey: "empty")
        self.profileImage = .init(url: imageURL, variants: [])
    }
}

extension PrimalFeedPost {
    var isArticle: Bool { kind == NostrKind.longForm.rawValue || kind == NostrKind.shortenedArticle.rawValue }
}

final class ParsedContent {
    var post: PrimalFeedPost
    let user: ParsedUser
    
    init(post: PrimalFeedPost, user: ParsedUser) {
        self.post = post
        self.user = user
    }
    
    var hashtags: [ParsedElement] = []
    var mentions: [ParsedElement] = []
    var notes: [ParsedElement] = []
    var httpUrls: [ParsedElement] = []
    var highlights: [ParsedElement] = []
    var zaps: [ParsedZap] = []
    
    var highlightEvents: [ParsedContent] = []
    
    var mediaResources: [MediaMetadata.Resource] = []
    var videoThumbnails: [String: String] = [:]
    var linkPreview: LinkMetadata?
    var article: Article?
    
    var invoice: Invoice?
    
    var text: String = ""
    var attributedText: NSAttributedString = NSAttributedString(string: "")
    var attributedTextShort: NSAttributedString = NSAttributedString(string: "")
    
    var embededPost: ParsedContent?
    var reposted: ParsedRepost?
    
    var mentionedUsers: [PrimalUser] = []
    
    var replyingTo: ParsedContent?
}

struct ParsedRepost {
    var users: [ParsedUser]
    var date: Date
    var id: String
    
    var user: ParsedUser? { users.first }
}

extension ParsedUser {
    func webURL() -> String {
        "https://primal.net/p/\(data.npub)"
    }
    
    var isCurrentUser: Bool { data.isCurrentUser }
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
        let specialStyle: Bool = ContentDisplaySettings.hugeFonts && {
            switch style {
            case .threadChildren, .notifications, .embedded:
                return false
            default:
                break
            }
            
            let mainText = highlights.reversed().reduce(text, { ($0 as NSString).replacingCharacters(in: .init(location: $1.position, length: $1.length), with: "") })
            
            if mainText.count > 42 {
                return false
            }
            
            return !mainText.contains(where: { $0.isNewline })
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
        
        for element in httpUrls {
            guard let url = URL(string: element.text) else { continue }
            result.addAttributes([
                .foregroundColor: UIColor.accent,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
        for element in notes {
            guard let url = URL(string: "note://\(element.text)") else {
                result.addAttributes([
                    .foregroundColor: UIColor.accent.withAlphaComponent(0.5)
                ], range: .init(location: element.position, length: element.length))
                continue
            }
            result.addAttributes([
                .foregroundColor: UIColor.accent,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
        for element in mentions {
            guard let url = URL(string: "mention://\(element.reference)") else {
                result.addAttributes([
                    .foregroundColor: UIColor.accent.withAlphaComponent(0.5)
                ], range: .init(location: element.position, length: element.length))
                continue
            }
            result.addAttributes([
                .foregroundColor: UIColor.accent,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
        for element in hashtags {
            guard let url = URL(string: "hashtag://\(element.text)") else {
                result.addAttributes([
                    .foregroundColor: UIColor.accent.withAlphaComponent(0.5)
                ], range: .init(location: element.position, length: element.length))
                continue
            }
            result.addAttributes([
                .foregroundColor: UIColor.accent,
                .link: url
            ], range: .init(location: element.position, length: element.length))
        }
        
        for element in highlights {
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
        
        attributedText = result
        if result.length > 1200 {
            attributedTextShort = result.attributedSubstring(to: 1000)
        } else {
            attributedTextShort = result
        }
    }
    
    func noteId() -> String {
        post.kind == NostrKind.longForm.rawValue ?
            getATagID() ?? bech32_note_id(post.id) ?? post.id
          : bech32_note_id(post.id) ?? post.id
    }
    
    func webURL() -> String { "https://primal.net/e/\(noteId())" }
    
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
        new.notes = notes
        new.httpUrls = httpUrls
        
        new.mediaResources = mediaResources
        new.videoThumbnails = videoThumbnails
        new.linkPreview = linkPreview
        
        new.invoice = invoice
        
        new.text = text
        new.attributedText = attributedText
        new.attributedTextShort = attributedTextShort
        
        new.embededPost = embededPost
        new.reposted = reposted
        
        new.mentionedUsers = mentionedUsers
        
        new.replyingTo = replyingTo        
        return new
    }
}
