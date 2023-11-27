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
        case user(ParsedUser)
        case address(String, ParsedLNInvoice?, ParsedUser?)
        
        var user: ParsedUser? {
            switch self {
            case let .user(user):
                return user
            case .address(_, _, let user):
                return user
            }
        }
        
        var address: String {
            switch self {
            case let .user(user):
                return user.data.lud16.isEmpty ? user.data.lud06 : user.data.lud16
            case .address(_, let invoice, let user):
                return user?.data.lud16 ?? invoice?.lninvoice.description ?? ""
            }
        }
        
        var startingAmount: Int {
            switch self {
            case .user:                     return 0
            case .address(_, let parsed, _):  return (parsed?.lninvoice.amount_msat ?? 0) / 1000
            }
        }
        
        var message: String {
            switch self {
            case .user:                     return ""
            case .address(_, let parsed, _):
                guard let desc = parsed?.lninvoice.description?.removingPercentEncoding else { return "" }
                
                return desc.split(separator: " ").dropFirst(3).joined(separator: " ")
            }
        }
        
        var isEditable: Bool {
            switch self {
            case .user:                     return true
            case .address(_, let parsed, _):  return parsed == nil || parsed?.lninvoice.amount_msat == 0
            }
        }
    }
    
    let destination: Destination
    
    let input = LargeBalanceConversionInputView()
    let messageInput = PlaceholderTextView()
    
    let scrollView = UIScrollView()
    
    var cancellables = Set<AnyCancellable>()
    
    init(_ destination: Destination) {
        self.destination = destination
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        input.balance = destination.startingAmount
        messageInput.text = destination.message
        
        input.isUserInteractionEnabled = destination.isEditable
        messageInput.isHidden = !destination.isEditable
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        input.becomeFirstResponder()
    }
}

private extension WalletSendViewController {
    func setup() {
        title = "Sending To"
        
        let sizingView = UIView()
        view.addSubview(sizingView)
        sizingView.pinToSuperview(edges: .top, safeArea: true)
        sizingView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        let profilePictureView = FLAnimatedImageView().constrainToSize(120)
        let nipLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        
        let messageParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        
        let sendButton = LargeRoundedButton(title: "Send")
        
        let stack = UIStackView(axis: .vertical, [
            profilePictureView, SpacerView(height: 12),
            nipLabel, SpacerView(height: 12), SpacerView(height: 20, priority: .defaultLow),
            input, SpacerView(height: 12), SpacerView(height: 20, priority: .defaultLow),
            messageParent, SpacerView(height: 12), SpacerView(height: 32, priority: .init(400)), UIView(),
            sendButton
        ])
        
        sendButton.pinToSuperview(edges: .horizontal)
        
        messageParent.pinToSuperview(edges: .horizontal)
        messageParent.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        messageParent.addSubview(messageInput)
        messageParent.layer.cornerRadius = 24
        
        messageInput.pinToSuperview(edges: .horizontal, padding: 10).pinToSuperview(edges: .vertical, padding: 4)
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
        profilePictureView.layer.cornerRadius = 60
        
        if let user = destination.user {
            profilePictureView.setUserImage(user)
            messageInput.placeholderText = "message for \(user.data.firstIdentifier)"
        } else {
            profilePictureView.image = UIImage(named: "Profile")
        }
        
        nipLabel.text = destination.address
        nipLabel.numberOfLines = 2
        nipLabel.textAlignment = .center
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            self?.send(sender: sendButton)
        }), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        updateTheme()
    }
    
    @objc func didTapView() {
        input.resignFirstResponder()
        messageInput.resignFirstResponder()
    }
    
    func send(sender: MyButton) {
        Task { @MainActor in
            
            let amount = input.balance
            
            if amount < 1 {
                input.becomeFirstResponder()
                return
            }
            
            sender.isEnabled = false
            
            let spinnerVC = WalletSpinnerViewController(sats: amount, address: destination.address)
            navigationController?.pushViewController(spinnerVC, animated: true)
            
            do {
                switch self.destination {
                case .user(let user):
                    try await WalletManager.instance.send(
                        user: user.data,
                        sats: amount,
                        note: messageInput.text ?? ""
                    )
                case let .address(address, invoice, user):
                    if address.hasPrefix("lnurl") {
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
                
                spinnerVC.present(WalletTransferSummaryController(.success(amount: amount, address: destination.address)), animated: true) {
                    self.navigationController?.popToViewController(self, animated: false)
                    self.navigationController?.viewControllers.remove(object: self)
                }
            } catch {
                let message = (error as? WalletError)?.message ?? error.localizedDescription
                spinnerVC.present(WalletTransferSummaryController(.failure(navTitle: "Payment Failed", title: "Unable to send", message: message)), animated: true) {
                    self.navigationController?.popToViewController(self, animated: false)
                }
            }
            
            sender.isEnabled = true
        }
    }
}

final class BitcoinInputParentView: UIStackView {
    private let amountDescLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ input: LargeBalanceConversionInputView, spacing: CGFloat = 12) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .center
        self.spacing = spacing
        
        addArrangedSubview(amountDescLabel)
        addArrangedSubview(input)
        
        amountDescLabel.font = .appFont(withSize: 16, weight: .regular)
        amountDescLabel.text = "amount"
        
//        input.$isBitcoinPrimary.sink { [weak self] isBitcoin in
//            self?.amountDescLabel.text = isBitcoin ? "amount: (sats)" : "amount: (USD)"
//        }
//        .store(in: &cancellables)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
