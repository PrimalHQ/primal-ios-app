//
//  WalletSendViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.23..
//

import Combine
import FLAnimatedImage
import UIKit

final class WalletSendViewController: UIViewController, Themeable {
    enum Destination {
        case user(ParsedUser, startingAmount: Int = 0)
        case address(String, ParsedLNInvoice?, ParsedUser?, startingAmount: Int? = nil)
        
        var user: ParsedUser? {
            switch self {
            case let .user(user, _):
                return user
            case .address(_, _, let user, _):
                return user
            }
        }
        
        var address: String {
            switch self {
            case let .user(user, _):
                return user.data.lud16.isEmpty ? user.data.lud06 : user.data.lud16
            case .address(let address, let invoice, let user, _):
                if address.isBitcoinAddress {
                    return address.parsedBitcoinAddress.0
                }
                return user?.data.lud16 ?? invoice?.lninvoice.description ?? address
            }
        }
        
        var startingAmount: Int {
            switch self {
            case .user(_, let amount):                              return amount
            case .address(let address, let parsed, _, let startingAmount):
                return startingAmount ?? (parsed?.lninvoice.amount_msat ?? 0) / 1000
            }
        }
        
        var name: String? {
            user?.data.name ?? (address.isBitcoinAddress ? "Bitcoin Address" : nil)
        }
        
        var message: String {
            switch self {
            case .user:                     return ""
            case .address(let address, let parsed, _, _):
                if address.isBitcoinAddress {
                    return address.parsedBitcoinAddress.2 ?? ""
                }
                
                guard let desc = parsed?.lninvoice.description?.removingPercentEncoding else { return "" }
                
                return desc.split(separator: " ").dropFirst(3).joined(separator: " ")
            }
        }
        
        var isEditable: Bool {
            switch self {
            case .user:                     return true
            case .address(_, let parsed, _, _):  return parsed == nil || parsed?.lninvoice.amount_msat == 0
            }
        }
    }
    
    let destination: Destination
    
    let input = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let messageInput = PlaceholderTextView()
    let feeView = MiningFeeView()
    let scrollView = UIScrollView()
    
    var cancellables = Set<AnyCancellable>()
    
    init(_ destination: Destination) {
        self.destination = destination
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        input.balance = destination.startingAmount
        messageInput.text = destination.message
        
        messageInput.superview?.isHidden = !destination.isEditable
        messageInput.isUserInteractionEnabled = destination.isEditable
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        view.backgroundColor = .background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        messageInput.resignFirstResponder()
    }
}

private extension WalletSendViewController {
    func setup() {
        title = "Sending To"
        
        let sizingView = UIView()
        view.addSubview(sizingView)
        sizingView.pinToSuperview(edges: .top, safeArea: true)
        sizingView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        let profilePictureView = FLAnimatedImageView().constrainToSize(88)
        let nipLabel = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        let nameLabel = UILabel()
        
        let messageParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        sendButton.backgroundColor = .accent2
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        sendButton.constrainToSize(height: 58)
        sendButton.layer.cornerRadius = 29
        
        let infoParent = UIStackView(axis: .vertical, [profilePictureView, SpacerView(height: 12), nipLabel, SpacerView(height: 2)])
        infoParent.alignment = .center
        
        let inputParent = UIView()
        let inputStack = UIStackView(axis: .vertical, [inputParent, SpacerView(height: 12)])
        
        let cancelButton = SimpleRoundedButton(title: "Cancel")
        let buttonStack = UIStackView([cancelButton, sendButton])
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 18
    
        let messageStack = UIStackView(axis: .vertical, [
            messageParent,
            feeView,
            SpacerView(height: 264 - (destination.address.isBitcoinAddress ? 108 : 48), priority: .defaultLow),
            buttonStack
        ])
        messageStack.spacing = 16
        
        let stack = UIStackView(axis: .vertical, [
            infoParent,
            inputStack,
            messageStack
        ])
        stack.distribution = .equalSpacing
        
        buttonStack.pinToSuperview(edges: .horizontal)
        messageStack.pinToSuperview(edges: .horizontal)
        inputStack.pinToSuperview(edges: .horizontal)
        
        if let name = destination.name {
            nameLabel.text = name
            nameLabel.font = .appFont(withSize: 20, weight: .semibold)
            nameLabel.textColor = .foreground
            infoParent.insertArrangedSubview(nameLabel, at: 2)
        }
        
        messageParent.pinToSuperview(edges: .horizontal)
        messageParent.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        messageParent.addSubview(messageInput)
        messageParent.layer.cornerRadius = 24
        
        inputParent.addSubview(input)
        input.pinToSuperview(edges: .vertical)
        input.largeAmountLabel.centerToView(inputParent, axis: .horizontal)
        
        messageInput.pinToSuperview(edges: .horizontal, padding: 10).pinToSuperview(edges: .top, padding: 6).pinToSuperview(edges: .bottom, padding: 2)
        messageInput.font = .appFont(withSize: 16, weight: .regular)
        messageInput.backgroundColor = .clear
        messageInput.mainTextColor = .foreground
        messageInput.placeholderTextColor = .foreground.withAlphaComponent(0.6)
        messageInput.didBeginEditing = { [weak self] textView in
            guard let self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.scrollView.scrollRectToVisible(textView.convert(textView.frame, to: self.scrollView), animated: true)
            }
        }
        messageInput.setContentCompressionResistancePriority(.required, for: .vertical)
        
        scrollView.keyboardDismissMode = .interactiveWithAccessory
        view.addSubview(scrollView)
        scrollView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        let bot = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bot.priority = .defaultHigh
        bot.isActive = true
        
        scrollView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical, padding: 20)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -72).isActive = true
        let height = stack.heightAnchor.constraint(equalTo: sizingView.heightAnchor, constant: -50)
        height.priority = .init(500)
        height.isActive = true
        
        stack.alignment = .center
        
        profilePictureView.contentMode = .scaleAspectFill
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.cornerRadius = 44
        
        if let user = destination.user {
            profilePictureView.setUserImage(user)
            messageInput.placeholderText = "message for \(user.data.firstIdentifier)"
        } else {
            profilePictureView.image = destination.address.isBitcoinAddress ? UIImage(named: "onchainPayment") : UIImage(named: "nonZapPayment")
            messageInput.placeholderText = "message"
        }
        
        feeView.isHidden = !destination.address.isBitcoinAddress
        
        nipLabel.text = destination.address
        nipLabel.font = .appFont(withSize: 16, weight: .regular)
        nipLabel.textAlignment = .center
        
        if destination.address.isBitcoinAddress {
            nipLabel.numberOfLines = 1
            nipLabel.lineBreakMode = .byTruncatingMiddle
        } else {
            nipLabel.numberOfLines = 2
        }
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapView()
            self?.send(sender: sendButton)
        }), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tap)
        
        updateTheme()
    }
    
    @objc func didTapView() {
        messageInput.resignFirstResponder()
    }
    
    func send(sender: UIButton) {
        Task { @MainActor in
            
            let amount = input.balance
            let note = messageInput.text ?? ""
            
            if amount < 1 {
                return
            }
            
            let spinnerVC = WalletSpinnerViewController(sats: amount, address: destination.address)
            navigationController?.pushViewController(spinnerVC, animated: true)
            
            do {
                switch self.destination {
                case .user(let user, _):
                    try await WalletManager.instance.send(
                        user: user.data,
                        sats: amount,
                        note: note
                    )
                case let .address(address, invoice, user, _):
                    if address.isBitcoinAddress {
                        try await WalletManager.instance.sendOnchain(address, sats: amount, note: note)
                    } else if address.isEmail {
                        try await WalletManager.instance.sendLud16(address, sats: amount, note: note)
                    } else if address.hasPrefix("lnurl") {
                        try await WalletManager.instance.sendLNURL(
                            lnurl: address,
                            pubkey: user?.data.pubkey,
                            sats: amount,
                            note: messageInput.text ?? ""
                        )
                    } else {
                        if invoice?.lninvoice.amount_msat ?? 0 == 0 {
                            try await WalletManager.instance.sendLNInvoice(address, satsOverride: amount, messageOverride: messageInput.text)
                        } else {
                            try await WalletManager.instance.sendLNInvoice(address, satsOverride: nil, messageOverride: nil)
                        }
                    }
                }
                
                navigationController?.present(WalletTransferSummaryController(.success(amount: amount, address: destination.address)), animated: true) { [weak self] in
                    guard let self else { return }
                    
                    navigationController?.popToViewController(self, animated: false)
                    if let amountVC = navigationController?.viewControllers.first(where: { $0 as? WalletSendAmountController != nil }) {
                        navigationController?.viewControllers.remove(object: amountVC)
                    }
                    navigationController?.viewControllers.remove(object: self)
                }
            } catch {
                let message = (error as? WalletError)?.message ?? error.localizedDescription
                navigationController?.present(WalletTransferSummaryController(.failure(navTitle: "Payment Failed", title: "Unable to send", message: message)), animated: true) {
                    self.navigationController?.popToViewController(self, animated: false)
                }
            }
        }
    }
}

final class MiningFeeView: UIView {
    let descLabel = UILabel()
    let feeLabel = UILabel()
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([descLabel, UIView(), feeLabel])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        constrainToSize(height: 48)
        
        layer.cornerRadius = 24
        backgroundColor = .background3
        
        descLabel.text = "Mining fee"
        feeLabel.text = "Fast: $0.82"
        descLabel.font = .appFont(withSize: 16, weight: .regular)
        feeLabel.font = .appFont(withSize: 16, weight: .regular)
        descLabel.textColor = .foreground
        feeLabel.textColor = .foreground
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
