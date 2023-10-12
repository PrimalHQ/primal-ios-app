//
//  ProfileLinkDisplayView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

class ProfileLinkDisplayView: UIView {
    var link = "" {
        didSet {
            label.text = link
        }
    }
    
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(arrangedSubviews: [
            UIImageView(image: UIImage(named: "linkIcon")),
            SpacerView(width: 8),
            label
        ])
        stack.alignment = .center
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .accent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
