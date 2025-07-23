//
//  SimpleHelperViews.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit

final class PullBarView: UIView {
    let pullBar = UIView()
    
    init(color: UIColor = .foreground.withAlphaComponent(0.8)) {
        super.init(frame: .zero)
        addSubview(pullBar)
        pullBar.backgroundColor = color
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal).constrainToSize(width: 65, height: 4)
        pullBar.layer.cornerRadius = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
