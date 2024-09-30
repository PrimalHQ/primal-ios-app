//
//  SearchHeaderView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 20.6.23..
//

import UIKit

final class SearchHeaderView: MyButton, Themeable {
    let label = UILabel()
    let icon = UIImageView(image: UIImage(named: "searchIconSmall"))
    
    init() {
        super.init(frame: .zero)
        
        constrainToSize(height: 32)
        let width = widthAnchor.constraint(equalToConstant: 255)
        width.priority = .defaultHigh
        width.isActive = true
        
        layer.cornerRadius = 16
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.alignment = .center
        stack.spacing = 8
        
        addSubview(stack)
        stack.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 12)
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        label.text = "search nostr"
        label.font = .appFont(withSize: 16, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
        label.textColor = .foreground4
        icon.tintColor = .foreground4
    }
}
