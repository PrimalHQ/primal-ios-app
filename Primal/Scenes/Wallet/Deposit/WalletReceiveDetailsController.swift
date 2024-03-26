//
//  WalletReceiveDetailsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.10.23..
//

import Combine
import UIKit

protocol WalletReceiveDetailsControllerDelegate: AnyObject {
    func detailsChanged(_ details: AdditionalDepositInfo)
}

final class WalletReceiveDetailsController: UIViewController, Themeable, KeyboardInputConnector {
    let input = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let textInput = PlaceholderTextView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    weak var delegate: WalletReceiveDetailsControllerDelegate?
    init(details: AdditionalDepositInfo, delegate: WalletReceiveDetailsControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        
        setup()
        
        input.balance = details.satoshi
        if !details.description.isEmpty {
            textInput.text = details.description
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        view.backgroundColor = .background
        
        textInput.mainTextColor = .foreground
        textInput.placeholderTextColor = .foreground.withAlphaComponent(0.6)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        input.becomeFirstResponder()
    }
    
    var maxInputAmountSats: Int { 999999999 }
    var maxInputAmountUSD: Double { 99999 }
}


private extension WalletReceiveDetailsController {
    func setup() {
        updateTheme()
        title = "Receive Details"
        
        let textParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        textParent.layer.cornerRadius = 24
        textParent.addSubview(textInput)
        textInput
            .pinToSuperview(edges: .horizontal, padding: 10)
            .pinToSuperview(edges: .top, padding: 5.5)
            .pinToSuperview(edges: .bottom, padding: 4)
        textParent.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        
        textInput.textAlignment = .center
        textInput.placeholderText = "add comment"
        textInput.font = .appFont(withSize: 16, weight: .regular)
        textInput.backgroundColor = .clear
        textParent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapInput)))
        
        let applyButton = WalletActionButton(text: "APPLY") { [weak self] in
            guard let self else { return }
            
            self.delegate?.detailsChanged(.init(satoshi: self.input.balance, description: self.textInput.text))
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelButton = WalletActionButton(text: "CANCEL") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        applyButton.backgroundColor = .accent
        applyButton.setTitleColor(.white, for: .normal)
        
        let actionStack = UIStackView([cancelButton, applyButton])
        actionStack.spacing = 16
        actionStack.distribution = .fillEqually
        
        let keyboardView = NumberKeyboardView()
        keyboardView.delegate = self
        
        let botStack = UIStackView(axis: .vertical, [keyboardView, SpacerView(height: 44), actionStack])
        
        let mainStack = UIStackView(axis: .vertical, [
            input,
            textParent,
            botStack
        ])
        
        actionStack.pinToSuperview(edges: .horizontal)
        textParent.pinToSuperview(edges: .horizontal)
        mainStack.distribution = .equalSpacing
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .top, padding: 30, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        input.largeAmountLabel.centerToView(view, axis: .horizontal)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    func descLabel(_ text: String) -> UILabel {
        let descLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        descLabel.font = .appFont(withSize: 18, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.text = text
        return descLabel
    }
    
    @objc func didTapInput() {
        textInput.becomeFirstResponder()
    }
    
    @objc func didTapView() {
        textInput.resignFirstResponder()
    }
}
