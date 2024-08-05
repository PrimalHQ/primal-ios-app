//
//  ArticleSelectionMenuView.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.7.24..
//

import UIKit

extension UIButton.Configuration {
    static func articleSelectionMenuButton(name: String, image: UIImage?) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = .init(name, attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]))
        config.image = image?.withTintColor(.foreground).withRenderingMode(.alwaysOriginal)
        config.imagePadding = 8
        config.imagePlacement = .top
        config.background.backgroundColor = .background3
        config.background.cornerRadius = 4
        config.contentInsets = .zero
        return config
    }
    
    static func articleSelectionMenuButtonSelected(name: String, image: UIImage?) -> UIButton.Configuration {
        var config = articleSelectionMenuButton(name: name, image: image)
        config.background.backgroundColor = .foreground6
        return config
    }
}

class ArticleSelectionMenuView: UIView, Themeable {
    let highlight = UIButton()
    let quote = UIButton()
    let comment = UIButton()
    let copy = UIButton()
    
    let triangle = UIImageView(image: UIImage(named: "bottomTriangle"))
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([highlight, quote, comment, copy])
        stack.spacing = 5
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.pinToSuperview(padding: 4)
        
        let buttonConfigs: [(UIButton, String, String)] = [
            (highlight, "Highlight", "highlightIcon24"),
            (quote, "Quote", "quoteIcon24"),
            (comment, "Comment", "commentIcon24"),
            (copy, "Copy", "copyIcon24")
        ]
        
        buttonConfigs.forEach { (button, name, image) in
            let image = UIImage(named: image)
            button.configurationUpdateHandler = { button in
                button.configuration = button.isHighlighted ?
                    .articleSelectionMenuButtonSelected(name: name, image: image) : .articleSelectionMenuButton(name: name, image: image)
            }
        }
        
        constrainToSize(height: 70)
        updateTheme()
        layer.cornerRadius = 8
        
        addSubview(triangle)
        triangle.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: -8)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    func updateTheme() {
        [highlight, quote, comment, copy].forEach { $0.setNeedsUpdateConfiguration() }
        backgroundColor = .background3
        triangle.tintColor = .background3
    }
}
