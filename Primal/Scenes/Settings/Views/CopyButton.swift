//
//  CopyButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class CopyButton: MyButton, Themeable {
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
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        addSubview(stack)
        stack.centerToSuperview()
        stack.spacing = 12
        stack.alignment = .center
        
        constrainToSize(height: 48)
        updateTheme()
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
    
    func updateTheme() {        
        backgroundColor = .accent
    }
}
