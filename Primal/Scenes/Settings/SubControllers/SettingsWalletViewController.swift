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
    let backupWallet = SettingsInfoView(name: "Backup wallet", desc: "", showArrow: true)
    let restoreWallet = SettingsInfoView(name: "Restore existing wallet", desc: "", showArrow: true)
    let exportWallet = SettingsInfoView(name: "Export transaction history", desc: "", showIcon: .menuImageSave)
    
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
        
        let addressDesc = descLabel("You can change your Nostr Lightning Address (for receiving zaps) in your ", link: "profile settings.") { [weak self] in
            guard let user = IdentityManager.instance.user else { return }
            self?.show(EditProfileViewController(profile: user), sender: nil)
        }
        
        let backupDesc = descLabel("Write down your wallet recovery phrase so you don’t lose access to your funds")
        let restoreDesc = descLabel("If you have an existing wallet that you wish to use with your Nostr account, you can restore it here using your 12-24 wallet recovery phrase")
        let exportDesc = descLabel("Download your entire wallet transaction history in CSV format")
        
        let primalStack = UIStackView(axis: .vertical, [
            showNotifications,                                                                                                  SpacerView(height: 10),
            descLabel("Get notified with push notifications when you receive a payment above a certain size"),                  SpacerView(height: 24),
            
            nwcVC.view
        ])
        
        let backupStack = UIStackView(axis: .vertical, [backupWallet, SpacerView(height: 10), backupDesc, SpacerView(height: 24)])
        let restoreStack = UIStackView(axis: .vertical, [restoreWallet, SpacerView(height: 10), restoreDesc, SpacerView(height: 24)])
        let exportStack = UIStackView(axis: .vertical, [exportWallet, SpacerView(height: 10), exportDesc, SpacerView(height: 24)])
        
        let externalWallet = SettingsSwitchView("Use external wallet")
        let walletStart = SettingsSwitchView("Start in wallet")
        
        let backupInfoView = WalletBackupInfoView()
        
        let mainStack = UIStackView(axis: .vertical, [
            backupInfoView,
            SettingsInfoView(name: "LN Address", desc: IdentityManager.instance.user?.lud16 ?? "Not set...", showArrow: false), SpacerView(height: 10),
            addressDesc,                                                                                                        SpacerView(height: 24),
            walletStart,                                                                                                        SpacerView(height: 10),
            descLabel("Open the wallet when Primal starts"),                                                                    SpacerView(height: 24),
            minTransaction,                                                                                                     SpacerView(height: 10),
            descLabel("You can choose to hide small transactions to avoid spam in your transaction list"),                      SpacerView(height: 24),
            backupStack,
            restoreStack,
            exportStack,
            externalWallet,                                                                                                     SpacerView(height: 10),
            descLabel("Alternatively you can connect to an external lightning wallet via Nostr Wallet Connect"),                SpacerView(height: 24),
            nwcStack,
            primalStack,
        ])
        
        mainStack.setCustomSpacing(20, after: backupInfoView)
        
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
        
        // Hide restore button if the current wallet isn't spark
        Publishers.CombineLatest($useNWCWallet.removeDuplicates(), WalletManager.instance.$activeWallet)
            .map { $0 || !($1 is Wallet.Spark) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: restoreStack)
            .store(in: &cancellables)
        
        // Hide backup button if the current wallet isn't spark or if it's already backed up
        Publishers.CombineLatest($useNWCWallet.removeDuplicates(), WalletManager.instance.$activeWallet)
            .map {
                guard !$0, let spark = $1 as? Wallet.Spark else { return nil }
                return spark
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (wallet: Wallet.Spark?) in
                guard let wallet else {
                    backupStack.isHidden = true
                    backupInfoView.isHidden = true
                    return
                }
                backupStack.isHidden = false
                backupInfoView.isHidden = wallet.isBackedUp || wallet.balanceInBtc?.doubleValue ?? 0 == 0
            })
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
            self?.show(RestoreWalletController(), sender: nil)
        }), for: .touchUpInside)
        
        [backupInfoView.backupButton, backupWallet].forEach {
            $0.addAction(.init(handler: { [weak self] _ in
                self?.present(BackupWalletController(), animated: true)
            }), for: .touchUpInside)
        }
        
        exportWallet.addAction(.init(handler: { [weak self] _ in
            guard let self, let walletId = WalletManager.instance.walletID else { return }
            Task { @MainActor in
                self.exportWallet.isEnabled = false
                let transactions = try await WalletManager.instance.walletRepo.allTransactions(walletId: walletId)
                
                CSVExporter.exportTransactions(transactions, walletType: "Primal", from: self)
                self.exportWallet.isEnabled = true
            }
        }), for: .touchUpInside)
        
        Task {
            try await updateNWCStack()
        }
    }
}

final class SettingsInfoView: MyButton, Themeable {
    let nameLabel = UILabel()
    let descLabel = UILabel()
    let arrowImageView = UIImageView()
    
    override var isPressed: Bool {
        didSet {
            backgroundColor = isPressed ? .background3.withAlphaComponent(0.6) : .background3
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    convenience init(name: String, desc: String, showArrow: Bool = false) {
        self.init(name: name, desc: desc, showIcon: showArrow ? .settingsSmallArrow : nil)
    }
    init(name: String, desc: String, showIcon: UIImage? = nil) {
        super.init(frame: .zero)
        
        let stack = UIStackView([nameLabel, SpacerView(width: 17, priority: .required), UIView(), descLabel])
        
        if let showIcon {
            stack.addArrangedSubview(SpacerView(width: 12, priority: .required))
            stack.addArrangedSubview(arrowImageView)
            arrowImageView.image = showIcon
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
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
    
    func updateTheme() {
        backgroundColor = .background3
        addressLabel.textColor = .foreground
        relayLabel.textColor = .foreground
        spacerView.backgroundColor = .background
    }
}

class WalletBackupInfoView: UIView, Themeable {
    let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
    let descriptionLabel = UILabel(
        "This wallet has not been backed up. It is important to back up your wallet so you don’t lose access to your funds.",
        color: .foreground,
        font: .appFont(withSize: 14, weight: .regular)
    )
    let backupButton = UIButton().constrainToSize(height: 48)
    
    var updateCancellable: AnyCancellable?
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        
        let stackView = UIStackView(axis: .vertical, spacing: 12, [titleLabel, descriptionLabel, backupButton])
        addSubview(stackView)
        stackView.pinToSuperview(padding: 14)
        
        descriptionLabel.numberOfLines = 0
        
        layer.cornerRadius = 12
        layer.borderWidth = 1
        
        updateTheme()
        
        updateCancellable = WalletManager.instance.$balance.map({ "Wallet Balance: \($0.localized()) sats" }).assign(to: \.text, on: titleLabel)
    }
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        descriptionLabel.textColor = .foreground.withAlphaComponent(0.75)
        backupButton.configuration = .pill(text: "Back Up Wallet Now", foregroundColor: .white, backgroundColor: .failureRed, font: .appFont(withSize: 16, weight: .semibold))
        layer.borderColor = UIColor.failureRed.withAlphaComponent(0.2).cgColor
        backgroundColor = .failureRed.withAlphaComponent(0.12)
    }
}
