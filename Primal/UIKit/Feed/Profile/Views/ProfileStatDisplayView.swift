//
//  ProfileStatDisplayView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

class ProfileStatDisplayView: UIView {
    let infoLabel = UILabel()
    
    init(_ title: String) {
        super.init(frame: .zero)
        
        let titleLabel = UILabel()
        let stack = UIStackView(arrangedSubviews: [infoLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        
        infoLabel.font  = .appFont(withSize: 28, weight: .regular)
        infoLabel.textColor = .foreground
        infoLabel.text = "0"
        
        titleLabel.font = .appFont(withSize: 14, weight: .light)
        titleLabel.textColor = .foreground5
        titleLabel.text = title
        
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
