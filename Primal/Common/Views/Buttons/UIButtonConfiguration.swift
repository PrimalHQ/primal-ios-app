//
//  UIButtonConfiguration.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.2.24..
//

import UIKit

extension UIButton.Configuration {
    static func simpleImage(_ image: UIImage?) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.image = image
        return configuration
    }
    
    static func accent(_ text: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init(text, attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 16, weight: .regular)
        ]))
        configuration.baseForegroundColor = .accent
        return configuration
    }
    
    static func gray(_ text: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init(text, attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ]))
        configuration.baseForegroundColor = .foreground3
        return configuration
    }
}
