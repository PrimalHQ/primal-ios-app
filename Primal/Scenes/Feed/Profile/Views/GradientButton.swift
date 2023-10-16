//
//  GradientButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class GradientButton: MyButton, Themeable {
    var title: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    private let gradient = GradientView(colors: UIColor.gradient)
    private let label = UILabel()
    init(title: String, font: UIFont = .appFont(withSize: 14, weight: .medium)) {
        super.init(frame: .zero)
        
        label.text = title
        label.font = font
        label.textColor = .white
        
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)
        
        addSubview(gradient)
        gradient.pinToSuperview()
        
        addSubview(label)
        label.centerToSuperview()
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    override var isPressed: Bool {
        didSet {
            label.alpha = isPressed ? 0.5 : 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        gradient.colors = UIColor.gradient
    }
}
