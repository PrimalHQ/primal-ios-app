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
    
    private var cancellables: Set<AnyCancellable> = []
    
    var depositInfo: DepositInfo? {
        didSet {
            updateInfo()
        }
    }
    
    var additionalInfo: AdditionalDepositInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestInfo()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = backButtonWithColor(.foreground)
        
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
                self?.depositInfo?.lnurl = data.lnInvoice
            } else {
                self?.navigationController?.viewControllers.remove(object: self!)
                return
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
        qrCodeImageView.image = .createQRCode(depositInfo.lnurl)
        
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
            actionButton(text: "COPY", action: { [weak self] in
                guard let lnurl = self?.depositInfo?.lnurl else { return }
                UIPasteboard.general.string = lnurl
                self?.view.showToast("Copied!")
            }),
            actionButton(text: "ADD DETAILS", action: { [weak self] in
                self?.show(WalletReceiveDetailsController(details: self?.additionalInfo ?? .init(satoshi: 0, description: ""), delegate: self), sender: nil)
            })
        ]).constrainToSize(height: 60)
        actionStack.spacing = 18
        actionStack.distribution = .fillEqually
        
        [
            parentParent,
            amountParent,               SpacerView(height: 10),
            descLabel("Receiving to:"), SpacerView(height: 4),
            ludLabel,                   SpacerView(height: 28),
            descDescLabel, descLabel,   SpacerView(height: 28),
            actionStack,
            UIView()
        ].forEach { mainStack.addArrangedSubview($0) }
        
        mainStack.setCustomSpacing(26, after: parentParent)
        mainStack.setCustomSpacing(16, after: amountParent)
        mainStack.setCustomSpacing(4, after: descDescLabel)
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .top, padding: 30, safeArea: true).pinToSuperview(edges: .bottom, padding: 86, safeArea: true)
        
        view.addSubview(loadingIndicator)
        loadingIndicator.centerToSuperview().constrainToSize(70)
        
        mainStack.isHidden = true
        loadingIndicator.play()
    }
    
    func actionButton(text: String, action: @escaping () -> Void) -> UIButton {
        let button = ThemeableButton().setTheme {
            $0.setTitleColor(.foreground, for: .normal)
            $0.backgroundColor = .background3
        }
        
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        button.setTitle(text, for: .normal)
        button.addAction(.init(handler: { _ in
            action()
        }), for: .touchUpInside)
        
        return button
    }
    
    func descLabel(_ text: String) -> UILabel {
        let descLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        descLabel.font = .appFont(withSize: 18, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.text = text
        return descLabel
    }
}
