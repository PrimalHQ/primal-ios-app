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

    private let glassView: UIVisualEffectView?

    init() {
        if #available(iOS 26.0, *) {
            glassView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        } else {
            glassView = nil
        }
        super.init(frame: .zero)

        let stack = UIStackView([commentButton, zapButton])
        stack.spacing = 4

        if let glassView {
            glassView.tintColor = .background
            glassView.layer.cornerRadius = 24
            glassView.clipsToBounds = true
            addSubview(glassView)
            glassView.pinToSuperview()
            glassView.contentView.addSubview(stack)
        } else {
            addSubview(stack)
            layer.borderWidth = 1
        }
        stack.pinToSuperview(edges: .horizontal, padding: 9).pinToSuperview(edges: .vertical)

        commentButton.setContentHuggingPriority(.required, for: .horizontal)
        zapButton.setContentHuggingPriority(.required, for: .horizontal)
        zapButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        commentButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        layer.cornerRadius = 24
        clipsToBounds = true
        constrainToSize(height: 48)

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        commentButton.configuration = .longFormEventButton(image: UIImage(named: "feedComment"), title: comments.localized())
        zapButton.configuration = .longFormEventButton(image: UIImage(named: "feedZap"), title: sats.localized())

        if let glassView {
            backgroundColor = .background.withAlphaComponent(0.3)
            glassView.overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        } else {
            layer.borderColor = UIColor.foreground6.cgColor
            backgroundColor = .background
        }
    }
}
