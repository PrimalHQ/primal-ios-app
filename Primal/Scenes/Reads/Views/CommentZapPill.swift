//
//  CommentZapPill.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.6.24..
//

import UIKit

extension UIButton.Configuration {
    static func longFormEventButton(image: UIImage?, title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.image = image?.withRenderingMode(.alwaysTemplate).withTintColor(.foreground3).withRenderingMode(.alwaysOriginal)
        config.imagePadding = 4

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 9, bottom: 0, trailing: 9)

        config.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        return config
    }
}

class CommentZapPill: UIView, Themeable {
    let commentButton = UIButton()
    let zapButton = UIButton()
    
    var comments: Int = 0 { didSet { updateTheme() } }
    var sats: Int = 0 { didSet { updateTheme() } }
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([commentButton, zapButton])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 9).pinToSuperview(edges: .vertical)
        stack.spacing = 4
        
        commentButton.setContentHuggingPriority(.required, for: .horizontal)
        zapButton.setContentHuggingPriority(.required, for: .horizontal)
        zapButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        commentButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        layer.cornerRadius = 24
        layer.borderWidth = 1
        constrainToSize(height: 48)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    func updateTheme() {
        commentButton.configuration = .longFormEventButton(image: UIImage(named: "feedComment"), title: comments.localized())
        zapButton.configuration = .longFormEventButton(image: UIImage(named: "feedZap"), title: sats.localized())
        
        layer.borderColor = UIColor.foreground6.cgColor
        backgroundColor = UIColor.background
    }
}
