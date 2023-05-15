//
//  GradientView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.5.23..
//

import UIKit

class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    var colors: [UIColor] {
        set { gradientLayer.colors = newValue.map { $0.cgColor } }
        get { [] }
    }
    
    init(colors: [UIColor]) {
        super.init(frame: .zero)
        
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = .init(x: 0.5, y: 0)
        gradientLayer.endPoint = .init(x: 0.5, y: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
