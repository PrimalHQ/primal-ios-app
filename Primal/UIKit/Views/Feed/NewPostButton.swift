//
//  NewPostButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.8.23..
//

import UIKit

class NewPostButton: UIButton, Themeable {
    init() {
        super.init(frame: .zero)
        
        setImage(UIImage(named: "addPostPlus"), for: .normal)
        constrainToSize(56)
        updateTheme()
        layer.cornerRadius = 28
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .gradientColor(
            bounds: .init(width: 56, height: 56),
            startPoint: .zero,
            endPoint: .init(x: 1, y: 1)
        )
    }
}
