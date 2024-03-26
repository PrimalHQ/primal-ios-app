//
//  UITextView+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.6.23..
//

import UIKit

extension UITextView {
    func scrollToCursorPosition() {
        guard let cursorPos = selectedTextRange?.start else { return }
        let caret = caretRect(for: cursorPos)
        scrollRectToVisible(caret, animated: true)
    }
    
    func convertToNSRange( _ startPosition: UITextPosition, _ endPosition: UITextPosition) -> NSRange? {
        let startOffset = offset(from: beginningOfDocument, to: startPosition)
        let endOffset = offset(from: beginningOfDocument, to: endPosition)
        let length = endOffset - startOffset
        guard length >= 0, startOffset >= 0 else {
            return nil
        }
        return NSRange(location: startOffset, length: length)
    }
}
