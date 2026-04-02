//
//  SettingsDevModeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.9.24..
//

import Combine
import UIKit
import PrimalShared

extension String {
    static let devToolsEnabledKey = "devToolsEnabledKey1"
    static let walletSwitcherEnabledKey = "walletSwitcherEnabledKey"
}

struct DevModeSettings {
    static var devToolsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: .devToolsEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: .devToolsEnabledKey) }
    }
    static var walletSwitcherEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: .walletSwitcherEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: .walletSwitcherEnabledKey) }
    }
}

final class SettingsDevModeController: UIViewController, Themeable {
    let smoothScrollSpeed = SettingsInfoView(name: "Smooth Scroll Speed", desc: "200", showArrow: true)
    let walletListStack = UIStackView(axis: .vertical, [])
    let cacheBreakdownView = CacheBreakdownView()

    var cancellables: Set<AnyCancellable> = []

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
        cacheBreakdownView.startObserving()
    }
}

private extension SettingsDevModeController {
    func setup() {
        title = "Dev Mode"

        let walletSwitcher = SettingsSwitchView("Enable Wallet Switcher")
        let scrollButton = SettingsSwitchView("Enable Smooth Scroll Button")

        let clearCacheButton = UIButton(configuration: .accentPill(text: "Clear Image Cache", font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 40)
        clearCacheButton.addAction(.init(handler: { [weak clearCacheButton] _ in
            clearCacheButton?.isEnabled = false
            CachingManager.instance.clearImageCaches {
                clearCacheButton?.isEnabled = true
                RootViewController.instance.view.showToast("Image cache cleared", extraPadding: 0)
            }
        }), for: .touchUpInside)

        walletListStack.spacing = 8

        // MARK: - NWC Audit Logs

        let exportNwcLogsButton = SettingsInfoView(name: "Export NWC audit logs", desc: "", showIcon: .menuImageSave)
        exportNwcLogsButton.addAction(.init(handler: { [weak self, weak exportNwcLogsButton] _ in
            exportNwcLogsButton?.isEnabled = false
            Task { @MainActor in
                do {
                    let repo = WalletRepositoryFactory.shared.createNwcLogRepository()
                    let logs = try await repo.getNwcLogs()

                    guard let self else { return }

                    if logs.isEmpty {
                        RootViewController.instance.view.showToast("No NWC logs found", extraPadding: 0)
                    } else {
                        CSVExporter.exportNwcLogs(logs, from: self)
                    }
                } catch {
                    RootViewController.instance.view.showToast("Failed to export NWC logs", extraPadding: 0)
                }
                exportNwcLogsButton?.isEnabled = true
            }
        }), for: .touchUpInside)

        // MARK: - Wallet Log Recording

        let walletLogToggle = SettingsSwitchView("Record wallet logs")
        walletLogToggle.switchView.isOn = WalletLogRecorder.instance.isRecording

        walletLogToggle.switchView.addAction(.init(handler: { [weak walletLogToggle] _ in
            guard let isOn = walletLogToggle?.switchView.isOn else { return }
            if isOn {
                WalletLogRecorder.instance.startRecording()
            } else {
                WalletLogRecorder.instance.stopRecording()
            }
        }), for: .valueChanged)

        let exportWalletLogsButton = SettingsInfoView(name: "Export wallet logs", desc: "", showIcon: .menuImageSave)
        exportWalletLogsButton.addAction(.init(handler: { [weak self] _ in
            let urls = WalletLogRecorder.instance.logFileURLs()
            guard !urls.isEmpty else {
                RootViewController.instance.view.showToast("No wallet logs to export", extraPadding: 0)
                return
            }
            guard let self else { return }
            let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
            self.present(activityVC, animated: true)
        }), for: .touchUpInside)

        let clearWalletLogsButton = UIButton(configuration: .accentPill(text: "Clear Wallet Logs", font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 40)
        clearWalletLogsButton.addAction(.init(handler: { [weak clearWalletLogsButton, weak walletLogToggle] _ in
            clearWalletLogsButton?.isEnabled = false
            WalletLogRecorder.instance.clearLogs()
            walletLogToggle?.switchView.setOn(false, animated: true)
            clearWalletLogsButton?.isEnabled = true
            RootViewController.instance.view.showToast("Wallet logs cleared", extraPadding: 0)
        }), for: .touchUpInside)

        let stack = UIStackView(axis: .vertical, [
            walletSwitcher, SpacerView(height: 10),
            descLabel("Enable wallet switcher popup on the wallet home screen"), SpacerView(height: 20),
            walletListStack, SpacerView(height: 20),
            SettingsBorder(), SpacerView(height: 20),
            cacheBreakdownView, SpacerView(height: 12),
            clearCacheButton, SpacerView(height: 20),
            SettingsBorder(), SpacerView(height: 20),
            exportNwcLogsButton, SpacerView(height: 10),
            descLabel("Export NWC request/response audit logs as CSV"), SpacerView(height: 20),
            SettingsBorder(), SpacerView(height: 20),
            walletLogToggle, SpacerView(height: 10),
            descLabel("Record wallet SDK logs to disk for debugging"), SpacerView(height: 20),
            exportWalletLogsButton, SpacerView(height: 10),
            descLabel("Share recorded wallet log files"), SpacerView(height: 12),
            clearWalletLogsButton, SpacerView(height: 20),
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

        walletSwitcher.switchView.isOn = DevModeSettings.walletSwitcherEnabled
        scrollButton.switchView.isOn = !RootViewController.instance.smoothScrollButton.isHidden

        walletSwitcher.switchView.addAction(.init(handler: { [weak walletSwitcher] _ in
            guard let value = walletSwitcher?.switchView.isOn else { return }
            DevModeSettings.walletSwitcherEnabled = value
        }), for: .valueChanged)

        scrollButton.switchView.addAction(.init(handler: { [weak scrollButton] _ in
            guard let value = scrollButton?.switchView.isOn else { return }
            RootViewController.instance.smoothScrollButton.isHidden = !value
        }), for: .valueChanged)

        smoothScrollSpeed.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsEditSmoothScrollSpeedController(), sender: nil)
        }), for: .touchUpInside)

        loadWallets()
    }

    func loadWallets() {
        let userId = IdentityManager.instance.userHexPubkey

        Task { @MainActor in
            let sparkWalletIds = (try? await WalletManager.instance.sparkWalletAccountRepository
                .findAllPersistedWalletIds(userId: userId)) ?? []

            WalletManager.instance.$activeWallet
                .receive(on: DispatchQueue.main)
                .sink { [weak self] activeWallet in
                    self?.updateWalletList(userId: userId, activeWallet: activeWallet, sparkWalletIds: sparkWalletIds)
                }
                .store(in: &cancellables)
        }
    }

    func updateWalletList(userId: String, activeWallet: UserWallet?, sparkWalletIds: [String]) {
        walletListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var seenIds: Set<String> = []

        // Active wallet first
        if let active = activeWallet {
            let wallet = active.wallet
            let sats = Int((wallet.balanceInBtc?.doubleValue ?? 0) * .BTC_TO_SAT)
            let item = DevToolsWalletItemView()
            item.configure(wallet: wallet, isActive: true, lightningAddress: active.lightningAddress, balanceInSats: sats)
            walletListStack.addArrangedSubview(item)
            seenIds.insert(wallet.walletId)
        }

        // Remaining Spark wallets (deduplicated)
        for walletId in sparkWalletIds where !seenIds.contains(walletId) {
            let item = DevToolsWalletItemView()
            walletListStack.addArrangedSubview(item)
            Task { @MainActor in
                let address = try? await WalletManager.instance.sparkWalletAccountRepository
                    .getLightningAddress(userId: userId, walletId: walletId)
                item.configure(walletId: walletId, lightningAddress: address)
            }
        }
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

// MARK: - DevToolsWalletItemView

private final class DevToolsWalletItemView: UIView, Themeable {
    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    private let activeChip = UILabel()
    private let supportLabel = UILabel()
    private let copyButton = UIButton()
    private let keyButton = UIButton()

    private var walletId: String?
    private var isSpark = false
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 12

        nameLabel.font = .appFont(withSize: 16, weight: .semibold)
        balanceLabel.font = .appFont(withSize: 16, weight: .regular)
        supportLabel.font = .appFont(withSize: 13, weight: .regular)
        supportLabel.lineBreakMode = .byTruncatingTail

        activeChip.font = .appFont(withSize: 11, weight: .bold)
        activeChip.textAlignment = .center
        activeChip.clipsToBounds = true
        activeChip.isHidden = true

        copyButton.setImage(UIImage(named: "copyIcon24")?.withRenderingMode(.alwaysTemplate), for: .normal)
        copyButton.constrainToSize(32)
        copyButton.addAction(.init(handler: { [weak self] _ in
            guard let walletId = self?.walletId else { return }
            UIPasteboard.general.string = walletId
            self?.showDimmedToastCentered("Copied!")
        }), for: .touchUpInside)

        keyButton.setImage(UIImage(named: "keySmall")?.withRenderingMode(.alwaysTemplate), for: .normal)
        keyButton.constrainToSize(32)
        keyButton.isHidden = true
        keyButton.addAction(.init(handler: { [weak self] _ in
            self?.copySeedPhrase()
        }), for: .touchUpInside)

        let headlineStack = UIStackView([nameLabel, balanceLabel, activeChip])
        headlineStack.spacing = 8
        headlineStack.alignment = .center

        let leftStack = UIStackView(axis: .vertical, [headlineStack, supportLabel])
        leftStack.spacing = 4

        let mainStack = UIStackView([leftStack, UIView(), copyButton, keyButton])
        mainStack.alignment = .center
        mainStack.spacing = 8

        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 10)

        updateTheme()
    }
    
    func updateTheme() {
        backgroundColor = .background3
        nameLabel.textColor = .foreground
        balanceLabel.textColor = .foreground3
        supportLabel.textColor = .foreground4
        copyButton.tintColor = .foreground3
        keyButton.tintColor = .foreground3
        activeChip.textColor = .white
        activeChip.backgroundColor = .accent
    }

    func configure(wallet: Wallet, isActive: Bool, lightningAddress: String?, balanceInSats: Int?) {
        walletId = wallet.walletId
        isSpark = wallet is Wallet.Spark

        if wallet is Wallet.Spark {
            nameLabel.text = "Spark Wallet"
        } else if wallet is Wallet.Primal {
            nameLabel.text = "Primal Wallet"
        } else if wallet is Wallet.NWC {
            nameLabel.text = "NWC Wallet"
        } else {
            nameLabel.text = "Wallet"
        }

        if let sats = balanceInSats {
            balanceLabel.text = "\(sats.localized()) sats"
            balanceLabel.isHidden = false
        } else {
            balanceLabel.isHidden = true
        }

        activeChip.isHidden = !isActive
        if isActive {
            activeChip.text = "  ACTIVE  "
            activeChip.sizeToFit()
            activeChip.layer.cornerRadius = activeChip.intrinsicContentSize.height / 2
        }

        let truncatedId = truncateWalletId(wallet.walletId)
        if let address = lightningAddress, !address.isEmpty {
            supportLabel.text = "\(address) · \(truncatedId)"
        } else {
            supportLabel.text = truncatedId
        }

        keyButton.isHidden = !isSpark
    }

    func configure(walletId: String, lightningAddress: String?) {
        self.walletId = walletId
        isSpark = true

        nameLabel.text = "Spark Wallet"
        balanceLabel.isHidden = true
        activeChip.isHidden = true

        let truncatedId = truncateWalletId(walletId)
        if let address = lightningAddress, !address.isEmpty {
            supportLabel.text = "\(address) · \(truncatedId)"
        } else {
            supportLabel.text = truncatedId
        }

        keyButton.isHidden = false
    }

    private func truncateWalletId(_ id: String) -> String {
        guard id.count > 15 else { return id }
        return "\(id.prefix(5))...\(id.suffix(5))"
    }

    private func copySeedPhrase() {
        guard let walletId else { return }
        Task { @MainActor in
            do {
                let seed = try await WalletManager.instance.sparkWalletAccountRepository
                    .getPersistedSeedWords(walletId: walletId).getOrNull()
                let words = seed?.compactMap { $0 as? String } ?? []
                if words.isEmpty {
                    self.showDimmedToastCentered("No seed phrase found")
                } else {
                    UIPasteboard.general.string = words.joined(separator: " ")
                    self.showDimmedToastCentered("Seed phrase copied!")
                }
            } catch {
                self.showDimmedToastCentered("Failed to get seed phrase")
            }
        }
    }
}
