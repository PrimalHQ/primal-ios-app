//
//  SettingsWalletViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.1.24..
//

import UIKit
import Combine
import PrimalShared

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
    let restoreWallet = SettingsInfoView(name: "Restore existing wallet", desc: "", showArrow: true)
    
    let nwcVC = SettingsWalletNWCController()
    
    let nwcStack = UIStackView(axis: .vertical, [])
    
    @Published var useNWCWallet = true
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
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
    func updateNWCStack() async throws {
        nwcStack.subviews.forEach{ $0.removeFromSuperview() }
        
        //nostr+walletconnect://1291af9c119879ef7a59636432c6e06a7a058c0cae80db27c0f20f61f3734e52?relay=wss%3A%2F%2Fnwc.primal.net%2Fx0yn66fe7i6ljbfsypyzme9wwr5o48&secret=7ab8341dbf75e0bc3d053bd9503c2a9d5d608fa54b3e42d0b942c9a1089f1857
        
        let activeWallet = try await WalletManager.instance.walletAccountRepo.getActiveWallet(userId: IdentityManager.instance.userHexPubkey)
        
        if let nwc = activeWallet as? Wallet.NWC {
            let disconnectButton = LargeRoundedButton(title: "Disconnect Wallet")
            let info = NWCInfoView()
            
            [
                SettingsTitleView(title: "WALLET CONNECTED"),               SpacerView(height: 10),
                info,                                                       SpacerView(height: 16),
                disconnectButton,                                           SpacerView(height: 24)
            ].forEach { nwcStack.addArrangedSubview($0) }
            
            info.relayLabel.text = nwc.relays.first
            info.addressLabel.text = nwc.lightningAddress ?? "Unknown address"
            
            disconnectButton.addAction(.init(handler: { [weak self] _ in
                Task { @MainActor in
                    try await WalletManager.instance.disconnectNWCWallet()
                    
                    try await self?.updateNWCStack()
                }
            }), for: .touchUpInside)
        } else {
            let pasteButton = ThemeableButton().setTheme({ $0.configuration = .pill(text: "Paste NWC String", foregroundColor: .foreground, backgroundColor: .background3, font: .appFont(withSize: 16, weight: .regular)) }).constrainToSize(height: 48)
            let scanButton = ThemeableButton().setTheme({ $0.configuration = .pill(text: "Scan NWC QR Code", foregroundColor: .foreground, backgroundColor: .background3, font: .appFont(withSize: 16, weight: .regular)) }).constrainToSize(height: 48)
            
            [
                SettingsTitleView(title: "CONNECT A WALLET"),                                                                       SpacerView(height: 10),
                descLabel("Connect an external wallet by scanning or pasting its Nostr Wallet Connect (NWC) connection string:"),   SpacerView(height: 24),
                pasteButton,                                                                                                        SpacerView(height: 12),
                scanButton,                                                                                                         SpacerView(height: 24),
                SpacerView(height: 10),
            ].forEach { nwcStack.addArrangedSubview($0) }
            
            pasteButton.addAction(.init(handler: { [weak self] _ in
                guard let paste = UIPasteboard.general.string else { return }
                Task { @MainActor in
                    self?.view.showToast("Pasted!")
                    
                    try await WalletManager.instance.setNWCWallet(nwcString: paste)
                    
                    try await self?.updateNWCStack()
                }
            }), for: .touchUpInside)
            
            scanButton.addAction(.init(handler: { [weak self] _ in
                self?.navigationController?.pushViewController(SettingsNWCQRScanController(callback: { code in
                    Task { @MainActor in
                        try await WalletManager.instance.setNWCWallet(nwcString: code)
                        try await self?.updateNWCStack()
                    }
                }), animated: true)
            }), for: .touchUpInside)
        }
    }
    
    func setup() {
        title = "Wallet Settings"
        
        let externalWallet = SettingsSwitchView("Use external wallet")
        
        let walletStart = SettingsSwitchView("Start in wallet")
        
        let addressDesc = descLabel("You can change your Nostr Lightning Address (for receiving zaps) in your ", link: "profile settings.") { [weak self] in
            guard let user = IdentityManager.instance.user else { return }
            self?.show(EditProfileViewController(profile: user), sender: nil)
        }
        
        let maxBalanceDesc = descLabel("Primal is a transactional wallet, designed for handling small amounts. We recommend self custody for larger amounts.")
        let restoreDesc = descLabel("If you have an existing wallet that you wish to use with your Nostr account, you can restore it here using your 12-24 wallet recovery phrase.")
        
        let primalStack = UIStackView(axis: .vertical, [
            showNotifications,                                                                                                  SpacerView(height: 10),
            descLabel("Get notified with push notifications when you receive a payment above a certain size"),                  SpacerView(height: 24),
            
//            SettingsInfoView(name: "Fiat currency", desc: "USD", showArrow: true),                                              SpacerView(height: 10),
//            descLabel("You can choose to hide small transactions to avoid spam in your transaction list"),                      SpacerView(height: 24),
            SettingsInfoView(name: "Max wallet balance", desc: "\(WalletManager.instance.maxBalance.localized()) sats", showArrow: false), SpacerView(height: 10),
            maxBalanceDesc,
            nwcVC.view
        ])
        
        let mainStack = UIStackView(axis: .vertical, [
            SettingsInfoView(name: "LN Address", desc: IdentityManager.instance.user?.lud16 ?? "Not set...", showArrow: false), SpacerView(height: 10),
            addressDesc,                                                                                                        SpacerView(height: 24),
            walletStart,                                                                                                        SpacerView(height: 10),
            descLabel("Open the wallet when Primal starts"),                                                                    SpacerView(height: 24),
            minTransaction,                                                                                                     SpacerView(height: 10),
            descLabel("You can choose to hide small transactions to avoid spam in your transaction list"),                      SpacerView(height: 24),
            restoreWallet,                                                                                                      SpacerView(height: 10),
            restoreDesc,                                                                                                        SpacerView(height: 24),
            externalWallet,                                                                                                     SpacerView(height: 10),
            descLabel("Alternatively you can connect to an external lightning wallet via Nostr Wallet Connect"),                SpacerView(height: 24),
            nwcStack,
            primalStack,
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
        
        scroll.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 16)
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        updateTheme()
        
        walletStart.switchView.isOn = WalletSettings.startInWallet
        
        useNWCWallet = WalletManager.instance.isNWCWalletActive
        
        $useNWCWallet.removeDuplicates().receive(on: DispatchQueue.main).sink { [weak self] useNWC in
            externalWallet.switchView.isOn = useNWC
            primalStack.isHidden = useNWC
            self?.nwcStack.isHidden = !useNWC
        }
        .store(in: &cancellables)
        
        externalWallet.switchView.addAction(.init(handler: { [weak self, weak externalWallet] _ in
            guard let externalWallet else { return }
            let usePrimalWallet = externalWallet.switchView.isOn
            
            Task { @MainActor in
                try await WalletManager.instance.setUsePrimalWallet(usePrimalWallet)
                try await self?.updateNWCStack()
                self?.useNWCWallet = usePrimalWallet
            }
        }), for: .valueChanged)
        
        walletStart.switchView.addAction(.init(handler: { [weak walletStart] _ in
            guard let value = walletStart?.switchView.isOn else { return }
            WalletSettings.startInWallet = value
        }), for: .valueChanged)
        
        minTransaction.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsEditMinTransactionController(), sender: nil)
        }), for: .touchUpInside)
        
        showNotifications.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsEditMinNotificationController(), sender: nil)
        }), for: .touchUpInside)
        
        restoreWallet.addAction(.init(handler: { [weak self] _ in
            
        }), for: .touchUpInside)
        
        Task {
            try await updateNWCStack()
        }
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

class NWCInfoView: UIView, Themeable {
    let relayLabel = UILabel()
    let addressLabel = UILabel()
    let spacerView = SpacerView(height: 1)
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 16
        
        let relayParent = UIView().constrainToSize(height: 48)
        let addressParent = UIView().constrainToSize(height: 48)
        relayParent.addSubview(relayLabel)
        addressParent.addSubview(addressLabel)
        relayLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 12)
        addressLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 12)
        
        let mainStack = UIStackView(axis: .vertical, [relayParent, spacerView, addressParent])
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        relayLabel.font = .appFont(withSize: 16, weight: .regular)
        addressLabel.font = .appFont(withSize: 16, weight: .regular)
        relayLabel.textAlignment = .center
        addressLabel.textAlignment = .center
        relayLabel.adjustsFontSizeToFitWidth = true
        addressLabel.adjustsFontSizeToFitWidth = true
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
        addressLabel.textColor = .foreground
        relayLabel.textColor = .foreground
        spacerView.backgroundColor = .background
    }
}
