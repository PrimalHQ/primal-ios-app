//
//  ThemeableLabel.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class ThemeableLabel: UILabel, Themeable {
    @discardableResult
    func setTheme(_ theme: @escaping (ThemeableLabel) -> ()) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableLabel) -> () = { _ in } {
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
    func setTheme(_ theme: @escaping (ThemeableView) -> ()) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableView) -> () = { _ in } {
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
    func setTheme(_ theme: @escaping (ThemeableImageView) -> ()) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableImageView) -> () = { _ in } {
        didSet {
            theme(self)
        }
    }
    
    func updateTheme() {
        theme(self)
    }
}

final class ThemeableButton: UIButton, Themeable {
    func setTheme(_ theme: @escaping (ThemeableButton) -> ()) -> Self {
        self.theme = theme
        return self
    }
    
    var theme: (ThemeableButton) -> () = { _ in } {
        didSet {
            theme(self)
        }
    }
    
    func updateTheme() {
        theme(self)
    }
}
