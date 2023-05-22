//
//  ParsedContent.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.5.23..
//

import Foundation
import UIKit

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
    // array of dictionaries where key is position and value is length
    var hashtags: [ParsedElement] = []
    var mentions: [ParsedElement] = []
    var notes: [ParsedElement] = []
    var httpUrls: [ParsedElement] = []
    
    var imageUrls: [URL] = []
    var firstExtractedURL: URL?
    
    var text: String = ""
    var attributedText: NSAttributedString = NSAttributedString(string: "")
}

extension ParsedContent {
    var elements: [ParsedElement] { httpUrls + notes + mentions + hashtags }
    
    func buildContentString() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        
        let result = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .paragraphStyle: style
        ])
        
        for element in elements {
            result.addAttributes([
                .foregroundColor: UIColor(rgb: 0xCA079F)
            ], range: .init(location: element.position, length: element.length))
        }
        
        attributedText = result
    }
}
