//
//  OnboardingInputParent.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.11.23..
//

import UIKit

final class OnboardingInputParent: UIView {
    init(input: UIView) {
        super.init(frame: .zero)
        
        addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 15).centerToSuperview(axis: .vertical)
        
        backgroundColor = .white.withAlphaComponent(0.8)
        layer.cornerRadius = 24
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc func tapped() {
        guard let textInput: UITextField = findAllSubviews().first else { return }
        textInput.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
