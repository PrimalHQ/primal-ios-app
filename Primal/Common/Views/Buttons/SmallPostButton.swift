//
//  SmallPostButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import UIKit

final class SmallPostButton: UIButton, Themeable {
//    let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        
//        addSubview(titleLabel)
//        titleLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 8)
        
//        titleLabel.textAlignment = .center
//        titleLabel.adjustsFontSizeToFitWidth = true
//        titleLabel.text = title
        
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 14, weight: .medium)
        
        constrainToSize(height: 28)
        layer.cornerRadius = 14
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            updateTheme()
        }
    }
    
    func updateTheme() {
        backgroundColor = isEnabled ? .accent : .background3
        setTitleColor(isEnabled ? .white : .foreground5, for: .normal)
    }
}
