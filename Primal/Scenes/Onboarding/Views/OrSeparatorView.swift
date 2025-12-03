//
//  OrSeparatorView.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 11. 2025..
//

import UIKit

class OrSeparatorView: UIStackView {
    init() {
        super.init(frame: .zero)
        
        let border1 = SpacerView(height: 1, color: .white.withAlphaComponent(0.4))
        let border2 = SpacerView(height: 1, color: .white.withAlphaComponent(0.4))
        let orLabel = UILabel("or", color: .white, font: .appFont(withSize: 16, weight: .semibold))
        
        [border1, orLabel, border2].forEach { addArrangedSubview($0) }
        
        border1.widthAnchor.constraint(equalTo: border2.widthAnchor).isActive = true
        
        spacing = 12
        alignment = .center
        
        orLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
