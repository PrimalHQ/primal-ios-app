//
//  GradientBorderIconButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class GradientBorderIconButton: MyButton, Themeable {
    private let gradient = GradientBorderView(
        gradientColors: UIColor.gradient.withAlphaComponent(0.85),
        backgroundColor: .background,
        cornerRadius: 8
    )
    
    private let iconView = UIImageView()
    
    init(icon: UIImage?) {
        super.init(frame: .zero)
     
        iconView.image = icon
        gradient.backgroundView.addSubview(iconView)
        iconView.centerToSuperview()
        
        addSubview(gradient)
        gradient.pinToSuperview()
        constrainToSize(36)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        gradient.backgroundColor = .background
    }
}
