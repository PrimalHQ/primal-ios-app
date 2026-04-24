//
//  NewPostButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.8.23..
//

import UIKit

class NewPostButton: UIButton, Themeable {
    private var isExcited = false
    
    init() {
        super.init(frame: .zero)
        constrainToSize(56)
        updateTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        var config = UIButton.Configuration.filled()
        if #available(iOS 26.0, *) {
            config = UIButton.Configuration.glass()
        }

        config.image = UIImage(named: "addPostPlus")?.withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .foreground
        config.baseBackgroundColor = .accent
        config.cornerStyle = .capsule
        configuration = config
    }

    func setHidden(_ hidden: Bool, animated: Bool) {
        isExcited = false
        
        guard animated else {
            isHidden = hidden
            alpha = 1
            transform = .identity
            return
        }

        if hidden {
            UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
                self.transform = .init(scaleX: 0.2, y: 0.2)
                self.isHidden = true
            }
        } else {
            alpha = 0
            transform = .init(scaleX: 0.2, y: 0.2)
            isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
                self.transform = .identity
            }
        }
    }
    
    func setIsExcited(_ excited: Bool) {
        guard isExcited != excited, !isHidden else { return }
        
        isExcited = excited
        
        UIView.animate(withDuration: 0.1) {
            self.transform = excited ? .init(scaleX: 0.9, y: 0.9) : .identity
        }
    }
}
