//
//  SettingsMainViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

class SettingsMainViewController: UIViewController, Themeable {
    let versionLabel = UILabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        updateTheme()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        versionLabel.textColor = .foreground
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsMainViewController {
    func setupView() {
        title = "Settings"
        
        let keys = SettingsOptionButton(title: "Account")
        let appearance = SettingsOptionButton(title: "Appearance")
        let muted = SettingsOptionButton(title: "Muted Accounts")
        let notifications = SettingsOptionButton(title: "Notifications")
        let network = SettingsOptionButton(title: "Network")
        let feeds = SettingsOptionButton(title: "Feeds")
        let wallet = SettingsOptionButton(title: "Wallet")
        let zaps = SettingsOptionButton(title: "Zaps")
        
        let versionTitleLabel = SettingsTitleView(title: "VERSION")
        
        wallet.isEnabled = LoginManager.instance.method() == .nsec
        notifications.isEnabled = LoginManager.instance.method() == .nsec
        feeds.isEnabled = LoginManager.instance.method() == .nsec
        zaps.isEnabled = LoginManager.instance.method() == .nsec
        
        let bottomStack = UIStackView(arrangedSubviews: [versionTitleLabel, versionLabel, UIView()])
        let stack = UIStackView(arrangedSubviews: [keys, appearance, muted, notifications, feeds, zaps, SpacerView(height: 40), bottomStack])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12, safeArea: true)
        stack.axis = .vertical
        stack.setCustomSpacing(12, after: versionTitleLabel)
        
        bottomStack.axis = .vertical
        bottomStack.spacing = 12
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        versionLabel.font = .appFont(withSize: 20, weight: .bold)
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = appVersion
        } else {
            versionLabel.text = "Unknown"
        }
        
        keys.addTarget(self, action: #selector(keysPressed), for: .touchUpInside)
        wallet.addTarget(self, action: #selector(walletPressed), for: .touchUpInside)
        feeds.addTarget(self, action: #selector(feedsPressed), for: .touchUpInside)
        
        appearance.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsAppearanceViewController(), sender: nil)
        }), for: .touchUpInside)
        
        muted.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsMutedViewController(), sender: nil)
        }), for: .touchUpInside)
        
        notifications.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsNotificationsViewController(), sender: nil)
        }), for: .touchUpInside)
        
        zaps.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsZapsViewController(), sender: nil)
        }), for: .touchUpInside)
    }
    
    @objc func feedsPressed() {
        show(SettingsFeedViewController(), sender: nil)
    }
    
    @objc func keysPressed() {
        show(SettingsNsecViewController(), sender: nil)
    }
    
    @objc func walletPressed() {
        show(SettingsWalletViewController(), sender: nil)
    }
}
