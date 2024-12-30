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
        let font = font ?? .appFont(withSize: 16, weight: .regular)
        
        let myText = (text ?? "") as NSString
        let attributes: [NSAttributedString.Key : Any] = [.font : font]
        
        let width = frame.width < 10 ? 335 : frame.width
        
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
    
    // MARK: - Builder Pattern
    @discardableResult
    func setText(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func setFont(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func setMultiline() -> Self {
        textAlignment = .center
        numberOfLines = 0
        return self
    }
    
    @discardableResult
    func setLineSpacing(_ spacing: CGFloat) -> Self {
        
        return self
    }
}
