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
    
    let borderView = UIView()
    let backgroundView = UIView()
    
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
            borderView.isHidden = !zapSelected
        }
    }
    
    init(emoji: String, title: String) {
        self.title = title
        self.emoji = emoji
        super.init(frame: .zero)
        
        emojiLabel.text = emoji
        emojiLabel.font = .appFont(withSize: 20, weight: .black)
        
        label.text = title
        label.font = .appFont(withSize: 18, weight: .semibold)
        label.textColor = .white
        
        addSubview(borderView)
        borderView.pinToSuperview()
        borderView.addSubview(backgroundView)
        backgroundView.pinToSuperview(padding: 1)
        backgroundView.layer.cornerRadius = 43
        
        constrainToSize(88)
        layer.cornerRadius = 44
        layer.masksToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [emojiLabel, label])
        addSubview(stack)
        stack.centerToSuperview()
        stack.spacing = 8
        stack.alignment = .center
        stack.axis = .vertical
        stack.isUserInteractionEnabled = false
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        borderView.backgroundColor = .accent
        backgroundView.backgroundColor = .background2
        backgroundColor = .background3
        label.textColor = .foreground
    }
}
