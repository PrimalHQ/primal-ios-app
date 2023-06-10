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
        
        Connection.instance.request(.object([
            "user_search": .object([
                "query": .string("A"),
                "limit": .number(15),
                "pubkey": .string(IdentityManager.instance.userHex)
            ])
        ])) { result in
            print(result)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.invalidateIntrinsicContentSize() // Necessary for self sizing text field
        didChangeEvent.send(textView)
    }
}
