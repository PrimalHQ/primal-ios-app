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
        
        if #available(iOS 26.0, *) {
            var config = UIButton.Configuration.glass()
            config.image = .addPostPlus
            config.cornerStyle = .capsule
            configuration = config
        } else {
            setImage(.addPostPlus, for: .normal)
            layer.cornerRadius = 28
            tintColor = .white
        }
        
        constrainToSize(56)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        if #available(iOS 26.0, *) {
            tintColor = .foregroundAutomatic
        } else {
            backgroundColor = .accent
        }
    }
}
