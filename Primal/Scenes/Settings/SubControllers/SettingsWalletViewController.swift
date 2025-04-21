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

final class SettingsWalletViewController: UIViewController, SettingsController, Themeable {
    let minTransaction = SettingsInfoView(name: "Hide transactions below", desc: "1 sats", showArrow: true)
    let showNotifications = SettingsInfoView(name: "Show notifications above", desc: "1 sats", showArrow: true)
    
    let nwcVC = SettingsWalletNWCController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        minTransaction.descLabel.text = "\(UserDefaults.standard.minimumZapValue) sats"
        
        let minimumNotificationValue = IdentityManager.instance.userSettings?.notificationsAdditional?.show_wallet_push_notifications_above_sats ?? 1
        showNotifications.descLabel.text = "\(minimumNotificationValue) sats"
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
        
        let addressDesc = descLabel("You can change your Nostr Lightning Address (for receiving zaps) in your ", link: "profile settings.") { [weak self] in
            guard let user = IdentityManager.instance.user else { return }
            self?.show(EditProfileViewController(profile: user), sender: nil)
        }
        
        let maxBalanceDesc = descLabel("Primal is a transactional wallet, designed for handling small amounts. We recommend self custody for larger amounts.")
        
        minTransaction.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsEditMinTransactionController(), sender: nil)
        }), for: .touchUpInside)
        
        showNotifications.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsEditMinNotificationController(), sender: nil)
        }), for: .touchUpInside)
        
        let stack = UIStackView(axis: .vertical, [
            walletStart,                                                                                                        SpacerView(height: 10),
            descLabel("Open the wallet when Primal starts."),                                                                   SpacerView(height: 24),
            SettingsInfoView(name: "LN Address", desc: IdentityManager.instance.user?.lud16 ?? "Not set...", showArrow: false), SpacerView(height: 10),
            addressDesc,                                                                                                        SpacerView(height: 24),
            showNotifications,                                                                                                  SpacerView(height: 10),
            descLabel("Get notified with push notifications when you receive a payment above a certain size"),                           SpacerView(height: 24),
            minTransaction,                                                                                                     SpacerView(height: 10),
            descLabel("You can choose to hide small transactions to avoid spam in your transaction list"),                      SpacerView(height: 24),
//            SettingsInfoView(name: "Fiat currency", desc: "USD", showArrow: true),                                              SpacerView(height: 10),
//            descLabel("You can choose to hide small transactions to avoid spam in your transaction list"),                      SpacerView(height: 24),
            SettingsInfoView(name: "Max wallet balance", desc: "\(WalletManager.instance.maxBalance.localized()) sats", showArrow: false), SpacerView(height: 10),
            maxBalanceDesc,
            nwcVC.view
        ])
        
        nwcVC.willMove(toParent: self)
        addChild(nwcVC)
        nwcVC.didMove(toParent: self)
        
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
}

final class SettingsInfoView: MyButton, Themeable {
    let nameLabel = UILabel()
    let descLabel = UILabel()
    let arrowImageView = UIImageView(image: UIImage(named: "settingsSmallArrow"))
    
    override var isPressed: Bool {
        didSet {
            backgroundColor = isPressed ? .background3.withAlphaComponent(0.6) : .background3
        }
    }
    
    init(name: String, desc: String, showArrow: Bool) {
        super.init(frame: .zero)
        
        let stack = UIStackView([nameLabel, SpacerView(width: 17, priority: .required), UIView(), descLabel])
        
        if showArrow {
            stack.addArrangedSubview(SpacerView(width: 12, priority: .required))
            stack.addArrangedSubview(arrowImageView)
        } else {
            isUserInteractionEnabled = false
        }
        
        nameLabel.text = name
        descLabel.text = desc
        
        addSubview(stack)
        stack.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 16)
        stack.alignment = .center
        
        constrainToSize(height: 48)
        layer.cornerRadius = 12
        
        updateTheme()
        
        descLabel.lineBreakMode = .byTruncatingTail
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        descLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        nameLabel.font = .appFont(withSize: 16, weight: .regular)
        descLabel.font = .appFont(withSize: 16, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        backgroundColor = .background3
        nameLabel.textColor = .foreground
        descLabel.textColor = .foreground3
        arrowImageView.tintColor = .foreground3
    }
}
