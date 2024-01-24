//
//  WalletReceiveViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.10.23..
//

import Combine
import UIKit

final class WalletReceiveViewController: UIViewController, Themeable {
    private let qrCodeImageView = UIImageView()
    
    private let amountParent = UIStackView(axis: .vertical, [])
    private let amountLabel = UILabel()
    private let ludLabel = UILabel()
    
    private lazy var descDescLabel = descLabel("Description:")
    private let descLabel = UILabel()
    
    private let mainStack = UIStackView(axis: .vertical, [])
    private let loadingIndicator = LoadingSpinnerView()
    
    private lazy var ludDescLabel = descLabel("Lightning Address:")
    
    private let lightningButton = WalletSendTabButton(icon: UIImage(named: "receiveLightning"))
    private let onchainButton = WalletSendTabButton(icon: UIImage(named: "receiveBitcoin"))
    private let nfcButton = WalletSendTabButton(icon: UIImage(named: "receiveNFC"))
    
    private var activeButton: WalletSendTabButton? {
        didSet {
            oldValue?.isActive = false
            activeButton?.isActive = true
            if activeButton == lightningButton {
                onchainAddress = nil
            }
            requestInfo()
        }
    }
    
    private lazy var detailsButton = WalletActionButton(text: "ADD DETAILS", action: { [weak self] in
        self?.show(WalletReceiveDetailsController(details: self?.additionalInfo ?? .init(satoshi: 0, description: ""), delegate: self), sender: nil)
    })
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var lnInvoice: String? {
        didSet {
            updateInfo()
        }
    }
    private var onchainAddress: String? {
        didSet {
            updateInfo()
        }
    }
    
    var onchainAddressWithDetails: String? {
        guard var onchainAddress, let additionalInfo else { return onchainAddress }
        
        var hasSatoshi = additionalInfo.satoshi > 0
        if hasSatoshi {
            onchainAddress += "?amount=\(additionalInfo.satoshi.satsToBitcoinString())"
        }
        
        if !additionalInfo.description.isEmpty {
            onchainAddress += hasSatoshi ? "&" : "?"
            onchainAddress += "label=\(additionalInfo.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? additionalInfo.description)"
        }
        
        return onchainAddress
    }
    
    var invoice: String {
        onchainAddressWithDetails ?? lnInvoice ?? depositInfo?.lnurl ?? ""
    }
    
    var depositInfo: DepositInfo? {
        didSet {
            updateInfo()
        }
    }
    
    var additionalInfo: AdditionalDepositInfo? {
        didSet {
            detailsButton.setTitle(additionalInfo == nil ? "ADD DETAILS" : "EDIT DETAILS", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestInfo()
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        [ludLabel, descLabel].forEach { $0.textColor = .foreground }
        
        view.backgroundColor = .background
    }
}

extension WalletReceiveViewController: WalletReceiveDetailsControllerDelegate {
    func detailsChanged(_ details: AdditionalDepositInfo) {
        additionalInfo = details
    }
}

private extension WalletReceiveViewController {
    func requestInfo() {
        let network = activeButton == lightningButton ? WalletTransactionNetwork.lightning : .onchain
        PrimalWalletRequest(type: .deposit(network, additionalInfo)).publisher().receive(on: DispatchQueue.main).sink { [weak self] res in
            if let data = res.depositInfo {
                self?.depositInfo = data
            } else if let data = res.invoiceInfo {
                self?.lnInvoice = data.lnInvoice
            } else if let onchain = res.onchainAddress {
                self?.onchainAddress = onchain
            } else {
                if let message = res.message {
                    self?.showErrorMessage(message)
                }
                self?.additionalInfo = nil
            }
        }
        .store(in: &cancellables)
    }
    
    func updateInfo() {
        guard let depositInfo else {
            mainStack.isHidden = true
            loadingIndicator.isHidden = false
            loadingIndicator.play()
            return
        }
        
        mainStack.isHidden = false
        loadingIndicator.isHidden = true
        loadingIndicator.stop()
        
        if let onchainAddress {
            ludDescLabel.text = "Bitcoin Address:"
            ludLabel.text = onchainAddress
        } else {
            ludDescLabel.text = "Lightning Address:"
            ludLabel.text = depositInfo.lud16
        }
        
        qrCodeImageView.image = .createQRCode("bitcoin:\(invoice)")
        
        guard let additionalInfo else {
            amountParent.isHidden = true
            descDescLabel.isHidden = true
            descLabel.isHidden = true
            return
        }
        
        amountParent.isHidden = additionalInfo.satoshi <= 0
        descDescLabel.isHidden = additionalInfo.description.isEmpty
        descLabel.isHidden = additionalInfo.description.isEmpty
        
        descLabel.text = additionalInfo.description
        amountLabel.text = additionalInfo.satoshi.localized()
    }
    
    func setup() {
        updateTheme()
        title = "Receive"
        
        let qrCodeParent = UIView()
        qrCodeParent.backgroundColor = .white
        qrCodeParent.layer.cornerRadius = 12
        
        qrCodeParent.addSubview(qrCodeImageView)
        qrCodeImageView.pinToSuperview(padding: 16)
        qrCodeParent.heightAnchor.constraint(equalTo: qrCodeParent.widthAnchor).isActive = true
        qrCodeImageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        qrCodeImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let parentParent = UIView()
        parentParent.addSubview(qrCodeParent)
        qrCodeParent.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let width = qrCodeParent.widthAnchor.constraint(equalTo: parentParent.widthAnchor, constant: -40)
        width.priority = .defaultHigh
        width.isActive = true
        
        qrCodeImageView.contentMode = .scaleAspectFit
        
        let satsLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        satsLabel.text = "sats"
        satsLabel.font = .appFont(withSize: 18, weight: .bold)
        satsLabel.transform = .init(translationX: 0, y: 10)
        
        amountLabel.font = .appFont(withSize: 48, weight: .bold)
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.constrainToSize(height: 60)
        
        amountParent.addArrangedSubview(UIStackView([amountLabel, satsLabel]))
        amountParent.alignment = .center
        
        [ludLabel, descLabel].forEach {
            $0.font = .appFont(withSize: 18, weight: .bold)
            $0.textAlignment = .center
        }
        descLabel.numberOfLines = 3
        
        let actionStack = UIStackView([
            WalletActionButton(text: "COPY", action: { [weak self] in
                guard let invoice = self?.invoice else { return }
                UIPasteboard.general.string = invoice
                self?.view.showToast("Copied!", extraPadding: false)
            }),
            detailsButton
        ])
        actionStack.spacing = 18
        actionStack.distribution = .fillEqually
        
        [
            SpacerView(height: 44),
            parentParent,               SpacerView(height: 18), SpacerView(height: 8, priority: .required),
            amountParent,               SpacerView(height: 26),
            ludDescLabel,               SpacerView(height: 4, priority: .required),
            ludLabel,                   SpacerView(height: 20), SpacerView(height: 8, priority: .required),
            descDescLabel, descLabel,   SpacerView(height: 20), SpacerView(height: 8, priority: .required),
            actionStack,                SpacerView(height: 30, priority: .required),
            UIView()
        ].forEach { mainStack.addArrangedSubview($0) }
        
        mainStack.setCustomSpacing(4, after: descDescLabel)
        
        [descDescLabel, descLabel, ludDescLabel, ludLabel].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        ludLabel.lineBreakMode = .byTruncatingMiddle
        
        let mainStackParent = UIView()
        mainStackParent.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical)
        
        let selectionStack = UIStackView([lightningButton, onchainButton, nfcButton])
        let selectionStackParent = UIView()
        selectionStackParent.addSubview(selectionStack)
        selectionStack.pinToSuperview(edges: .vertical, padding: 16).centerToSuperview()
        selectionStack.spacing = 65
        
        let viewStack = UIStackView(axis: .vertical, [mainStackParent, SpacerView(height: 1, color: .background3), selectionStackParent])
        view.addSubview(viewStack)
        viewStack.pinToSuperview(safeArea: true)
        
        view.addSubview(loadingIndicator)
        loadingIndicator.centerToSuperview().constrainToSize(70)
        
        mainStack.isHidden = true
        loadingIndicator.play()
        
        [lightningButton, onchainButton].forEach { button in
            button.addAction(.init(handler: { [weak self] _ in
                self?.activeButton = button
            }), for: .touchUpInside)
        }
        activeButton = lightningButton
        
        nfcButton.isHidden = true
        nfcButton.addAction(.init(handler: { [weak self] _ in
            self?.showErrorMessage("NFC is coming soon")
        }), for: .touchUpInside)
    }
    
    func descLabel(_ text: String) -> UILabel {
        let descLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        descLabel.font = .appFont(withSize: 18, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.text = text
        return descLabel
    }
}

final class WalletActionButton: UIButton, Themeable {
    init(text: String, action: @escaping () -> Void) {
        super.init(frame: .zero)
        
        updateTheme()
        layer.cornerRadius = 30
        titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        setTitle(text, for: .normal)
        addAction(.init(handler: { _ in
            action()
        }), for: .touchUpInside)
        
        constrainToSize(height: 60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateTheme() {
        setTitleColor(.foreground, for: .normal)
        backgroundColor = .background3
    }
}
