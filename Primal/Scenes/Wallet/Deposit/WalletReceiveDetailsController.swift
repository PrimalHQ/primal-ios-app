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

final class WalletReceiveDetailsController: UIViewController, Themeable {
    
    let input = LargeBalanceConversionInputView()
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
        
        textInput.backgroundColor = .background3
        textInput.mainTextColor = .foreground
        textInput.placeholderTextColor = .foreground.withAlphaComponent(0.6)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        input.becomeFirstResponder()
    }
}

private extension WalletReceiveDetailsController {
    func setup() {
        updateTheme()
        title = "Receive Details"
        
        let textParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        textParent.layer.cornerRadius = 8
        textParent.addSubview(textInput)
        textInput.pinToSuperview(padding: 10)
        textParent.constrainToSize(height: 120)
        
        textInput.placeholderText = "add comment"
        textInput.font = .appFont(withSize: 16, weight: .regular)
        textParent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapInput)))
        
        let applyButton = WalletActionButton(text: "APPLY") { [weak self] in
            guard let self else { return }
            
            self.delegate?.detailsChanged(.init(satoshi: self.input.balance, description: self.textInput.text))
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelButton = WalletActionButton(text: "CANCEL") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let actionStack = UIStackView([applyButton, cancelButton])
        actionStack.spacing = 18
        actionStack.distribution = .fillEqually
        
        let mainStack = UIStackView(axis: .vertical, [
            BitcoinInputParentView(input, spacing: 0), SpacerView(height: 52),
            textParent, SpacerView(height: 36),
            actionStack,
            UIView()
        ])
        
        actionStack.pinToSuperview(edges: .horizontal).constrainToSize(height: 60)
        textParent.pinToSuperview(edges: .horizontal)
        mainStack.alignment = .center
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .top, padding: 30, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
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
        input.resignFirstResponder()
        textInput.resignFirstResponder()
    }
}
