//
//  SettingsDevModeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.9.24..
//

import UIKit

extension String {
    static let enableDevModeKey = "enableDevModeKey1"
}

struct DevModeSettings {
    static var enableDevMode: Bool {
        get { UserDefaults.standard.bool(forKey: .enableDevModeKey) }
        set { UserDefaults.standard.set(newValue, forKey: .enableDevModeKey) }
    }
}

final class SettingsDevModeController: UIViewController, Themeable {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsDevModeController {
    func setup() {
        title = "Dev Mode"
        
        let devMode = SettingsSwitchView("Enable Dev Mode")
        
        let stack = UIStackView(axis: .vertical, [
            devMode, SpacerView(height: 10),
            descLabel("Show the connected state in the top right corner of the screen. More dev features to come."), SpacerView(height: 32),
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
        
        devMode.switchView.isOn = DevModeSettings.enableDevMode
        
        devMode.switchView.addAction(.init(handler: { [weak devMode] _ in
            guard let value = devMode?.switchView.isOn else { return }
            DevModeSettings.enableDevMode = value
            RootViewController.instance.connectionDot.isHidden = !value
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
