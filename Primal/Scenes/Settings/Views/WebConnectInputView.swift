//
//  WebConnectInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.7.24..
//

import UIKit

class WebConnectInputView: UIStackView, Themeable {
    let input = RoundedInputField(placeholder: "wss://")
    let action = UIButton(configuration: .roundedIconAccent(UIImage(named: "WebConnectInputIcon"))).constrainToSize(40)
    
    init() {
        super.init(frame: .zero)
        addArrangedSubview(input)
        addArrangedSubview(action)
        spacing = 8
        
        input.input.returnKeyType = .done
        input.input.autocapitalizationType = .none
        input.input.keyboardType = .URL
        input.input.autocorrectionType = .no
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        action.configuration = .roundedIconAccent(UIImage(named: "WebConnectInputIcon"))
    }
}
