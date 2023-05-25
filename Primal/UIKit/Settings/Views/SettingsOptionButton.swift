//
//  SettingsOptionButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class SettingsOptionButton: MyButton, Themeable {
    let label = UILabel()
    let icon = UIImageView(image: UIImage(named: "chevron"))
    let border = UIView()
    
    override var isPressed: Bool {
        didSet {
            updateTheme()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview(axis: .vertical)
        
        addSubview(icon)
        icon.pinToSuperview(edges: .trailing, padding: 21).centerToSuperview(axis: .vertical)
        
        addSubview(border)
        border.pinToSuperview(edges: [.bottom, .horizontal]).constrainToSize(height: 1)
        
        label.font = .appFont(withSize: 20, weight: .bold)
        label.text = title
        
        updateTheme()
        
        constrainToSize(height: 60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        label.textColor = isPressed ? .foreground.withAlphaComponent(0.5) : .foreground
        border.backgroundColor = .background3
    }
}
