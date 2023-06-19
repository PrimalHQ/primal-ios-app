//
//  ConnectAlbyButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.6.23..
//

import UIKit

final class ConnectAlbyButton: MyButton {
    var title: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
    
    private let icon = UIImageView(image: UIImage(named: "albyIcon"))
    private let label = UILabel()
    init() {
        super.init(frame: .zero)
        
        label.text = "Connect Alby Wallet"
        label.font = .appFont(withSize: 18, weight: .medium)
        label.textColor = .black
        
        let gradient = GradientView(colors: [.init(rgb: 0xFFDF6F), .init(rgb: 0xCF7828)])
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)
        
        addSubview(gradient)
        gradient.pinToSuperview()
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        
        addSubview(stack)
        stack.centerToSuperview()
        stack.alignment = .center
        stack.spacing = 6
        
        constrainToSize(height: 48)
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
}
