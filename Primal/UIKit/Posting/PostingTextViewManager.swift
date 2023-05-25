//
//  PostingTextViewManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import Combine
import UIKit

final class PostingTextViewManager: NSObject {
    @Published var isEditing = false
    
    var didChangeEvent = PassthroughSubject<UITextView, Never>()
}

extension PostingTextViewManager: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditing = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.invalidateIntrinsicContentSize() // Necessary for self sizing text field
        didChangeEvent.send(textView)
    }
}
