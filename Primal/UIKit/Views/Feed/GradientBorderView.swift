//
//  GradientBorderView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.5.23..
//

import UIKit

final class GradientBorderView: GradientView {
    override var backgroundColor: UIColor? {
        get { backgroundView.backgroundColor }
        set { backgroundView.backgroundColor = newValue }
    }
    
    let backgroundView = UIView()
    
    var cornerRadius: CGFloat {
        get { backgroundView.layer.cornerRadius }
        set {
            gradientLayer.cornerRadius = newValue
            backgroundView.layer.cornerRadius = newValue - borderWidth
        }
    }
    
    var borderWidth: CGFloat { // Defaults to 1
        get {
            -(backgroundSizeConstraints.first?.constant ?? 0) / 2 }
        set {
            for constraint in backgroundSizeConstraints {
                constraint.constant = -newValue * 2
            }
        }
    }
    
    var backgroundSizeConstraints: [NSLayoutConstraint] = []
    
    init(gradientColors: [UIColor], backgroundColor: UIColor, cornerRadius: CGFloat = 0) {
        super.init(colors: gradientColors)
        setup()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(backgroundView)
        backgroundView.centerToSuperview()
        backgroundView.clipsToBounds = true
        backgroundSizeConstraints = [
            backgroundView.heightAnchor.constraint(equalTo: heightAnchor, constant: -2),
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor, constant: -2)
        ]
        NSLayoutConstraint.activate(backgroundSizeConstraints)
        
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint = .init(x: 1, y: 1)
    }
}
