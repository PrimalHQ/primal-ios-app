//
//  SettingsMainViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

protocol SettingsController: UIViewController {

}
extension SettingsController {
    func descLabel(_ text: String) -> UILabel {
        return descLabel(text, link: "", action: {})
    }
    
    func descLabel(_ text: String, link: String, action: @escaping () -> Void) -> UILabel {
        let label = ThemeableLabel().setTheme {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 6
            let mutable = NSMutableAttributedString(string: text, attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .regular),
                .foregroundColor: UIColor.foreground3,
                .paragraphStyle: paragraph
            ])
            mutable.append(.init(string: link, attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .regular),
                .foregroundColor: UIColor.accent,
                .paragraphStyle: paragraph
            ]))
            $0.attributedText = mutable
        }
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(BindableTapGestureRecognizer(action: {
            action()
        }))
        return label
    }
}


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
        
        let keys = SettingsOptionButton(title: "Keys")
        let wallet = SettingsOptionButton(title: "Wallet")
        let network = SettingsOptionButton(title: "Network")
        let appearance = SettingsOptionButton(title: "Appearance")
        let contentDisplay = SettingsOptionButton(title: "Content Display")
        let muted = SettingsOptionButton(title: "Muted Accounts")
        let mediaUploads = SettingsOptionButton(title: "Media Uploads")
        let notifications = SettingsOptionButton(title: "Notifications")
        let devMode = SettingsOptionButton(title: "Dev Mode")
        devMode.isHidden = true
        let zaps = SettingsOptionButton(title: "Zaps")
        
        let versionTitleLabel = SettingsTitleView(title: "VERSION")
        
        let bottomStack = UIStackView(arrangedSubviews: [versionTitleLabel, versionLabel, UIView()])
        let stack = UIStackView(arrangedSubviews: [keys, wallet, network, appearance, contentDisplay, muted, mediaUploads, notifications, devMode, zaps, SpacerView(height: 40), bottomStack])
        
        let scroll = UIScrollView()
        
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
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
        
        guard LoginManager.instance.method() == .nsec else {
            [keys, appearance, contentDisplay, muted, notifications, zaps, network].forEach { $0.addDisabledNSecWarning(self) }
            return
        }
        
        keys.addTarget(self, action: #selector(keysPressed), for: .touchUpInside)

        devMode.addAction(.init(handler: { [weak self] _ in self?.show(SettingsDevModeController(), sender: nil) }), for: .touchUpInside)
        
        wallet.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsWalletViewController(), animated: true)
        }), for: .touchUpInside)

        appearance.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsAppearanceViewController(), animated: true)
        }), for: .touchUpInside)
        
        network.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsNetworkViewController(), animated: true)
        }), for: .touchUpInside)
        
        contentDisplay.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsContentDisplayController(), animated: true)
        }), for: .touchUpInside)
        
        muted.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsMutedViewController(), animated: true)
        }), for: .touchUpInside)
        
        notifications.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsNotificationsViewController(), animated: true)
        }), for: .touchUpInside)
        
        mediaUploads.addAction(.init(handler: { [weak self] _ in self?.show(SettingsMediaUploadsController(), sender: nil) }), for: .touchUpInside)
        
        zaps.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.pushViewController(SettingsZapsViewController(), animated: true)
        }), for: .touchUpInside)
    }
    
    @objc func keysPressed() {
        navigationController?.pushViewController(SettingsNsecViewController(), animated: true)
    }
}
