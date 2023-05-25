//
//  SettingsMainViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

class SettingsMainViewController: UIViewController, Themeable {
    let deleteButton = UIButton()
    
    let versionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        updateTheme()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        deleteButton.backgroundColor = .background3
        
        versionLabel.textColor = .foreground
    }
}

private extension SettingsMainViewController {
    func setupView() {
        title = "Settings"
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let keys = SettingsOptionButton(title: "Keys")
        let appearance = SettingsOptionButton(title: "Appearance")
        let notifications = SettingsOptionButton(title: "Notifications")
        let messages = SettingsOptionButton(title: "Messages")
        let network = SettingsOptionButton(title: "Network")
        
        let deleteLabel = SettingsTitleView(title: "DELETE")
        let versionTitleLabel = SettingsTitleView(title: "VERSION")
        
        let stack = UIStackView(arrangedSubviews: [
            keys, appearance, notifications, messages, network,
            deleteLabel, deleteButton, versionTitleLabel, versionLabel, UIView()
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12, safeArea: true)
        stack.axis = .vertical
        stack.setCustomSpacing(40, after: network)
        stack.setCustomSpacing(16, after: deleteLabel)
        stack.setCustomSpacing(36, after: deleteButton)
        stack.setCustomSpacing(12, after: versionTitleLabel)
        
        deleteLabel.text = "DELETE ACCOUNT"
        deleteLabel.font = .appFont(withSize: 14, weight: .medium)
        
        deleteButton.setTitle("Delete account", for: .normal)
        deleteButton.setTitleColor(.accent, for: .normal)
        deleteButton.setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
        deleteButton.titleLabel?.font  = .appFont(withSize: 20, weight: .regular)
        deleteButton.contentHorizontalAlignment = .left
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0);
        deleteButton.layer.cornerRadius = 8
        deleteButton.constrainToSize(height: 48)
        
        versionLabel.font = .appFont(withSize: 20, weight: .bold)
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = appVersion
        } else {
            versionLabel.text = "Unknown"
        }
        
        keys.addTarget(self, action: #selector(keysPressed), for: .touchUpInside)
    }
    
    @objc func keysPressed() {
        show(SettingsNsecViewController(), sender: nil)
    }
}
