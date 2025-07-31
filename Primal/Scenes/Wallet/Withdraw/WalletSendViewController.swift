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
        
        var addressDisplay: String {
            switch self {
            case let .user(user, _):
                return user.data.lud16.isEmpty ? user.data.lud06 : user.data.lud16
            case .address(let address, let invoice, let user, _):
                if address.isBitcoinAddress {
                    return "Bitcoin Address"
                }
                return user?.data.lud16 ?? "Lightning Invoice"
            }
        }
        
        var startingAmount: Int {
            switch self {
            case .user(_, let amount):                              return amount
            case .address(_, let parsed, _, let startingAmount):
                return startingAmount ?? (parsed?.lninvoice.amount_msat ?? 0) / 1000
            }
        }
        
        var name: String? {
            user?.data.name
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
            case .address(_, let parsed, _, _):  return parsed == nil || parsed?.lninvoice.description?.isEmpty != false
            }
        }
    }
    
    let destination: Destination
    
    let profilePictureView = UserImageView(height: 88)
    let nameLabel = UILabel()
    let input = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let messageInput = PlaceholderTextView()
    let messageParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
    let feeView = MiningFeeView()
    let sendButton = UIButton()
    
    var tiers: [WalletOnchainTier] = [] {
        didSet {
            feeView.alpha = tiers.isEmpty ? 0.01 : 1
            selectedTier = tiers.first
        }
    }
    var selectedTier: WalletOnchainTier? {
        didSet {
            guard let selectedTier else { return }
            feeView.feeLabel.text = "\(selectedTier.name): \(selectedTier.price)"
        }
    }
    var selectedTierIndex: Int { tiers.firstIndex(where: { $0.id == selectedTier?.id }) ?? 0 }
    
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
        
        let nipLabel = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        sendButton.backgroundColor = .accent
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        sendButton.constrainToSize(height: 58)
        sendButton.layer.cornerRadius = 29
        
        let infoParent = UIStackView(axis: .vertical, [profilePictureView, SpacerView(height: 12), nipLabel, SpacerView(height: 2)])
        infoParent.alignment = .center
        
        let inputParent = UIView()
        let inputStack = UIStackView(axis: .vertical, [inputParent, SpacerView(height: 12)])
    
        let bottomView = UIView()
        let bottomStack = UIStackView(axis: .vertical, [
            messageParent,
            feeView,
            UIView(),
            sendButton
        ])
        
        bottomStack.setCustomSpacing(16, after: messageParent)
        bottomStack.setCustomSpacing(16, after: feeView)
        bottomView.addSubview(bottomStack)
        bottomStack.pinToSuperview()

        let botH = bottomView.heightAnchor.constraint(equalToConstant: 354)
        botH.priority = .init(300)
        botH.isActive = true
        
        let stack = UIStackView(axis: .vertical, [
            infoParent,
            SpacerView(height: 16, priority: .required),
            inputStack,
            SpacerView(height: 16, priority: .required),
            bottomView
        ])
        stack.distribution = .equalSpacing
        
        bottomView.pinToSuperview(edges: .horizontal)
        inputStack.pinToSuperview(edges: .horizontal)
        
        nipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        if let name = destination.name {
            nameLabel.text = name
            nameLabel.font = .appFont(withSize: 20, weight: .semibold)
            nameLabel.textColor = .foreground
            infoParent.insertArrangedSubview(nameLabel, at: 2)
            nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        messageParent.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        messageParent.addSubview(messageInput)
        messageParent.layer.cornerRadius = 24
        
        inputParent.addSubview(input)
        input.pinToSuperview()
        input.largeAmountLabel.centerToView(inputParent, axis: .horizontal)
        
        messageInput.pinToSuperview(edges: .horizontal, padding: 10).pinToSuperview(edges: .top, padding: 6).pinToSuperview(edges: .bottom, padding: 2)
        messageInput.font = .appFont(withSize: 16, weight: .regular)
        messageInput.backgroundColor = .clear
        messageInput.mainTextColor = .foreground
        messageInput.textAlignment = .center
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
        height.priority = .defaultHigh
        height.isActive = true
        
        stack.alignment = .center
        
        if let user = destination.user {
            profilePictureView.setUserImage(user)
            messageInput.placeholderText = "message for \(user.data.firstIdentifier)"
            
            profilePictureView.addGestureRecognizer(BindableTapGestureRecognizer { [weak self] in
                self?.show(ProfileViewController(profile: user), sender: nil)
            })
        } else {
            if destination.address.isBitcoinAddress {
                profilePictureView.image = .onchainPayment
                messageInput.placeholderText = "Add note to self"
            } else {
                profilePictureView.image = .nonZapPaymentDynamic
                profilePictureView.animatedImageView.clipsToBounds = false
                messageInput.placeholderText = "message"
            }
        }
        
        feeView.isHidden = !destination.address.isBitcoinAddress
        feeView.alpha = 0.01
        
        nipLabel.text = destination.addressDisplay
        nipLabel.font = .appFont(withSize: 16, weight: .regular)
        nipLabel.textAlignment = .center
        
        if destination.address.isBitcoinAddress {
            nipLabel.numberOfLines = 1
            nipLabel.lineBreakMode = .byTruncatingMiddle
            
            PrimalWalletRequest(type: .onchainPaymentTiers(address: destination.address, amount: destination.startingAmount.satsToBitcoinString())).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    self?.tiers = res.tiers.map {
                        var price: String = "\($0.estimatedFee.amount) \($0.estimatedFee.currency)"
                        if let amount = Double($0.estimatedFee.amount) {
                            let usd = amount * .BTC_TO_USD
                            price = "$\(usd.localized())"
                        }
                        
                        let min = $0.estimatedDeliveryDurationInMin
                        var time = min.localized() + " min"
                        
                        if min >= 120 {
                            let hours = min / 60
                            
                            if hours >= 24 {
                                let days = hours / 24
                                
                                time = "\(days) day"
                            } else {
                                time = "\(hours) hour"
                            }
                        }
                        
                        return .init(name: $0._label, price: price, length: time, id: $0.id)
                    }
                }
                .store(in: &cancellables)
        } else {
            nipLabel.numberOfLines = 2
        }
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            messageInput.resignFirstResponder()
            send(sender: sendButton)
        }), for: .touchUpInside)
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.messageInput.resignFirstResponder()
        }))
        
        feeView.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            present(WalletOnchainTierPickController(tiers: self.tiers, selectedIndex: self.selectedTierIndex, delegate: self), animated: true)
        }), for: .touchUpInside)
        
        updateTheme()
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
                        try await WalletManager.instance.sendOnchain(destination.address, tier: selectedTier?.id ?? "tier_fast", sats: amount, note: note)
                    } else if address.isEmail {
                        try await WalletManager.instance.sendLud16(address, sats: amount, note: note)
                    } else if address.lowercased().hasPrefix("lnurl") {
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
                
                // Have to use this callback as sometimes the result would come too soon
                spinnerVC.onAppearCallback = { [weak self] in
                    guard let self else { return }
                    
                    let summary = WalletTransferSummaryController(.paymentSuccess(amount: amount, address: destination.address))
                    navigationController?.pushViewController(summary, animated: true)
                    
                    summary.view.isUserInteractionEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        summary.view.isUserInteractionEnabled = true
                        self.navigationController?.viewControllers.removeAll(where: {
                            $0 as? WalletSendAmountController != nil ||
                            $0 as? WalletSendParentViewController != nil ||
                            $0 as? WalletSendViewController != nil
                        })
                    }
                }
            } catch {
                let message = (error as? WalletError)?.message ?? error.localizedDescription
                
                navigationController?.pushViewController(WalletTransferSummaryController(.failure(navTitle: "Payment Failed", title: "Unable to send", message: message)), animated: true)
            }
        }
    }
}

extension WalletSendViewController: WalletOnchainTierPickDelegate {
    func didPickTier(_ tier: String) {
        selectedTier = tiers.first(where: { $0.id == tier }) ?? selectedTier
    }
}

final class MiningFeeView: MyButton {
    let descLabel = UILabel()
    let feeLabel = UILabel()
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([descLabel, UIView(), feeLabel])
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        constrainToSize(height: 48)
        
        layer.cornerRadius = 24
        backgroundColor = .background3
        
        descLabel.text = "Mining fee"
        feeLabel.text = "----"
        descLabel.font = .appFont(withSize: 16, weight: .regular)
        feeLabel.font = .appFont(withSize: 16, weight: .regular)
        descLabel.textColor = .foreground
        feeLabel.textColor = .foreground
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
