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
    let messageInput = UITextView()
    
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
        navigationItem.leftBarButtonItem = backButtonWithColor(.foreground)
        
        view.backgroundColor = .background
    }
}

extension WalletSendViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.scrollView.scrollRectToVisible(textView.convert(textView.frame, to: self.scrollView), animated: true)
        }
    }
}

private extension WalletSendViewController {
    func setup() {
        title = "Payment Details"
        
        let profilePictureView = FLAnimatedImageView().constrainToSize(120)
        let sendToLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let nipLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        
        let messageDescLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let messageParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        
        let sendButton = LargeGradientIconButton(title: "Send", icon: UIImage(named: "feedZapFilled")?.withTintColor(.white))
        
        let stack = UIStackView(axis: .vertical, [
            profilePictureView, SpacerView(height: 16),
            sendToLabel, SpacerView(height: 8), nipLabel, SpacerView(height: 32),
            BitcoinInputParentView(input), SpacerView(height: 64),
            messageDescLabel, SpacerView(height: 10),
            messageParent, SpacerView(height: 44),
            sendButton
        ])
        
        sendButton.pinToSuperview(edges: .horizontal)
        
        messageParent.pinToSuperview(edges: .horizontal).constrainToSize(height: 120)
        messageParent.addSubview(messageInput)
        messageParent.layer.cornerRadius = 8
        
        messageInput.pinToSuperview(edges: .horizontal, padding: 10).pinToSuperview(edges: .vertical, padding: 8)
        messageInput.font = .appFont(withSize: 16, weight: .regular)
        messageInput.textColor = .foreground
        messageInput.backgroundColor = .clear
        messageInput.delegate = self
        
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
        
        stack.alignment = .center
        
        profilePictureView.contentMode = .scaleAspectFill
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.cornerRadius = 60
        profilePictureView.setUserImage(user)
        
        messageDescLabel.font = .appFont(withSize: 16, weight: .regular)
        
        sendToLabel.text = "sending to:"
        messageDescLabel.text = "message for \(user.data.firstIdentifier):"
        nipLabel.text = user.data.lud16
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            self?.send()
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    func send() {
        Task { @MainActor in
            do {
                let amount = input.balance
                try await WalletManager.instance.send(
                    user: user.data,
                    amount: amount.satsToBitcoinString(),
                    note: messageInput.text ?? ""
                )
                
                self.present(WalletTransferSummaryController(.success(amount: amount, address: user.data.lud16)), animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.navigationController?.viewControllers.remove(object: self)
                }
            } catch {
                self.present(WalletTransferSummaryController(.failure(error)), animated: true)
            }
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
        
        input.$isBitcoinPrimary.sink { [weak self] isBitcoin in
            self?.amountDescLabel.text = isBitcoin ? "amount: (sats)" : "amount: (USD)"
        }
        .store(in: &cancellables)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
