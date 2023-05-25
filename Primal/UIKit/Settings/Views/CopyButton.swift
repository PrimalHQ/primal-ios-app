//
//  CopyButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class CopyButton: MyButton {
    private let icon = UIImageView()
    private let label = UILabel()
    
    let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        icon.image = UIImage(named: "copyIcon")
        
        label.text = title
        label.font = .appFont(withSize: 18, weight: .medium)
        label.textColor = .white
        
        let borderGradient = GradientBorderView(
            gradientColors: [
                UIColor(rgb: 0xFA4343).withAlphaComponent(0.85),
                UIColor(rgb: 0x5B12A4).withAlphaComponent(0.85)
            ],
            backgroundColor: .black
        )
        let innerGradient = GradientView(colors: [
            UIColor(rgb: 0xFA4343).withAlphaComponent(0.5),
            UIColor(rgb: 0x5B12A4).withAlphaComponent(0.5)
        ])
        
        addSubview(borderGradient)
        borderGradient.pinToSuperview()
        
        borderGradient.backgroundView.addSubview(innerGradient)
        innerGradient.pinToSuperview()
        
        borderGradient.cornerRadius = 8
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        addSubview(stack)
        stack.centerToSuperview()
        stack.spacing = 12
        stack.alignment = .center
        
        constrainToSize(height: 48)
    }
    
    func animateCopied() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.icon.image = UIImage(named: "checkmark")
            self.label.text = "Copied"
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
                    self.icon.image = UIImage(named: "copyIcon")
                    self.label.text = self.title
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
