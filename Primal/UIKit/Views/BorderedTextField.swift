//
//  BorderedTextField.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import UIKit

final class BorderedTextField: UIView {
    let input = UITextField()
    private let atSymbol = UILabel()
    init(showAtSymbol: Bool = false) {
        super.init(frame: .zero)
        atSymbol.isHidden = !showAtSymbol
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BorderedTextField {
    func setup() {
        backgroundColor = UIColor(rgb: 0x181818)
        layer.cornerRadius = 12
        layer.borderColor = UIColor(rgb: 0x757575).cgColor
        layer.borderWidth = 1
        
        let stack = UIStackView(arrangedSubviews: [atSymbol, input])
        stack.spacing = 11
        stack.alignment = .center
        
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 18).pinToSuperview(edges: .vertical, padding: 14)
        
        atSymbol.text = "@"
        atSymbol.font = .appFont(withSize: 20, weight: .bold)
        atSymbol.textColor = .init(rgb: 0xCCCCCC)
        atSymbol.setContentHuggingPriority(.required, for: .horizontal)
        
        input.font = .appFont(withSize: 20, weight: .regular)
        input.textColor = .init(rgb: 0xCCCCCC)
        input.textContentType = .username
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc func tapped() {
        input.becomeFirstResponder()
    }
}
