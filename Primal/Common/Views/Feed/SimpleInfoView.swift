//
//  SimpleInfoView.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.24..
//

import UIKit

class SimpleInfoView: UIView, Themeable {
    enum Kind {
        case warning, file
    }
    
    private let icon = UIImageView()
    private let label = UILabel()
    init() {
        super.init(frame: .zero)
        let stack = UIStackView([icon, label])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 16)
        stack.spacing = 8
        stack.alignment = .center
        
        layer.cornerRadius = 8
        
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.font = .appFont(withSize: 16, weight: .regular)
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func set(kind: Kind, text: String) {
        label.text = text
        switch kind {
        case .warning:
            icon.image = UIImage(named: "warningIcon")
        case .file:
            icon.image = UIImage(named: "fileIcon")
        }
    }
    
    func updateTheme() {
        backgroundColor = .background5
        label.textColor = .foreground
        icon.tintColor = .foreground4
    }
}
