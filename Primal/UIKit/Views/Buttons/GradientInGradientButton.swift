//
//  GradientInGradientButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import UIKit

final class GradientInGradientButton: MyButton {
    var cornerRadius: CGFloat {
        get { borderGradient.cornerRadius }
        set { borderGradient.cornerRadius = newValue }
    }
    
    private let borderGradient = GradientBorderView(
        gradientColors: [
            UIColor(rgb: 0xFA4343).withAlphaComponent(0.75),
            UIColor(rgb: 0x5B12A4).withAlphaComponent(0.75)
        ],
        backgroundColor: UIColor(rgb: 0xFA4343)
    )
    private let innerGradient = GradientView(colors: [UIColor(rgb: 0xFA4343),UIColor(rgb: 0x5B12A4)])
    let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        
        addSubview(borderGradient)
        borderGradient.pinToSuperview()
        
        borderGradient.backgroundView.addSubview(innerGradient)
        innerGradient.pinToSuperview()//padding: 1)
        
        addSubview(titleLabel)
        titleLabel.centerToSuperview()
        titleLabel.textColor = .white
        titleLabel.font = .appFont(withSize: 16, weight: .medium)
        titleLabel.text = title
        
        borderGradient.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
