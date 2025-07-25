//
//  LiveVideoChatInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 23. 7. 2025..
//

import UIKit

extension UIButton.Configuration {
    static func liveSendButton(enabled: Bool) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.image = .sendMessage.withTintColor(enabled ? .foreground : .foreground5)
        config.cornerStyle = .capsule
        config.baseForegroundColor = enabled ? .foreground : .foreground5
        config.background.backgroundColor = enabled ? .background4 : .foreground6
        return config
    }
}

class LiveVideoChatInputView: UIView {
    let textView = PlaceholderTextView()
    let sendButton = UIButton(configuration: .liveSendButton(enabled: false)).constrainToSize(40)
    
    private let backgroundView = UIView()
    private lazy var postStack = UIStackView([backgroundView, sendButton])
    
    var leftConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    
    var showSendButton = true {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0.1) {
                self.sendButton.alpha = self.showSendButton ? 1 : 0
            }
            
            leftConstraint?.constant = showSendButton ? 12 : 20
            rightConstraint?.constant = showSendButton ? 10 : 20
            
            UIView.animate(withDuration: 0.2) { [self] in
                sendButton.isHidden = !showSendButton
                layoutIfNeeded()
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .background
        
        postStack.alignment = .bottom
        postStack.spacing = 8
        
        addSubview(postStack)
        postStack.pinToSuperview(edges: .vertical, padding: 12)
        leftConstraint = postStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 12)
        leftConstraint?.isActive = true
        rightConstraint = rightAnchor.constraint(equalTo: postStack.rightAnchor, constant: 10)
        rightConstraint?.isActive = true
        
        backgroundView.pinToSuperview(edges: .vertical)
        backgroundView.layer.cornerRadius = 20
        backgroundView.backgroundColor = .background3
        backgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        backgroundView.heightAnchor.constraint(lessThanOrEqualToConstant: 84).isActive = true
        
        addSubview(textView)
        textView
            .pinToSuperview(edges: .top, padding: 13)
            .pinToSuperview(edges: .bottom, padding: 11)
            .pin(to: backgroundView, edges: .leading, padding: 10)
            .pin(to: backgroundView, edges: .trailing, padding: 10)
        textView.backgroundColor = .clear
        textView.font = .appFont(withSize: 16, weight: .regular)
        textView.mainTextColor = .foreground
        textView.placeholderTextColor = .foreground4
        textView.placeholderText = "Chat..."
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
