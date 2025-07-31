//
//  WalletSendAmountController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.1.24..
//

import Combine
import FLAnimatedImage
import UIKit

final class WalletSendAmountController: UIViewController, Themeable, KeyboardInputConnector {
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
            case .address(let address, let invoice, let user):
                if address.isBitcoinAddress {
                    return "Onchain transaction"
                }
                return user?.data.lud16 ?? invoice?.lninvoice.description ?? "Lightning Invoice"
            }
        }
        
        var name: String? {
            user?.data.name ?? (address.isBitcoinAddress ? "Bitcoin Address" : nil)
        }
        
        var startingAmount: Int {
            switch self {
            case .user:                         
                return 0
            case .address(_, let parsed, _):
                return (parsed?.lninvoice.amount_msat ?? 0) / 1000
            }
        }
    }
    
    let destination: Destination
    
    let input = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let keyboard = NumberKeyboardView()
    let profilePictureView = UserImageView(height: 88)
    let nameLabel = UILabel()
    let nipLabel = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
    lazy var infoParent = UIStackView(axis: .vertical, [profilePictureView, SpacerView(height: 12), nipLabel, SpacerView(height: 2)])
    
    let cancelButton = SimpleRoundedButton(title: "Cancel")
    let sendButton = LargeRoundedButton(title: "Next")
    
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    let scrollView = UIScrollView()
    
    var cancellables = Set<AnyCancellable>()
    
    init(_ destination: Destination) {
        self.destination = destination
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        input.balance = destination.startingAmount
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
       
        hapticFeedbackGenerator.prepare()
    }
    
    var maxInputAmountUSD: Double { Double(WalletManager.instance.balance).satToUSD }
    
    var maxInputAmountSats: Int { WalletManager.instance.balance }
}

private extension WalletSendAmountController {
    func setup() {
        title = "Sending To"
        
        let sizingView = UIView()
        view.addSubview(sizingView)
        sizingView.pinToSuperview(edges: .top, safeArea: true)
        sizingView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        infoParent.alignment = .center
        
        let inputParent = UIView()
        let inputStack = UIStackView(axis: .vertical, [inputParent, SpacerView(height: 12)])
        
        let buttonStack = UIStackView([cancelButton, sendButton])
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 18
        
        let keyboardStack = UIStackView(axis: .vertical, [keyboard, SpacerView(height: 12), SpacerView(height: 30, priority: .defaultLow), buttonStack])
        
        let stack = UIStackView(axis: .vertical, [
            infoParent,
            inputStack,
            keyboardStack
        ])
        
        if let name = destination.name {
            nameLabel.text = name
            nameLabel.font = .appFont(withSize: 20, weight: .semibold)
            nameLabel.textColor = .foreground
            infoParent.insertArrangedSubview(nameLabel, at: 2)
        }
        
        view.addSubview(scrollView)
        scrollView.pinToSuperview(safeArea: true)
        
        scrollView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical, padding: 20)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -72).isActive = true
        let height = stack.heightAnchor.constraint(equalTo: sizingView.heightAnchor, constant: -50)
        height.priority = .init(500)
        height.isActive = true
        
        stack.distribution = .equalSpacing
        
        inputParent.addSubview(input)
        input.pinToSuperview()
        input.largeAmountLabel.centerToView(inputParent, axis: .horizontal)
        input.animateReversed = false
        input.isSettingFirstTime = false
        
        if let user = destination.user {
            profilePictureView.setUserImage(user)
            
            profilePictureView.addGestureRecognizer(BindableTapGestureRecognizer { [weak self] in
                self?.show(ProfileViewController(profile: user), sender: nil)
            })
        } else {
            profilePictureView.image = destination.address.isBitcoinAddress ? .onchainPayment : .nonZapPaymentDynamic
            profilePictureView.animatedImageView.clipsToBounds = false
        }
        
        nipLabel.text = destination.address
        nipLabel.font = .appFont(withSize: 16, weight: .regular)
        nipLabel.textAlignment = .center
        
        if destination.address.isBitcoinAddress {
            nipLabel.numberOfLines = 1
            nipLabel.lineBreakMode = .byTruncatingMiddle
        } else {
            nipLabel.numberOfLines = 2
        }
        
        keyboard.delegate = self
        
        input.$balance.map({ $0 > 0 }).assign(to: \.isEnabled, onWeak: sendButton).store(in: &cancellables)
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.viewControllers.removeAll(where: { $0 as? WalletSendParentViewController != nil })
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            switch destination {
            case .user(let user):
                navigationController?.pushViewController(WalletSendViewController(.user(user, startingAmount: input.balance)), animated: true)
            case let .address(address, invoice, user):
                if address.isBitcoinAddress, input.balance < 21000 {
                    showErrorMessage("Amount too small for an on-chain transaction")
                    return
                }
                navigationController?.pushViewController(WalletSendViewController(.address(address, invoice, user, startingAmount: input.balance)), animated: true)
            }
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
}

protocol KeyboardInputConnector: NumberKeyboardViewDelegate {
    var input: LargeBalanceConversionView { get }
    var hapticFeedbackGenerator: UIImpactFeedbackGenerator { get }
    var maxInputAmountSats: Int { get }
    var maxInputAmountUSD: Double { get }
}

extension KeyboardInputConnector {
    var groupingSeparator: String {
        Locale.current.groupingSeparator ?? ","
    }
    
    var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    func triggerHapticFeedback() {
        hapticFeedbackGenerator.impactOccurred()
        hapticFeedbackGenerator.prepare()
    }
    
    func numberKeyboardNumberPressed(_ number: Int) {
        if input.isBitcoinPrimary {
            if input.balance > maxInputAmountSats / 10 {
                RootViewController.instance.view.showToast("Over maximum amount", extraPadding: 0)
                return
            }
            
            input.balance = input.balance * 10 + number
            triggerHapticFeedback()
            return
        }
        
        var text = input.largeAmountLabel.text ?? ""
        text = text.replacingOccurrences(of: groupingSeparator, with: "").replacingOccurrences(of: decimalSeparator, with: ".")
        
        text = text + "\(number)"
        
        if text.dropLast(3).last == "." { return } // Only up to two digits after .
        
        if number == 0, text.contains(".") { // Manual override so 0 doesn't get eaten up with localisation
            input.setLargeLabel(text, complexAnimation: true)
            triggerHapticFeedback()
            return
        }
        
        guard let doubleAmount = Double(text), doubleAmount <= maxInputAmountUSD else {
            RootViewController.instance.view.showToast("Over maximum amount", extraPadding: 0)
            return
        }
        
        input.balance = Int(doubleAmount.usdToSAT)
        triggerHapticFeedback()
    }
    
    func numberKeyboardDotPressed() {
        if input.isBitcoinPrimary || input.largeAmountLabel.text?.contains(decimalSeparator) == true { return }
        
        let newAmountString = (input.largeAmountLabel.text ?? "") + decimalSeparator
        input.setLargeLabel(newAmountString, complexAnimation: true)
        triggerHapticFeedback()
    }
    
    func numberKeyboardDeletePressed() {
        triggerHapticFeedback()
        
        if input.isBitcoinPrimary {
            input.balance = input.balance / 10
            return
        }
        
        let newAmountString = String((input.largeAmountLabel.text ?? "").dropLast())
        let calculationString = newAmountString.replacingOccurrences(of: groupingSeparator, with: "").replacingOccurrences(of: decimalSeparator, with: ".")

        guard newAmountString.last != decimalSeparator.last, newAmountString.hasSuffix("\(decimalSeparator)0") == false, let doubleAmount = Double(calculationString), doubleAmount <= maxInputAmountUSD else {
            if newAmountString.isEmpty {
                input.balance = 0
                return
            }
            input.setLargeLabel(newAmountString, complexAnimation: true)
            return
        }
        
        input.balance = Int(doubleAmount.usdToSAT)
    }
}
