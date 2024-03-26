//
//  InterestSelectionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import UIKit

final class InterestSelectionView: MyButton {
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = UIColor(rgb: 0x222222).withAlphaComponent(isSelected ? 1 : 0.4)
        }
    }
    
    let label = UILabel()
    
    init(name: String, isSelected: Bool) {
        super.init(frame: .zero)
        
        label.text = name
        
        self.isSelected = isSelected
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview()
        
        label.textColor = .white
        label.font = .appFont(withSize: 18, weight: .medium)
        
        constrainToSize(height: 36)
        layer.cornerRadius = 18
    }
}
