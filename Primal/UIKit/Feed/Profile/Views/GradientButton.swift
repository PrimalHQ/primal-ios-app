//
//  GradientButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class GradientButton: MyButton {
    let label = UILabel()
    init(title: String) {
        super.init(frame: .zero)
        
        label.text = title
        label.font = .appFont(withSize: 14, weight: .medium)
        label.textColor = .white
        
        let gradient = GradientView(colors: UIColor.gradient)
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)
        
        addSubview(gradient)
        gradient.pinToSuperview()
        
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 30).centerToSuperview(axis: .vertical)
        
        constrainToSize(height: 36)
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
