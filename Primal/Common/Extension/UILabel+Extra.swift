//
//  UILabel+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.5.23..
//

import UIKit

extension UILabel {
    convenience init(_ text: String, color: UIColor, font: UIFont, multiline: Bool = false) {
        self.init(frame: .zero)
        self.text = text
        self.textColor = color
        self.font = font
        self.numberOfLines = multiline ? 0 : 1
        if multiline {
            textAlignment = .center
        }
    }
    
    func countLabelLines() -> Int {
        let myText = (text ?? "") as NSString
        let attributes: [NSAttributedString.Key : Any] = [.font : font!]
        
        let width = bounds.width < 1 ? 315 : bounds.width
        
        let labelSize = myText.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
    
    func isTruncated() -> Bool {
        guard numberOfLines > 0 else { return false }
        return countLabelLines() > numberOfLines
    }
}
