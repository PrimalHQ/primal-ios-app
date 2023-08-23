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
    
    init(data: PrimalUser, profileImage: MediaMetadata.Resource? = nil, likes: Int? = nil) {
        self.data = data
        self.profileImage = profileImage ?? .init(url: data.picture, variants: [])
        self.likes = likes
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
}

struct ParsedRepost {
    var user: ParsedUser
    var date: Date
}

extension ParsedUser {
    func webURL() -> String {
        "https://primal.net/p/\(data.npub)"
    }
}

extension ParsedContent {
    func buildContentString() {
        let fs = FontSizeSelection.current
        let style = NSMutableParagraphStyle()
        style.lineSpacing = fs.contentLineSpacing
        style.maximumLineHeight = fs.contentLineHeight
        
        let result = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: fs.contentFontSize, weight: .regular),
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
            guard let url = URL(string: "mention://\(element.text)") else {
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
        "https://primal.net/e/\(post.id)"
    }
}
