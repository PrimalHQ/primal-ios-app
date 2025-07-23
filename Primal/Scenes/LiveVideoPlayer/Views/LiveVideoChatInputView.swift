//
//  LiveVideoChatInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 23. 7. 2025..
//

import UIKit

class LiveVideoChatInputView: UIView {
    let backgroundView = UIView()
    let textView = PlaceholderTextView()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .background
        
        addSubview(backgroundView)
        backgroundView.pinToSuperview(edges: .vertical, padding: 12).pinToSuperview(edges: .horizontal, padding: 20)
        backgroundView.layer.cornerRadius = 20
        backgroundView.backgroundColor = .background3
        backgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        backgroundView.heightAnchor.constraint(lessThanOrEqualToConstant: 84).isActive = true
        
        addSubview(textView)
        textView
            .pinToSuperview(edges: .top, padding: 13)
            .pinToSuperview(edges: .bottom, padding: 11)
            .pinToSuperview(edges: .trailing, padding: 30)
            .pinToSuperview(edges: .leading, padding: 30)
        textView.backgroundColor = .clear
        textView.font = .appFont(withSize: 16, weight: .regular)
        textView.mainTextColor = .foreground
        textView.placeholderTextColor = .foreground4
        textView.placeholderText = "Chat..."
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
