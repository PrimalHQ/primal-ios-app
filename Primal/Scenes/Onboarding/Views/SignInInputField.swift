//
//  SignInInputField.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.23..
//

import UIKit

final class SignInInputField: UIView {
    private lazy var textView = SelfSizingTextView()
    private lazy var placeholderLabel = UILabel()
    private lazy var secureTextLabel = UILabel()
    private lazy var correctBorder = UIView()
    private lazy var incorrectBorder = UIView()
    
    private var fixHeightConstraint: NSLayoutConstraint?
    
    var didBeginEditing: (UITextView) -> () = { _ in }
    var didEndEditing: (UITextView) -> () = { _ in }
    var didChange: (UITextView) -> () = { _ in }
    
    var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            
            guard textView.isHidden else { return }
            placeholderLabel.isHidden = !newValue.isEmpty
            secureTextLabel.isHidden = newValue.isEmpty
        }
    }
    
    var isCorrect: Bool? {
        didSet {
            guard let isCorrect else {
                incorrectBorder.isHidden = true
                correctBorder.isHidden = true
                return
            }
            incorrectBorder.isHidden = isCorrect
            correctBorder.isHidden = !isCorrect
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubview(incorrectBorder)
        incorrectBorder.pinToSuperview(padding: 2)
        incorrectBorder.layer.borderColor = UIColor(rgb: 0xC40000).cgColor
        incorrectBorder.layer.borderWidth = 2
        incorrectBorder.layer.cornerRadius = 22
        incorrectBorder.isHidden = true
        
        addSubview(correctBorder)
        correctBorder.pinToSuperview()
        correctBorder.layer.borderColor = UIColor(rgb: 0x52CE0A).cgColor
        correctBorder.layer.borderWidth = 3
        correctBorder.layer.cornerRadius = 24
        correctBorder.isHidden = true
        
        textView.font = .appFont(withSize: 16, weight: .medium)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.delegate = self
        addSubview(textView)
        textView.pinToSuperview(edges: .horizontal, padding: 10).pinToSuperview(edges: .vertical, padding: 3)
        textView.isHidden = true
        
        placeholderLabel.font = .appFont(withSize: 18, weight: .medium)
        placeholderLabel.text = "nsec / npub"
        placeholderLabel.textColor = .black.withAlphaComponent(0.5)
        addSubview(placeholderLabel)
        placeholderLabel.pinToSuperview(edges: .leading, padding: 15).centerToSuperview(axis: .vertical)
        
        secureTextLabel.text = "••••••••••••••••••••••••••••••••••••••••••"
        secureTextLabel.font = .appFont(withSize: 30, weight: .heavy)
        secureTextLabel.adjustsFontSizeToFitWidth = true
        secureTextLabel.textColor = .black
        secureTextLabel.isHidden = true
        addSubview(secureTextLabel)
        secureTextLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 15)
        
        backgroundColor = .white
        layer.cornerRadius = 24
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        fixHeightConstraint = heightAnchor.constraint(equalToConstant: 48)
        fixHeightConstraint?.isActive = true
        
        addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak textView] in
            textView?.becomeFirstResponder()
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
}

extension SignInInputField: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        fixHeightConstraint?.isActive = false
        textView.isHidden = false
        textView.invalidateIntrinsicContentSize()
        
        secureTextLabel.isHidden = true
        placeholderLabel.isHidden = true
        
        didBeginEditing(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        fixHeightConstraint?.isActive = true
        textView.isHidden = true
        
        secureTextLabel.isHidden = textView.text.isEmpty
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        didEndEditing(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        didChange(textView)
        textView.invalidateIntrinsicContentSize()
    }
}
