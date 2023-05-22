//
//  ColorAnimatingLabel.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.5.23..
//

import UIKit

final class ColorAnimatingLabel: UIView {
    var font: UIFont {
        get { frontLabel.font }
        set {
            frontLabel.font = newValue
            backLabel.font = newValue
        }
    }
    
    var text: String? {
        get { frontLabel.text }
        set {
            frontLabel.text = newValue
            backLabel.text = newValue
        }
    }
    
    var textColor: UIColor {
        get { frontLabel.textColor }
        set {
            frontLabel.textColor = newValue
            backLabel.textColor = newValue
        }
    }
    
    private let backLabel = UILabel()
    private let frontLabel = UILabel()
    
    func animateToColor(color: UIColor) {
        backLabel.textColor = color
        UIView.animate(withDuration: 1) {
            self.frontLabel.alpha = 0
        } completion: { finished in
            if finished {
                self.frontLabel.textColor = color
                self.frontLabel.alpha = 1
            }
        }
    }
    
    init(title: String? = nil) {
        super.init(frame: .zero)
        addSubview(backLabel)
        addSubview(frontLabel)
        backLabel.pinToSuperview()
        frontLabel.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
