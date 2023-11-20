//
//  ParsedContent.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.5.23..
//

import Foundation
import UIKit
import LinkPresentation

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
}

final class ParsedContent {
    var post: PrimalFeedPost
    let user: ParsedUser
    
    init(post: PrimalFeedPost, user: ParsedUser) {
        self.post = post
        self.user = user
    }
    
    // array of dictionaries where key is position and value is length
    var hashtags: [ParsedElement] = []
    var mentions: [ParsedElement] = []
    var notes: [ParsedElement] = []
    var httpUrls: [ParsedElement] = []
    
    var imageResources: [MediaMetadata.Resource] = []
    var linkPreview: LinkMetadata?
    
    var text: String = ""
    var attributedText: NSAttributedString = NSAttributedString(string: "")
    
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
}

extension ParsedContent {
    func buildContentString(enlarge: Bool = false) {
        let enlargingAmount: CGFloat = 2
        
        let fs = FontSizeSelection.current
        let style = NSMutableParagraphStyle()
        style.lineSpacing = fs.contentLineSpacing
        style.maximumLineHeight = fs.contentLineHeight + (enlarge ? enlargingAmount : 0)
        
        let result = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: fs.contentFontSize + (enlarge ? enlargingAmount : 0), weight: .regular),
            .paragraphStyle: style
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
        
        attributedText = result
    }
    
    func webURL() -> String {
        guard let note = bech32_note_id(post.id) else {
            return "https://primal.net/e/\(post.id)"
        }
        return "https://primal.net/e/\(note)"
    }
}
