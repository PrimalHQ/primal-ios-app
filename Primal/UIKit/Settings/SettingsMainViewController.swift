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
    
    let socket: SocketManager
    
    init(socket: SocketManager) {
        self.socket = socket
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
        let feeds = SettingsOptionButton(title: "Feeds")
        let appearance = SettingsOptionButton(title: "Appearance")
        let notifications = SettingsOptionButton(title: "Notifications")
        let network = SettingsOptionButton(title: "Network")
        
        let deleteLabel = SettingsTitleView(title: "DELETE")
        let versionTitleLabel = SettingsTitleView(title: "VERSION")
        
        let bottomStack = UIStackView(arrangedSubviews: [versionTitleLabel, versionLabel, UIView()])
        let stack = UIStackView(arrangedSubviews: [keys, feeds, appearance, notifications, network, bottomStack])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12, safeArea: true)
        stack.axis = .vertical
        stack.setCustomSpacing(40, after: network)
        stack.setCustomSpacing(12, after: versionTitleLabel)
        
        bottomStack.axis = .vertical
        bottomStack.spacing = 12
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
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
        show(SettingsNsecViewController(socket: socket), sender: nil)
    }
}