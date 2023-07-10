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
    
    var leftBorder = UIView()
    lazy var leftBorderWidthC = leftBorder.widthAnchor.constraint(equalToConstant: 0)
    
    var rightBorder = UIView()
    lazy var rightBorderWidthC = rightBorder.widthAnchor.constraint(equalToConstant: 0)
    
    var borderColor: UIColor {
        get { .black }
        set {
            topView.layer.borderColor = newValue.cgColor
            bottomView.layer.borderColor = newValue.cgColor
            leftBorder.backgroundColor = newValue
            rightBorder.backgroundColor = newValue
        }
    }
    
    var borderWidth: CGFloat {
        get { leftBorderWidthC.constant }
        set {
//            leftBorderWidthC.constant = newValue
//            rightBorderWidthC.constant = newValue
//            topView.layer.borderWidth = newValue
//            bottomView.layer.borderWidth = newValue
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
        
        backgroundMaskView.addSubview(leftBorder)
        backgroundMaskView.addSubview(rightBorder)
        leftBorder.pinToSuperview(edges: [.leading, .vertical])
        rightBorder.pinToSuperview(edges: [.trailing, .vertical])
        
        NSLayoutConstraint.activate([leftBorderWidthC, rightBorderWidthC])
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
