//
//  RestoreWalletController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 2. 2026..
//

import Combine
import UIKit
import PrimalShared

extension UIButton.Configuration {
    static func disabledPill(_ text: String, font: UIFont = .appFont(withSize: 18, weight: .semibold)) -> UIButton.Configuration {
        .pill(text: text, foregroundColor: .foreground5, backgroundColor: .background3, font: font)
    }
}

class RestoreWalletController: UIViewController {
    
    let inputField = PlaceholderTextView()
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Restore Existing Wallet"
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        let restoreButton = UIButton(configuration: .disabledPill("Restore Wallet Now")).constrainToSize(height: 56)
        let keyboardSpacer = KeyboardSizingView()
        let botStack = UIStackView(axis: .vertical, spacing: 24, [restoreButton, keyboardSpacer])
        
        let inputFieldParent = UIView()
        inputFieldParent.addSubview(inputField)
        inputField.pinToSuperview(edges: .vertical, padding: 4).pinToSuperview(edges: .horizontal, padding: 10)
        
        let messageLabel = UILabel("Invalid recovery phrase", color: .failureRed, font: .appFont(withSize: 13, weight: .regular), multiline: true)
        messageLabel.isHidden = true
        let inputStack = UIStackView(axis: .vertical, spacing: 8, [inputFieldParent, messageLabel])
        inputStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let mainStack = UIStackView(axis: .vertical, [
            inputStack,
            UILabel("We support recovery of any existing bitcoin wallet on the Spark network. Recovery phrases are 12 to 24 words long. ", color: .foreground3, font: .appFont(withSize: 16, weight: .regular), multiline: true),
            botStack
        ])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top, padding: 20, safeArea: true)
            .pinToSuperview(edges: .bottom)
        
        mainStack.distribution = .equalSpacing
        
        let inputHeightConstraint = inputField.heightAnchor.constraint(equalToConstant: 168)
        inputHeightConstraint.priority = .defaultLow
        inputHeightConstraint.isActive = true
        
        keyboardSpacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        keyboardSpacer.updateHeightCancellable().store(in: &cancellables)
        
        inputFieldParent.backgroundColor = .background4
        inputField.backgroundColor = .background4
        inputFieldParent.layer.cornerRadius = 12
        inputFieldParent.layer.borderWidth = 1
        inputFieldParent.layer.borderColor = UIColor.foreground6.cgColor
        
        inputField.placeholderTextColor = .foreground4
        inputField.placeholderText = "Enter your wallet recovery phrase"
        inputField.font = .appFont(withSize: 15, weight: .semibold)
        inputField.textColor = .foreground
        inputField.autocapitalizationType = .none
        inputField.keyboardType = .alphabet
        let validator = RecoveryPhraseValidator()
        
        inputField.didChange = { field in
            let phrase = (field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            restoreButton.configuration = validator.isValid(phrase: phrase) ?
                .accentPill(text: "Restore Wallet Now", font: .appFont(withSize: 18, weight: .semibold)) :
                .disabledPill("Restore Wallet Now")
            
            messageLabel.isHidden = true
            inputFieldParent.layer.borderColor = UIColor.foreground6.cgColor
        }
        
        restoreButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let phrase = (inputField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard validator.isValid(phrase: phrase) else {
                messageLabel.isHidden = false
                inputFieldParent.layer.borderColor = UIColor.failureRed.cgColor
                inputFieldParent.shake()
                return
            }
            
            WalletManager.instance.restoreWalletFromSeed(phrase)
            navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputField.becomeFirstResponder()
    }
}
