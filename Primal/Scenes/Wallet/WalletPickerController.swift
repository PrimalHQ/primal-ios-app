//
//  WalletPickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.3.26..
//

import Combine
import UIKit
import PrimalShared

extension Wallet {
    var displayName: String {
        if self is Wallet.Spark { return "Spark Wallet" }
        if self is Wallet.Primal { return "Legacy Wallet" }
        if self is Wallet.NWC { return "NWC Wallet" }
        return "Wallet"
    }
}

protocol WalletSelectionCellDelegate: AnyObject {
    func walletSelectionCellDidTapBolt(_ cell: WalletSelectionCell)
}

final class WalletPickerController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []

    private let table = UITableView()
    private var wallets: [Wallet] = []
    private let callback: (Wallet) -> Void

    private var isEditMode = false
    private var registeredWalletId: String?
    private var registeredLightningAddress: String?
    private var previewRegisteredWalletId: String?

    private let titleLabel = UILabel()
    private let bottomBar = UIView()
    private let configureButton = UIButton()
    private let cancelButton = UIButton()
    private let doneButton = UIButton()

    // Header height: pullBar(5) + spacing(20) + title(~24) + spacing(14) + top padding(16) = ~79
    private let headerHeight: CGFloat = 79

    init(callback: @escaping (Wallet) -> Void) {
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        setup()

        if let sheet = sheetPresentationController {
            sheet.detents = [.custom(resolver: { [weak self] _ in
                guard let self else { return 300 }
                return max(300, self.preferredContentSize.height)
            })]
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWallets()
        fetchRegisteredWallet()
    }

    private func loadWallets() {
        let userId = IdentityManager.instance.userHexPubkey
        WalletManager.instance.walletAccountRepo.observeWalletsByUser(userId: userId)
            .toPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallets in
                guard let self, let wallets = wallets as? [Wallet] else { return }
                self.wallets = wallets
                self.table.reloadData()
                self.updatePreferredHeight()
            }
            .store(in: &cancellables)
    }

    private func fetchRegisteredWallet() {
        let userId = IdentityManager.instance.userHexPubkey
        Task {
            guard let status = try await WalletManager.instance.primalWalletRepo
                .fetchWalletStatus(userId: userId).getOrNull() else { return }

            await MainActor.run {
                let registeredId = status.registeredSparkWalletId
                    ?? (status.hasCustodialWallet ? userId : nil)
                self.registeredWalletId = registeredId
                self.registeredLightningAddress = status.lightningAddress
                self.table.reloadData()
            }
        }
    }

    private func updatePreferredHeight() {
        table.layoutIfNeeded()
        let contentHeight = headerHeight + table.contentSize.height + 56 // 56 for bottom bar
        preferredContentSize = CGSize(width: view.bounds.width, height: max(300, contentHeight))
        sheetPresentationController?.invalidateDetents()
    }

    private func setEditMode(_ editing: Bool) {
        isEditMode = editing
        if editing {
            previewRegisteredWalletId = registeredWalletId
        } else {
            previewRegisteredWalletId = nil
        }
        titleLabel.text = editing ? "Configure Wallets" : "Wallets"
        configureButton.isHidden = editing
        cancelButton.isHidden = !editing
        doneButton.isHidden = !editing
        table.reloadData()
    }

    private func confirmReassignment() {
        guard let previewId = previewRegisteredWalletId, previewId != registeredWalletId else {
            setEditMode(false)
            return
        }

        guard let targetWallet = wallets.first(where: { $0.walletId == previewId }) else { return }

        let userId = IdentityManager.instance.userHexPubkey

        Task {
            if targetWallet is Wallet.Spark {
                _ = try await WalletManager.instance.sparkWalletAccountRepository
                    .registerSparkWallet(userId: userId, walletId: targetWallet.walletId)
            } else if targetWallet is Wallet.Primal {
                guard let sparkWalletId = registeredWalletId else { return }
                _ = try await WalletManager.instance.sparkWalletAccountRepository
                    .unregisterSparkWallet(userId: userId, walletId: sparkWalletId)
            } else {
                return
            }

            guard let status = try await WalletManager.instance.primalWalletRepo
                .fetchWalletStatus(userId: userId).getOrNull() else { return }

            await MainActor.run {
                let registeredId = status.registeredSparkWalletId
                    ?? (status.hasCustodialWallet ? userId : nil)
                self.registeredWalletId = registeredId
                self.registeredLightningAddress = status.lightningAddress
                self.setEditMode(false)
            }
        }
    }

    private func setup() {
        view.backgroundColor = .background2
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle

        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)

        titleLabel.text = "Wallets"
        titleLabel.font = .appFont(withSize: 20, weight: .bold)
        titleLabel.textColor = .foreground
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.textAlignment = .center

        table.showsVerticalScrollIndicator = false
        table.register(WalletSelectionCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .background2

        setupBottomBar()

        let stack = UIStackView(arrangedSubviews: [
            pullBarParent, SpacerView(height: 20, priority: .required),
            titleLabel, SpacerView(height: 14, priority: .required),
            table,
            bottomBar
        ])
        table.pinToSuperview(edges: .horizontal)

        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, safeArea: true).pinToSuperview(edges: .horizontal)
        stack.axis = .vertical

        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
    }

    private func setupBottomBar() {
        let separator = UIView()
        separator.backgroundColor = .foreground6
        separator.constrainToSize(height: 1)

        configureButton.setTitle("Configure wallets", for: .normal)
        configureButton.setTitleColor(.accent, for: .normal)
        configureButton.titleLabel?.font = .appFont(withSize: 16, weight: .regular)
        configureButton.addAction(.init(handler: { [weak self] _ in
            self?.setEditMode(true)
        }), for: .touchUpInside)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.accent, for: .normal)
        cancelButton.titleLabel?.font = .appFont(withSize: 16, weight: .regular)
        cancelButton.isHidden = true
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.setEditMode(false)
        }), for: .touchUpInside)

        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.accent, for: .normal)
        doneButton.titleLabel?.font = .appFont(withSize: 16, weight: .bold)
        doneButton.isHidden = true
        doneButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmReassignment()
        }), for: .touchUpInside)

        let buttonRow = UIStackView([cancelButton, UIView(), configureButton, doneButton])
        buttonRow.alignment = .center

        let barStack = UIStackView(axis: .vertical, [separator, buttonRow])
        bottomBar.addSubview(barStack)
        barStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 8)
    }
}

extension WalletPickerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { wallets.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let wallet = wallets[indexPath.row]
        let isActive = wallet.walletId == WalletManager.instance.activeWallet?.walletId

        let effectiveRegisteredId = isEditMode ? previewRegisteredWalletId : registeredWalletId
        let isRegistered = wallet.walletId == effectiveRegisteredId
        let isNWC = wallet is Wallet.NWC

        let boltFilled: Bool?
        if isEditMode {
            boltFilled = isNWC ? nil : isRegistered
        } else {
            boltFilled = nil
        }

        let addressOverride: String?
        if isEditMode && !isNWC {
            addressOverride = isRegistered ? registeredLightningAddress : nil
        } else {
            addressOverride = wallet.lightningAddress
        }

        if let cell = cell as? WalletSelectionCell {
            cell.delegate = self
            cell.setup(wallet, selected: !isEditMode && isActive, boltFilled: boltFilled, lightningAddressOverride: addressOverride)
        }
        return cell
    }
}

extension WalletPickerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet = wallets[indexPath.row]

        if isEditMode {
            guard !(wallet is Wallet.NWC) else { return }
            previewRegisteredWalletId = wallet.walletId
            table.reloadData()
        } else {
            dismiss(animated: true)
            callback(wallet)
        }
    }
}

extension WalletPickerController: WalletSelectionCellDelegate {
    func walletSelectionCellDidTapBolt(_ cell: WalletSelectionCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let wallet = wallets[indexPath.row]
        guard !(wallet is Wallet.NWC) else { return }
        previewRegisteredWalletId = wallet.walletId
        table.reloadData()
    }
}

final class WalletSelectionCell: UITableViewCell {
    private let backgroundColorView = UIView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let balanceLabel = UILabel()
    private let satsLabel = UILabel()
    private let boltButton = UIButton()

    weak var delegate: WalletSelectionCellDelegate?

    private var isSelectedWallet = false

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        backgroundColorView.isHidden = !highlighted && !isSelectedWallet
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(backgroundColorView)
        backgroundColorView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 6)

        let leftStack = UIStackView(axis: .vertical, [titleLabel, addressLabel])
        leftStack.alignment = .leading
        leftStack.spacing = 4

        let balanceStack = UIStackView(axis: .vertical, [balanceLabel, satsLabel])
        balanceStack.alignment = .trailing
        balanceStack.spacing = 2

        boltButton.constrainToSize(44)
        boltButton.tintColor = .foreground3
        boltButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.delegate?.walletSelectionCellDidTapBolt(self)
        }), for: .touchUpInside)

        let hStack = UIStackView([leftStack, UIView(), balanceStack, boltButton])
        hStack.alignment = .center
        hStack.spacing = 8

        contentView.addSubview(hStack)
        hStack.pinToSuperview(edges: .vertical, padding: 16).pinToSuperview(edges: .horizontal, padding: 32)

        backgroundColorView.backgroundColor = .background3
        backgroundColorView.layer.cornerRadius = 8

        titleLabel.font = .appFont(withSize: 20, weight: .regular)
        titleLabel.textColor = .foreground

        addressLabel.font = .appFont(withSize: 15, weight: .regular)
        addressLabel.textColor = .foreground4

        balanceLabel.font = .appFont(withSize: 15, weight: .regular)
        balanceLabel.textColor = .foreground

        satsLabel.font = .appFont(withSize: 15, weight: .regular)
        satsLabel.textColor = .foreground4
        satsLabel.text = "sats"

        backgroundColor = .background2
        contentView.backgroundColor = .background2
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// `boltFilled`: `true` = filled bolt icon, `false` = outline bolt icon, `nil` = hidden
    func setup(_ wallet: Wallet, selected: Bool, boltFilled: Bool? = nil, lightningAddressOverride: String?) {
        titleLabel.text = wallet.displayName

        let sats = Int((wallet.balanceInBtc?.doubleValue ?? 0) * .BTC_TO_SAT)
        balanceLabel.text = sats.localized()

        if let address = lightningAddressOverride, !address.isEmpty {
            addressLabel.text = address
            addressLabel.isHidden = false
        } else {
            addressLabel.isHidden = true
        }

        if let boltFilled {
            let imageName = boltFilled ? "feedZapFilled" : "feedZap"
            boltButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
            boltButton.tintColor = boltFilled ? .accent : .foreground3
            boltButton.isHidden = false
        } else {
            boltButton.isHidden = true
        }

        isSelectedWallet = selected
        backgroundColorView.isHidden = !selected
    }
}
