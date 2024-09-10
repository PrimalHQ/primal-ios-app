//
//  RoundedInputField.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.11.23..
//

import UIKit

final class RoundedInputField: UIView, Themeable {
    let input = UITextField()
    
    var text: String {
        get { input.text ?? "" }
        set { input.text = newValue }
    }
    
    var delegate: UITextFieldDelegate? {
        get { input.delegate }
        set { input.delegate = newValue }
    }
    
    var placeholder: String? {
        get { input.placeholder }
        set { input.placeholder = newValue }
    }
    
    init(placeholder: String? = nil, icon: UIImage? = nil) {
        super.init(frame: .zero)
        
        input.placeholder = placeholder
        input.font = .appFont(withSize: 18, weight: .regular)
        input.returnKeyType = .done
        
        addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        
        constrainToSize(height: 40)
        layer.cornerRadius = 20
        
        addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.input.becomeFirstResponder()
        }))
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool { input.becomeFirstResponder() }
    
    @discardableResult override func resignFirstResponder() -> Bool { input.resignFirstResponder() }
    
    func updateTheme() {
        input.textColor = .foreground
        
        backgroundColor = .background3
    }
}
