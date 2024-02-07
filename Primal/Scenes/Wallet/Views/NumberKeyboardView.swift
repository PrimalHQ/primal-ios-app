//
//  NumberKeyboardView.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.1.24..
//

import UIKit

protocol NumberKeyboardViewDelegate: AnyObject {
    func numberKeyboardNumberPressed(_ number: Int)
    func numberKeyboardDeletePressed()
    func numberKeyboardDotPressed()
}

final class NumberKeyboardView: UIView {
    weak var delegate: NumberKeyboardViewDelegate?
    
    private let dotButton = NumberKeyboardSymbolButton(Locale.current.decimalSeparator ?? ".")
    
    init() {
        super.init(frame: .zero)
        
        let mainStack = UIStackView(axis: .vertical, [])
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        var buttons = (1...10).reversed().map { num in
            let number = num % 10
            let button = NumberKeyboardSymbolButton("\(number)")
            button.addAction(.init(handler: { [weak self] _ in
                self?.delegate?.numberKeyboardNumberPressed(number)
            }), for: .touchUpInside)
            return button
        }
        
        for _ in 0...2 {
            let hStack = UIStackView([])
            mainStack.addArrangedSubview(hStack)
            
            hStack.spacing = 14
            hStack.distribution = .fillEqually
            
            for _ in 0..<3 {
                if let button = buttons.popLast() {
                    hStack.addArrangedSubview(button)
                }
            }
        }
        
        let del = NumberKeyboardIconButton(UIImage(named: "walletKeyboardDelete"))
        del.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.numberKeyboardDeletePressed()
        }), for: .touchUpInside)
        
        dotButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.numberKeyboardDotPressed()
        }), for: .touchUpInside)
        
        let hStack = UIStackView([dotButton, buttons.first ?? UIView(), del])
        mainStack.addArrangedSubview(hStack)
        hStack.spacing = 14
        hStack.distribution = .fillEqually
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class NumberKeyboardIconButton: NumberKeyboardButton {
    init(_ icon: UIImage?) {
        super.init()
        setImage(icon, for: .normal)
        tintColor = .foreground
        titleLabel?.font = .appFont(withSize: 36, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


final class NumberKeyboardSymbolButton: NumberKeyboardButton {
    init(_ symbol: String) {
        super.init()
        setTitle(symbol, for: .normal)
        setTitleColor(.foreground, for: .normal)
        setTitleColor(.foreground.withAlphaComponent(0.5), for: .highlighted)
        titleLabel?.font = .appFont(withSize: 36, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


class NumberKeyboardButton: UIButton {
    init() {
        super.init(frame: .zero)
        
        constrainToSize(height: 56)
        layer.cornerRadius = 28
        backgroundColor = .background3
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
