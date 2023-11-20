//
//  CircleIconButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class CircleIconButton: MyButton, Themeable {
    private let iconView = UIImageView()
    
    override var isPressed: Bool { didSet { iconView.alpha = isPressed ? 0.5 : 1 } }
    
    init(icon: UIImage?) {
        super.init(frame: .zero)
     
        iconView.image = icon
        addSubview(iconView)
        iconView.centerToSuperview()
        
        constrainToSize(36)
        layer.cornerRadius = 18
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
        iconView.tintColor = .foreground
    }
}
