//
//  SpacerView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.5.23..
//

import UIKit

final class SpacerView: UIView {
    init(width: CGFloat? = nil, height: CGFloat? = nil, priority: UILayoutPriority = .defaultHigh) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        if let width {
            let widthC = widthAnchor.constraint(equalToConstant: width)
            widthC.priority = priority
            widthC.isActive = true
        }
        
        if let height {
            let heightC = heightAnchor.constraint(equalToConstant: height)
            heightC.priority = priority
            heightC.isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
