//
//  GradientBorderTextButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class GradientBorderTextButton: MyButton, Themeable {
    private let gradient = GradientBorderView(
        gradientColors: UIColor.gradient.withAlphaComponent(0.85),
        backgroundColor: .background,
        cornerRadius: 8
    )
    
    private let label = UILabel()
    
    init(text: String) {
        super.init(frame: .zero)
     
        gradient.backgroundView.addSubview(label)
        label.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal, padding: 16)
        label.font = .appFont(withSize: 14, weight: .medium)
        label.text = text
        
        addSubview(gradient)
        gradient.pinToSuperview()
        constrainToSize(height: 36)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    func updateTheme() {
        gradient.backgroundColor = .background
        label.textColor = .foreground
    }
}
