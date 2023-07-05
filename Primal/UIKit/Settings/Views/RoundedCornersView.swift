//
//  RoundedCornersView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.6.23..
//

import UIKit

enum Corners {
    case top, bottom
}

final class RoundedCornersView: UIView {
    let topView = UIView()
    let bottomView = UIView()
    let backgroundMaskView = SpacerView(height: 30)
    
    override var backgroundColor: UIColor? {
        set {
            topView.backgroundColor = newValue
            bottomView.backgroundColor = newValue
            backgroundMaskView.backgroundColor = newValue
        }
        get { topView.backgroundColor }
    }
    
    var roundedCorners: Corners? {
        didSet {
            updateCorners()
        }
    }
    
    var cornerRadius: CGFloat {
        didSet {
            updateCorners()
            backgroundMaskView.heightConstraint?.constant = cornerRadius * 2
        }
    }
    
    init(rounded: Corners? = nil, radius: CGFloat) {
        roundedCorners = rounded
        cornerRadius = radius
        backgroundMaskView.heightConstraint?.constant = radius * 2
        
        super.init(frame: .zero)
        
        addSubview(backgroundMaskView)
        backgroundMaskView.pinToSuperview(edges: .horizontal).centerToSuperview()
        
        let stack = UIStackView(arrangedSubviews: [topView, bottomView])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    func updateCorners() {
        switch roundedCorners {
        case nil:
            topView.layer.cornerRadius = 0
            bottomView.layer.cornerRadius = 0
        case .top:
            topView.layer.cornerRadius = cornerRadius
            bottomView.layer.cornerRadius = 0
        case .bottom:
            bottomView.layer.cornerRadius = cornerRadius
            topView.layer.cornerRadius = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
