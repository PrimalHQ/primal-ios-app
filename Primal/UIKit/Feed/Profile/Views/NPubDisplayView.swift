//
//  NPubDisplayView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

class NPubDisplayView: MyButton, Themeable {
    
    var npub = "" {
        didSet {
            label.text = "\(String(npub.prefix(14)))...\(String(npub.suffix(10)))"
        }
    }
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    private let copy = UIImageView(image: UIImage(named: "purpleCopy"))
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(arrangedSubviews: [
            UIImageView(image: UIImage(named: "keySmall")),
            SpacerView(width: 6),
            label,
            SpacerView(width: 8),
            copy,
            UIView()
        ])
        stack.alignment = .center
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .foreground5
        
        addSubview(stack)
        stack.pinToSuperview()
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        copy.tintColor = .accent
    }
}
