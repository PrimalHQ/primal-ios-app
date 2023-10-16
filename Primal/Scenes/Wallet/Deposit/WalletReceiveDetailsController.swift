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
    let textInput = UITextField()
    
    private var cancellables: Set<AnyCancellable> = []
    
    weak var delegate: WalletReceiveDetailsControllerDelegate?
    init(details: AdditionalDepositInfo, delegate: WalletReceiveDetailsControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        
        input.balance = details.satoshi
        textInput.text = details.description
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = backButtonWithColor(.foreground)
        
        view.backgroundColor = .background
        
        textInput.textColor = .foreground
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
        
        textInput.font = .appFont(withSize: 16, weight: .regular)
        
        let mainStack = UIStackView(axis: .vertical, [
            BitcoinInputParentView(input, spacing: 0), SpacerView(height: 36),
            descLabel("message:"), SpacerView(height: 10),
            textParent,
            UIView()
        ])
        
        textParent.pinToSuperview(edges: .horizontal)
        mainStack.alignment = .center
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .top, padding: 30, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        textInput.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.detailsChanged(.init(satoshi: self?.input.balance ?? 0, description: self?.textInput.text ?? ""))
        }), for: .editingChanged)
        
        input.$balance.dropFirst().sink { [weak self] balance in
            self?.delegate?.detailsChanged(.init(satoshi: balance, description: self?.textInput.text ?? ""))
        }
        .store(in: &cancellables)
    }
    
    func descLabel(_ text: String) -> UILabel {
        let descLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        descLabel.font = .appFont(withSize: 18, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.text = text
        return descLabel
    }
}
