//
//  CheckboxRadioButton.swift
//  Primal
//
//  Created by Pavle Stevanović on 11. 12. 2025..
//

import UIKit

class CheckboxRadioButton: MyButton, Themeable {
    
    let imageView = UIImageView().constrainToSize(width: 12, height: 10)
    let circleView = UIView().constrainToSize(20)
    
    var accent = true {
        didSet {
            updateTheme()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateTheme()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        updateTheme()
        
        circleView.layer.cornerRadius = 10
        imageView.tintColor = .white
        
        addSubview(circleView)
        circleView.centerToSuperview()
        addSubview(imageView)
        imageView.centerToSuperview()
    }
    
    func updateTheme() {
        
        if isSelected {
            imageView.tintColor = accent ? .white : .background
            imageView.image = .checkboxLarge.withRenderingMode(.alwaysTemplate)
            circleView.backgroundColor = accent ? .accent : .foreground
            circleView.layer.borderWidth = 0
        } else {
            imageView.image = nil
            circleView.backgroundColor = .background
            circleView.layer.borderWidth = 1
            circleView.layer.borderColor = UIColor.foreground5.cgColor
        }
    }
}
