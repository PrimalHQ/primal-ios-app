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
    private let infoStack = UIStackView(axis: .vertical, [])
    private let loadingIndicator = LoadingSpinnerView()
    
    private lazy var ludDescLabel = descLabel("Lightning Address:")
    
    private let lightningButton = WalletSendTabButton(icon: UIImage(named: "receiveLightning"))
    private let onchainButton = WalletSendTabButton(icon: UIImage(named: "receiveBitcoin"))
    private let nfcButton = WalletSendTabButton(icon: UIImage(named: "receiveNFC"))
    
    private let lightningImage = UIImage(named: "qr-lightning")
    private let bitcoinImage = UIImage(named: "qr-btc")
    
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
            if onchainAddress != nil {
                updateInfo()
            }
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
    
    private var ludHeightC: NSLayoutConstraint?
    var isFirstTime = true
    var oldQRCode = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstTime {
            isFirstTime = false
        } else {
            requestInfo()
        }
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        let hasExtraInfo = additionalInfo?.satoshi ?? 0 > 0 || !(additionalInfo?.description ?? "").isEmpty
        
        ludHeightC?.isActive = !hasExtraInfo
        
        let protocolType = onchainAddress == nil ? "lightning" : "bitcoin"
        let newQRCode = "\(protocolType):\(invoice)"
        
        if qrCodeImageView.image == nil {
            if let onchainAddress {
                ludDescLabel.text = "Bitcoin Address:"
                ludLabel.text = onchainAddress
                ludLabel.font = .appFont(withSize: 18, weight: .bold)
                ludLabel.adjustsFontSizeToFitWidth = false
                
                qrCodeImageView.image = .createQRCode(newQRCode, dimension: 231, logo: bitcoinImage)
            } else {
                ludDescLabel.text = "Lightning Address:"
                ludLabel.text = depositInfo.lud16
                
                if hasExtraInfo {
                    ludLabel.font = .appFont(withSize: 18, weight: .bold)
                    ludLabel.adjustsFontSizeToFitWidth = false
                } else {
                    ludLabel.font = .appFont(withSize: 48, weight: .bold)
                    ludLabel.adjustsFontSizeToFitWidth = true
                }
                
                qrCodeImageView.image = .createQRCode(newQRCode, dimension: 231, logo: lightningImage)
            }
        } else {
            if newQRCode != oldQRCode {
                UIView.transition(with: qrCodeImageView.superview ?? qrCodeImageView, duration: 0.4, options: .transitionFlipFromLeft) { [self] in
                    if onchainAddress != nil {
                        qrCodeImageView.image = .createQRCode(newQRCode, dimension: 231, logo: bitcoinImage)
                    } else {
                        qrCodeImageView.image = .createQRCode(newQRCode, dimension: 231, logo: lightningImage)
                    }
                }
            }
            
            UIView.transition(with: infoStack, duration: 0.4, options: .transitionCrossDissolve) { [self] in
                if hasExtraInfo || onchainAddress != nil {
                    ludLabel.font = .appFont(withSize: 18, weight: .bold)
                    ludLabel.adjustsFontSizeToFitWidth = false
                } else {
                    ludLabel.font = .appFont(withSize: 48, weight: .bold)
                    ludLabel.adjustsFontSizeToFitWidth = true
                }
                
                ludLabel.text = onchainAddress ?? depositInfo.lud16
                ludDescLabel.text = onchainAddress != nil ? "Bitcoin Address:" : "Lightning Address:"
            }
        }
        
        oldQRCode = newQRCode
        
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
                guard let self else { return }
                
                UIPasteboard.general.string = invoice
                
                qrCodeParent.showDimmedToastCentered("Copied!")
            }),
            detailsButton
        ])
        actionStack.spacing = 18
        actionStack.distribution = .fillEqually
        
        [
            amountParent,               SpacerView(height: 26),
            ludDescLabel,               SpacerView(height: 4, priority: .required),
            ludLabel,                   SpacerView(height: 20), SpacerView(height: 8, priority: .required),
            descDescLabel, descLabel
        ].forEach { infoStack.addArrangedSubview($0) }
        
        [
            SpacerView(height: 44),
            parentParent,               SpacerView(height: 18), SpacerView(height: 8, priority: .required),
            infoStack,                  SpacerView(height: 20), SpacerView(height: 8, priority: .required),
            actionStack,                SpacerView(height: 30, priority: .required),
            UIView()
        ].forEach { mainStack.addArrangedSubview($0) }
        
        mainStack.setCustomSpacing(4, after: descDescLabel)
        
        [descDescLabel, descLabel, ludDescLabel, ludLabel].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        ludLabel.lineBreakMode = .byTruncatingMiddle
        ludHeightC = ludLabel.heightAnchor.constraint(equalToConstant: 58)
        ludLabel.isUserInteractionEnabled = true
        ludLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let text = self?.ludLabel.text else { return }
            
            UIPasteboard.general.string = text
            qrCodeParent.showDimmedToastCentered("Copied!")
        }))
        
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
        
        if !WalletManager.instance.hasPremium {
            let button = UIButton(
                configuration: .accent("get a custom lightning address", font: .appFont(withSize: 16, weight: .regular)),
                primaryAction: .init(handler: { [weak self]_ in
                    self?.show(PremiumViewController(), sender: nil)
                })
            )
            mainStack.addSubview(button)
            button
                .centerToView(ludLabel, axis: .horizontal)
                .pin(to: ludLabel, edges: .top, padding: 50)
        }
        
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
        
        guard WalletManager.instance.primal == nil else { return }
        
        selectionStackParent.isHidden = true
        detailsButton.isHidden = true
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
