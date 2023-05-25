//
//  ShowNsecButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class ShowNsecButton: MyButton, Themeable {
    private let icon = UIImageView()
    private let label = UILabel()
    
    var isVisible = false {
        didSet {
            updateView()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        icon.image = UIImage(named: "visibleIcon")
        
        label.font = .appFont(withSize: 18, weight: .medium)
        
        let borderGradient = GradientBorderView(
            gradientColors: [
                UIColor(rgb: 0xFA4343).withAlphaComponent(0.85),
                UIColor(rgb: 0x5B12A4).withAlphaComponent(0.85)
            ],
            backgroundColor: .black
        )
        
        addSubview(borderGradient)
        borderGradient.pinToSuperview()
        borderGradient.cornerRadius = 8
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        addSubview(stack)
        stack.centerToSuperview()
        stack.spacing = 8
        stack.alignment = .center
        
        constrainToSize(height: 48)
        
        updateView()
    }
    
    func updateView() {
        label.text = isVisible ? "Hide private key" : "Show private key"
        icon.image = isVisible ? UIImage(named: "hiddenIcon") : UIImage(named: "visibleIcon")
    }
    
    func updateTheme() {
        label.textColor = .init(rgb: 0xCCCCCC)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
