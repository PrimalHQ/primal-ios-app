//
//  SettingsEditMinNotificationController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.2.24..
//

import UIKit

final class SettingsEditMinNotificationController: UIViewController, Themeable {
    let valueInput = UITextField()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let value = Int(valueInput.text ?? "") else { return }

        UserDefaults.standard.minimumNotificationValue = value
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsEditMinNotificationController {
    func setup() {
        updateTheme()
        
        title = "Wallet Notifications Settings"
        
        let amountParent = ThemeableView().constrainToSize(height: 48).setTheme { $0.backgroundColor = .background3 }
        amountParent.addSubview(valueInput)
        amountParent.layer.cornerRadius = 24
        valueInput.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        
        let stack = UIStackView(axis: .vertical, [
            SettingsTitleViewVibrant(title: "SHOW IN APP NOTIFICATIONS FOR AMOUNTS LARGER THAN"), SpacerView(height: 12),
            amountParent
        ])
        
        valueInput.text = "\(UserDefaults.standard.minimumNotificationValue)"
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
