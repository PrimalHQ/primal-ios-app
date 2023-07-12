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
}
