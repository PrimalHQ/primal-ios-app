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
    
    init(position: Int, length: Int, text: String) {
        self.position = position
        self.length = length
        self.text = text
    }
}

final class ParsedContent {
    let post: PrimalFeedPost
    let user: PrimalUser
    
    init(post: PrimalFeedPost, user: PrimalUser) {
        self.post = post
        self.user = user
    }
    
    // array of dictionaries where key is position and value is length
    var hashtags: [ParsedElement] = []
    var mentions: [ParsedElement] = []
    var notes: [ParsedElement] = []
    var httpUrls: [ParsedElement] = []
    
    var imageResources: [MediaMetadata.Resource] = []
    var firstExtractedURL: URL?
    
    @Published var parsedMetadata: LinkMetadata?
    
    var text: String = ""
    var attributedText: NSAttributedString = NSAttributedString(string: "")
    
    var embededPost: ParsedContent?
    var reposted: PrimalUser?
}

extension ParsedContent {
    var elements: [ParsedElement] { httpUrls + notes + mentions + hashtags }
    
    func buildContentString() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        
        let result = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .paragraphStyle: style
        ])
        
        for element in elements {
            result.addAttributes([
                .foregroundColor: UIColor.accent
            ], range: .init(location: element.position, length: element.length))
        }
        
        attributedText = result
    }
}
