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
    let user: ParsedUser
    
    let input = LargeBalanceConversionInputView()
    let messageInput = PlaceholderTextView()
    
    let scrollView = UIScrollView()
    
    var cancellables = Set<AnyCancellable>()
    
    init(user: ParsedUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        setup()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        input.becomeFirstResponder()
    }
}

private extension WalletSendViewController {
    func setup() {
        title = "Payment Details"
        
        let sizingView = UIView()
        view.addSubview(sizingView)
        sizingView.pinToSuperview(edges: .top, safeArea: true)
        sizingView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        let profilePictureView = FLAnimatedImageView().constrainToSize(120)
        let nipLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        
        let messageParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        
        let sendButton = LargeGradientIconButton(title: "Send", icon: UIImage(named: "feedZapFilled")?.withTintColor(.white)).constrainToSize(height: 56)
        
        let stack = UIStackView(axis: .vertical, [
            profilePictureView, SpacerView(height: 12),
            nipLabel, SpacerView(height: 32),
            input, SpacerView(height: 32),
            messageParent, SpacerView(height: 44), UIView(),
            sendButton
        ])
        
        sendButton.pinToSuperview(edges: .horizontal)
        
        messageParent.pinToSuperview(edges: .horizontal).constrainToSize(height: 120)
        messageParent.addSubview(messageInput)
        messageParent.layer.cornerRadius = 8
        
        messageInput.pinToSuperview(edges: .horizontal, padding: 10).pinToSuperview(edges: .vertical, padding: 8)
        messageInput.font = .appFont(withSize: 16, weight: .regular)
        messageInput.backgroundColor = .clear
        messageInput.placeholderText = "message for \(user.data.firstIdentifier)"
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
        let bot = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56)
        bot.priority = .defaultHigh
        bot.isActive = true
        
        scrollView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical, padding: 20)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -72).isActive = true
        
        stack.heightAnchor.constraint(greaterThanOrEqualTo: sizingView.heightAnchor, constant: -96).isActive = true
        
        stack.alignment = .center
        
        profilePictureView.contentMode = .scaleAspectFill
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.cornerRadius = 60
        profilePictureView.setUserImage(user)
        
        nipLabel.text = user.data.lud16
        
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
            
            let spinnerVC = WalletSpinnerViewController(sats: amount, address: user.data.lud16)
            self.navigationController?.pushViewController(spinnerVC, animated: true)
            
            do {
                try await WalletManager.instance.send(
                    user: user.data,
                    sats: amount,
                    note: messageInput.text ?? ""
                )
                
                spinnerVC.present(WalletTransferSummaryController(.success(amount: amount, address: self.user.data.lud16)), animated: true) {
                    self.navigationController?.popToViewController(self, animated: false)
                    self.navigationController?.viewControllers.remove(object: self)
                }
            } catch {
                spinnerVC.present(WalletTransferSummaryController(.failure(error)), animated: true) {
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
