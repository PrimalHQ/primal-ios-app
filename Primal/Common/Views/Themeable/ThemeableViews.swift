//
//  ThemeableLabel.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class ThemeableLabel: UILabel, Themeable {
    @discardableResult
    func setTheme(_ theme: @escaping (ThemeableLabel) -> Void) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableLabel) -> Void = { _ in } {
        didSet {
            theme(self)
        }
    }
    
    func updateTheme() {
        theme(self)
    }
    
    convenience init(_ text: String? = nil, textColor: (() -> UIColor)? = nil, font: UIFont) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        if let textColor {
            setTheme { $0.textColor = textColor() }
        }
    }
}

final class ThemeableView: UIView, Themeable {
    func setTheme(_ theme: @escaping (ThemeableView) -> Void) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableView) -> Void = { _ in } {
        didSet {
            theme(self)
        }
    }
    
    func updateTheme() {
        theme(self)
    }
}

final class ThemeableImageView: UIImageView, Themeable {
    @discardableResult
    func setTheme(_ theme: @escaping (ThemeableImageView) -> Void) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableImageView) -> Void = { _ in } {
        didSet {
            theme(self)
        }
    }
    
    func updateTheme() {
        theme(self)
    }
}

final class ThemeableButton: UIButton, Themeable {
    func setTheme(_ theme: @escaping (ThemeableButton) -> Void) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableButton) -> Void = { _ in } {
        didSet {
            theme(self)
        }
    }
    
    func updateTheme() {
        theme(self)
    }
}
