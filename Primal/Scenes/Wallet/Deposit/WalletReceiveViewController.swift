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
    
    private lazy var detailsButton = WalletActionButton(text: "ADD DETAILS", action: { [weak self] in
        self?.show(WalletReceiveDetailsController(details: self?.additionalInfo ?? .init(satoshi: 0, description: ""), delegate: self), sender: nil)
    })
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var lnInvoice: String? {
        didSet {
            updateInfo()
        }
    }
    var invoice: String { lnInvoice ?? depositInfo?.lnurl ?? "" }
    
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
        PrimalWalletRequest(type: .deposit(additionalInfo)).publisher().receive(on: DispatchQueue.main).sink { [weak self] res in
            if let data = res.depositInfo {
                self?.depositInfo = data
            } else if let data = res.invoiceInfo {
                self?.lnInvoice = data.lnInvoice
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
        
        ludLabel.text = depositInfo.lud16
        qrCodeImageView.image = .createQRCode(invoice)
        
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
        qrCodeParent.layer.cornerRadius = 24
        
        qrCodeParent.addSubview(qrCodeImageView)
        qrCodeImageView.pinToSuperview(padding: 20)
        qrCodeParent.heightAnchor.constraint(equalTo: qrCodeParent.widthAnchor).isActive = true
        qrCodeImageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        qrCodeImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let parentParent = UIView()
        parentParent.addSubview(qrCodeParent)
        qrCodeParent.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let width = qrCodeParent.widthAnchor.constraint(equalTo: parentParent.widthAnchor)
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
        
        let ludDescLabel = descLabel("Receiving to:")
        
        [
            SpacerView(height: 30),
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
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .vertical, safeArea: true)
        
        view.addSubview(loadingIndicator)
        loadingIndicator.centerToSuperview().constrainToSize(70)
        
        mainStack.isHidden = true
        loadingIndicator.play()
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
