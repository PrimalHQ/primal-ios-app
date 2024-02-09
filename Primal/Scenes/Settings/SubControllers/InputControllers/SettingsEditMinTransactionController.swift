//
//  SettingsEditMinTransactionController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.1.24..
//

import UIKit

final class SettingsEditMinTransactionController: UIViewController, Themeable {
    let valueInput = UITextField()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let value = Int(valueInput.text ?? "") else { return }

        UserDefaults.standard.minimumZapValue = value
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsEditMinTransactionController {
    func setup() {
        updateTheme()
        
        title = "Wallet Minimum Transaction Settings"
        
        let amountParent = ThemeableView().constrainToSize(height: 48).setTheme { $0.backgroundColor = .background3 }
        amountParent.addSubview(valueInput)
        amountParent.layer.cornerRadius = 24
        valueInput.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        
        let stack = UIStackView(axis: .vertical, [
            SettingsTitleViewVibrant(title: "HIDE TRANSACTIONS IN WALLET BELOW AMOUNT"), SpacerView(height: 12),
            amountParent
        ])
        
        valueInput.text = "\(UserDefaults.standard.minimumZapValue)"
        valueInput.keyboardType = .numberPad
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: [.top, .horizontal], padding: 20, safeArea: true)
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.valueInput.resignFirstResponder()
        }))
        
        amountParent.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.valueInput.becomeFirstResponder()
        }))
    }
}
