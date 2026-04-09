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
        constrainToSize(56)
        updateTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        var config = UIButton.Configuration.filled()
        if #available(iOS 26.0, *) {
            config = UIButton.Configuration.glass()
        }
        
        config.image = UIImage(named: "addPostPlus")?.withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .foreground
        config.baseBackgroundColor = .accent
        config.cornerStyle = .capsule
        configuration = config
    }
}
