//
//  NPubDisplayView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

class NPubDisplayView: MyButton {
    
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
    
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(arrangedSubviews: [
            UIImageView(image: UIImage(named: "keySmall")),
            SpacerView(width: 6),
            label,
            SpacerView(width: 8),
            UIImageView(image: UIImage(named: "purpleCopy")),
            UIView()
        ])
        stack.alignment = .center
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .foreground5
        
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
