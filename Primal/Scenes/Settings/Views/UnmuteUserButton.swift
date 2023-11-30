//
//  UnmuteUserButton.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.9.23..
//

import UIKit

final class UnmuteUserButton: MyButton, Themeable {
    let titleLabel = UILabel()
    
    override var isPressed: Bool {
        didSet {
            titleLabel.textColor = isPressed ? .darkGray : .white
        }
    }
    
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(titleLabel)
        titleLabel.centerToSuperview()
        
        titleLabel.text = "unmute"
        titleLabel.font = .appFont(withSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        
        constrainToSize(width: 72, height: 32)
        
        updateTheme()
        
        layer.borderWidth = 1
        layer.cornerRadius = 6
    }
    
    func updateTheme() {
        backgroundColor = .background
        titleLabel.textColor = .foreground
        layer.borderColor = UIColor.accent.cgColor
    }
}
