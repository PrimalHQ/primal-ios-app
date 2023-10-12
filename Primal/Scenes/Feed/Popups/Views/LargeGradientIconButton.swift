//
//  LargeGradientIconButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.7.23..
//

import UIKit

final class LargeGradientIconButton: MyButton {
    private let icon = UIImageView()
    private let label = UILabel()
    
    let title: String
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    init(title: String, icon: UIImage? = nil) {
        self.title = title
        super.init(frame: .zero)
        
        if let icon {
            self.icon.image = icon
        } else {
            self.icon.isHidden = true
        }
        
        label.text = title
        label.font = .appFont(withSize: 20, weight: .semibold)
        label.textColor = .white
        
        let gradient = GradientView(colors: UIColor.gradient)
        
        addSubview(gradient)
        gradient.pinToSuperview()
        
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)
        
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [self.icon, label])
        addSubview(stack)
        stack.centerToSuperview()
        stack.spacing = 12
        stack.alignment = .center
        
        constrainToSize(height: 48)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
