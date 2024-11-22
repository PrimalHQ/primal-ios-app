//
//  UIButtonConfiguration.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.2.24..
//

import UIKit

extension UIButton.Configuration {
    static func roundedIconAccent(_ image: UIImage?) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .accent
        configuration.image = image
        return configuration
    }
    
    static func simpleImage(_ name: String) -> UIButton.Configuration {
        simpleImage(UIImage(named: name))
    }
    
    static func simpleImage(_ image: UIImage?) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.image = image
        return configuration
    }
    
    func noMargins() -> UIButton.Configuration {
        var config = self
        config.contentInsets = .zero
        return config
    }
    
    static func accent(_ text: String, font: UIFont = UIFont.appFont(withSize: 16, weight: .regular)) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init(text, attributes: AttributeContainer([
            .font: font
        ]))
        configuration.baseForegroundColor = .accent2
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
