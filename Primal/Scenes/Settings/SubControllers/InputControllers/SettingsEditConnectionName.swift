//
//  SettingsEditConnectionName.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import UIKit
import PrimalShared

final class SettingsEditConnectionName: UIViewController, Themeable {
    let valueInput = UITextField()
    
    let connection: RemoteAppConnection
    init(connection: RemoteAppConnection) {
        self.connection = connection
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        valueInput.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let value = valueInput.text ?? ""
        if value.isEmpty { return }

        Task {
            try? await RemoteSignerManager.instance.connectionRepo.updateConnectionName(clientPubKey: connection.clientPubKey, name: value)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsEditConnectionName {
    func setup() {
        updateTheme()
        
        title = "Connected App Details"
        
        let amountParent = ThemeableView().constrainToSize(height: 48).setTheme { $0.backgroundColor = .background3 }
        amountParent.addSubview(valueInput)
        amountParent.layer.cornerRadius = 24
        valueInput.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        
        let stack = UIStackView(axis: .vertical, [
            SettingsTitleViewVibrant(title: "EDIT CONNECTION NAME"), SpacerView(height: 12),
            amountParent
        ])
        
        valueInput.text = connection.name
        
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
