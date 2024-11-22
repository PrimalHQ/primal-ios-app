//
//  RoundedSmallButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class RoundedSmallButton: MyButton, Themeable {
    private let label = UILabel()
    
    init(text: String, font: UIFont = .appFont(withSize: 16, weight: .semibold), horizontalPadding: CGFloat = 16) {
        super.init(frame: .zero)
        
        addSubview(label)
        label.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal, padding: horizontalPadding)
        label.font = font
        label.text = text
        label.textAlignment = .center
        
        constrainToSize(height: 36)
        layer.cornerRadius = 18
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isPressed: Bool {
        didSet {
            label.alpha = isPressed ? 0.5 : 1
        }
    }
    
    func updateTheme() {
        backgroundColor = .background3
        label.textColor = .foreground
    }
}
