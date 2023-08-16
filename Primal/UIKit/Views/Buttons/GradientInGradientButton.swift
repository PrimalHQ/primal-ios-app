//
//  GradientInGradientButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import UIKit

final class GradientInGradientButton: MyButton {
    
    private let borderGradient = GradientBorderView(
        gradientColors: UIColor.gradient.withAlphaComponent(0.75),
        backgroundColor: UIColor.gradient.first!
    )
    private let innerGradient = GradientView(colors: UIColor.gradient)
    let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        
        addSubview(borderGradient)
        borderGradient.pinToSuperview()
        
        borderGradient.backgroundView.addSubview(innerGradient)
        innerGradient.pinToSuperview()
        
        addSubview(titleLabel)
        titleLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 8)
        titleLabel.textColor = .white
        titleLabel.font = .appFont(withSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = title
        
        borderGradient.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
