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

final class WalletPickerController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []

    private let table = UITableView()
    private var wallets: [Wallet] = []
    private let callback: (Wallet) -> Void

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

    private func updatePreferredHeight() {
        table.layoutIfNeeded()
        let contentHeight = headerHeight + table.contentSize.height
        preferredContentSize = CGSize(width: view.bounds.width, height: max(300, contentHeight))
        sheetPresentationController?.invalidateDetents()
    }

    private func setup() {
        view.backgroundColor = .background2
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle

        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)

        let title = UILabel()
        title.text = "Wallets"
        title.font = .appFont(withSize: 20, weight: .bold)
        title.textColor = .foreground
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.textAlignment = .center

        table.showsVerticalScrollIndicator = false
        table.register(WalletSelectionCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .background2

        let stack = UIStackView(arrangedSubviews: [
            pullBarParent, SpacerView(height: 20, priority: .required),
            title, SpacerView(height: 14, priority: .required),
            table
        ])
        table.pinToSuperview(edges: .horizontal)

        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, safeArea: true).pinToSuperview(edges: .horizontal)
        stack.axis = .vertical

        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
    }
}

extension WalletPickerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { wallets.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let wallet = wallets[indexPath.row]
        let isActive = wallet.walletId == WalletManager.instance.activeWallet?.walletId
        (cell as? WalletSelectionCell)?.setup(wallet, selected: isActive)
        return cell
    }
}

extension WalletPickerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet = wallets[indexPath.row]
        dismiss(animated: true)
        callback(wallet)
    }
}

final class WalletSelectionCell: UITableViewCell {
    private let backgroundColorView = UIView()
    private let titleLabel = UILabel()
    private let balanceLabel = UILabel()
    private let addressLabel = UILabel()

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

        let vStack = UIStackView(axis: .vertical, [titleLabel, balanceLabel, addressLabel])
        vStack.alignment = .leading
        vStack.spacing = 4

        contentView.addSubview(vStack)
        vStack.pinToSuperview(edges: .vertical, padding: 16).centerToSuperview()
        let leading = vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        leading.priority = .required
        leading.isActive = true

        backgroundColorView.backgroundColor = .background3
        backgroundColorView.layer.cornerRadius = 8

        titleLabel.font = .appFont(withSize: 20, weight: .regular)
        titleLabel.textColor = .foreground

        balanceLabel.font = .appFont(withSize: 15, weight: .regular)
        balanceLabel.textColor = .foreground4

        addressLabel.font = .appFont(withSize: 15, weight: .regular)
        addressLabel.textColor = .foreground4

        backgroundColor = .background2
        contentView.backgroundColor = .background2
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup(_ wallet: Wallet, selected: Bool) {
        titleLabel.text = wallet.displayName

        let sats = Int((wallet.balanceInBtc?.doubleValue ?? 0) * .BTC_TO_SAT)
        balanceLabel.text = sats.localized() + " sats"

        if let address = wallet.lightningAddress, !address.isEmpty {
            addressLabel.text = address
            addressLabel.isHidden = false
        } else {
            addressLabel.isHidden = true
        }

        isSelectedWallet = selected
        backgroundColorView.isHidden = !selected
    }
}
