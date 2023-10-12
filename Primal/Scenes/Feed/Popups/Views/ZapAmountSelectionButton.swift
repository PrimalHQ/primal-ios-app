//
//  ZapAmountSelectionButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 5.7.23..
//

import UIKit

final class ZapAmountSelectionButton: MyButton, Themeable {
    private let emojiLabel = UILabel()
    private let label = UILabel()
    
    let gradient = GradientView(colors: UIColor.gradient)
    let gradientCover = UIView()
    
    var title: String {
        didSet {
            label.text = title
        }
    }
    
    var emoji: String {
        didSet {
            emojiLabel.text = emoji
        }
    }
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    var zapSelected = true {
        didSet {
            gradient.isHidden = !zapSelected
        }
    }
    
    init(emoji: String, title: String) {
        self.title = title
        self.emoji = emoji
        super.init(frame: .zero)
        
        emojiLabel.text = emoji
        emojiLabel.font = .appFont(withSize: 28, weight: .heavy)
        
        label.text = title
        label.font = .appFont(withSize: 20, weight: .semibold)
        label.textColor = .white
        
        addSubview(gradient)
        gradient.pinToSuperview()
        gradient.addSubview(gradientCover)
        gradientCover.pinToSuperview(padding: 1)
        gradientCover.layer.cornerRadius = 7
        
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [emojiLabel, label])
        addSubview(stack)
        stack.centerToSuperview()
        stack.spacing = 8
        stack.alignment = .center
        stack.axis = .vertical
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        gradientCover.backgroundColor = .background2
        backgroundColor = .background3
        label.textColor = .foreground
    }
}
