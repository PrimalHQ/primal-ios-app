//
//  GradientSettingsButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 18.6.23..
//

import UIKit

final class GradientSettingsButton: MyButton {
    private let icon = UIImageView()
    private let label = UILabel()
    
    let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        icon.image = UIImage(named: "copyIcon")
        icon.isHidden = true
        
        label.text = title
        label.font = .appFont(withSize: 18, weight: .medium)
        label.textColor = .white
        
        let gradient = GradientView(colors: UIColor.gradient)
        
        addSubview(gradient)
        gradient.pinToSuperview()
        
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
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
