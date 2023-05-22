//
//  SpacerView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.5.23..
//

import UIKit

final class SpacerView: UIView {
    init(size: CGFloat? = nil, priority: UILayoutPriority = .defaultHigh) {
        super.init(frame: .zero)
        guard let size else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let heightC = heightAnchor.constraint(equalToConstant: size)
        heightC.priority = priority
        heightC.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
