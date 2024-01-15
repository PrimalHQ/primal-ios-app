//
//  SettingsWalletViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.1.24..
//

import UIKit

private extension String {
    static let startInWalletKey = "startInWalletKey"
}

struct WalletSettings {
    static var startInWallet: Bool {
        get { UserDefaults.standard.bool(forKey: .startInWalletKey) }
        set { UserDefaults.standard.set(newValue, forKey: .startInWalletKey) }
    }
}

final class SettingsWalletViewController: UIViewController, Themeable {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsWalletViewController {
    func setup() {
        title = "Wallet Settings"
        
        let walletStart = SettingsSwitchView("Start in wallet")
        
        let stack = UIStackView(axis: .vertical, [
            walletStart, SpacerView(height: 10),
            descLabel("Open the wallet when Primal starts."),
        ])
        
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
            .pinToSuperview(edges: .top, padding: 7, safeArea: true)
        
        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 38)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        updateTheme()
        
        walletStart.switchView.isOn = WalletSettings.startInWallet
        
        walletStart.switchView.addAction(.init(handler: { [weak walletStart] _ in
            guard let value = walletStart?.switchView.isOn else { return }
            WalletSettings.startInWallet = value
        }), for: .valueChanged)
    }
    
    func descLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }
}
