//
//  PlaceholderTextView.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.10.23..
//

import UIKit

final class PlaceholderTextView: SelfSizingTextView {
    
    var placeholderTextColor: UIColor = .foreground.withAlphaComponent(0.6) {
        didSet {
            if realText == placeholderText {
                textColor = placeholderTextColor
            }
        }
    }
    
    var mainTextColor: UIColor = .foreground {
        didSet {
            if realText != placeholderText {
                textColor = mainTextColor
            }
        }
    }
    
    var placeholderText: String? {
        didSet {
            if realText.isEmpty {
                text = placeholderText
                textColor = placeholderTextColor
            } else {
                textColor = mainTextColor
            }
        }
    }
    
    var didBeginEditing: (UITextView) -> () = { _ in }
    
    override var text: String! {
        set {
            let newValue = (newValue?.isEmpty != false ? placeholderText : newValue) ?? ""
            super.text = newValue
            textColor = newValue == placeholderText ? placeholderTextColor : mainTextColor
        }
        get {
            let real = realText
            return real == placeholderText ? "" : real
        }
    }
    
    private var realText: String {
        get { super.text ?? "" }
        set { super.text = newValue }
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaceholderTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if realText == placeholderText {
            realText = ""
        }
        textColor = mainTextColor
        didBeginEditing(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if realText.isEmpty {
            textView.text = placeholderText
            textView.textColor = placeholderTextColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
}
