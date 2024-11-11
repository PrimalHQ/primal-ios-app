//
//  BrightSmallButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

final class BrightSmallButton: MyButton, Themeable {
    var title: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
    
    override var isEnabled: Bool {
        didSet {
            label.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    private let label = UILabel()
    init(title: String, font: UIFont = .appFont(withSize: 16, weight: .semibold)) {
        super.init(frame: .zero)
        
        label.text = title
        label.font = font
        label.textAlignment = .center
        
        addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 26)
        
        constrainToSize(height: 36)
        
        layer.masksToBounds = true
        layer.cornerRadius = 18
        
        updateTheme()
    }
    
    override var isPressed: Bool {
        didSet {
            label.alpha = isPressed ? 0.5 : 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .foreground
        label.textColor = .background
    }
}
