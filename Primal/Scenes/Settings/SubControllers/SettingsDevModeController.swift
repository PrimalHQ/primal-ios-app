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
    let smoothScrollSpeed = SettingsInfoView(name: "Smooth Scroll Speed", desc: "200", showArrow: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        smoothScrollSpeed.descLabel.text = "\(RootViewController.instance.smoothScrollSpeed) units"
    }
}

private extension SettingsDevModeController {
    func setup() {
        title = "Dev Mode"
        
//        let devMode = SettingsSwitchView("Enable Dev Mode")
        let scrollButton = SettingsSwitchView("Enable Smooth Scroll Button")
        
        let stack = UIStackView(axis: .vertical, [
//            devMode, SpacerView(height: 10),
//            descLabel("Show the connected state in the top right corner of the screen. More dev features to come."), SpacerView(height: 20),
//            SettingsBorder(), SpacerView(height: 20),
            scrollButton, SpacerView(height: 10),
            descLabel("Show the button for smooth scrolling"), SpacerView(height: 20),
            smoothScrollSpeed, SpacerView(height: 20)
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
        
//        devMode.switchView.isOn = DevModeSettings.enableDevMode
        scrollButton.switchView.isOn = !RootViewController.instance.smoothScrollButton.isHidden
        
//        devMode.switchView.addAction(.init(handler: { [weak devMode] _ in
//            guard let value = devMode?.switchView.isOn else { return }
//            DevModeSettings.enableDevMode = value
//
//        }), for: .valueChanged)
        
        scrollButton.switchView.addAction(.init(handler: { [weak scrollButton] _ in
            guard let value = scrollButton?.switchView.isOn else { return }
            RootViewController.instance.smoothScrollButton.isHidden = !value
        }), for: .valueChanged)
        
        smoothScrollSpeed.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsEditSmoothScrollSpeedController(), sender: nil)
        }), for: .touchUpInside)
    }
    
    func descLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }
}

final class SettingsEditSmoothScrollSpeedController: UIViewController, Themeable {
    let valueInput = UITextField()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let value = Int(valueInput.text ?? "") else { return }

        RootViewController.instance.smoothScrollSpeed = value
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsEditSmoothScrollSpeedController {
    func setup() {
        updateTheme()
        
        title = "Smooth Scroll Speed"
        
        let amountParent = ThemeableView().constrainToSize(height: 48).setTheme { $0.backgroundColor = .background3 }
        amountParent.addSubview(valueInput)
        amountParent.layer.cornerRadius = 24
        valueInput.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        
        let stack = UIStackView(axis: .vertical, [
            SettingsTitleViewVibrant(title: "SCROLL AT SPEED:"), SpacerView(height: 12),
            amountParent
        ])
        
        valueInput.text = "\(RootViewController.instance.smoothScrollSpeed)"
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
