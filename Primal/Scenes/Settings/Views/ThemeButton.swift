//
//  ThemeButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.8.23..
//

import UIKit

final class ThemeButton: MyButton, Themeable {
    let theme: Theme
    
    private let themeIndicator: ThemeIndicator
    private let label = UILabel()
    
    init(theme: Theme) {
        self.theme = theme
        themeIndicator = ThemeIndicator(theme: theme)
        
        super.init(frame: .zero)
        
        let stack = UIStackView(axis: .vertical, [themeIndicator, label])
        
        addSubview(stack)
        stack.pinToSuperview()
        stack.spacing = 8
        
        label.text = theme.theme.shortTitle
        label.textAlignment = .center
        
        themeIndicator.heightAnchor.constraint(equalTo: themeIndicator.widthAnchor).isActive = true
        
        updateTheme()
        
        addAction(.init(handler: { _ in
            Theme.defaultTheme = theme.theme
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        label.textColor = .foreground2
        
        label.font = .appFont(withSize: 16, weight: .regular)
    }
}

final class ThemeIndicator: UIView, Themeable {
    let theme: Theme
    
    let checkboxBackground = UIImageView(image: UIImage(named: "themeCheckboxBackground"))
    let checkbox = UIImageView(image: UIImage(named: "themeCheckbox"))
    
    init(theme: Theme) {
        self.theme = theme
        super.init(frame: .zero)
        
        let image = UIImageView(image: theme.theme.settingsImage)
        addSubview(image)
        image.centerToSuperview()
        
        addSubview(checkboxBackground)
        checkboxBackground.pinToSuperview(edges: [.trailing, .bottom])
        checkboxBackground.addSubview(checkbox)
        checkbox.centerToSuperview()
        
        layer.cornerRadius = 8
        layer.borderWidth = 1
        
        checkboxBackground.tintColor = theme.theme.gradient.last
        
        backgroundColor = theme.theme.background
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentDefault = Theme.defaultTheme ?? Theme.current
        if theme == currentDefault.kind {
            let size: CGSize = bounds.size.width < 1 ? .init(width: 70, height: 70) : bounds.size
            layer.borderColor = UIColor.gradientColor(
                theme.theme.gradient,
                bounds: size,
                startPoint: .init(x: 0, y: 1),
                endPoint: .init(x: 1, y: 0)
            )?.cgColor
        }
    }
    
    func updateTheme() {
        let currentDefault = Theme.defaultTheme ?? Theme.current
        if theme == currentDefault.kind {
            checkboxBackground.isHidden = false
            layoutSubviews()
        } else {
            checkboxBackground.isHidden = true
            layer.borderColor = UIColor.foreground6.cgColor
        }
    }
}
