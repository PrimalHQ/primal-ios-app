//
//  WalletInAppPurchaseController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import UIKit

class WalletInAppPurchaseController: UIViewController, Themeable {
    private let satsLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
    
    private let stack = UIStackView(axis: .vertical, [])
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        view.backgroundColor = .background

    }
}

private extension WalletInAppPurchaseController {
    func setup() {
        updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        title = "Buy Sats"
        
        let satsCurrencyLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let satsStack = UIStackView([satsLabel, satsCurrencyLabel])
        satsStack.spacing = 8
        satsStack.alignment = .bottom
        
        let satsParentStack = UIStackView(axis: .vertical, [satsStack])
        satsParentStack.alignment = .center
        
        let forLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        
        let action = GradientButton(title: "Purchase Now", font: .appFont(withSize: 18, weight: .medium)).constrainToSize(height: 58)
        
        let itemStack = UIStackView(axis: .vertical, [])
        itemStack.alignment = .center
        
        [
            satsParentStack, SpacerView(height: 56),
            forLabel, SpacerView(height: 56),
            itemStack,
            UIView(),
            action
        ].forEach { stack.addArrangedSubview($0) }
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .bottom, padding: 56 + 32, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 32)
            .pinToSuperview(edges: .top, padding: 89, safeArea: true)
        
        satsLabel.text = "12,150"
        satsCurrencyLabel.text = "sats"
        forLabel.text = "for"
        
        satsLabel.font = .appFont(withSize: 48, weight: .bold)
        satsCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        forLabel.font = .appFont(withSize: 16, weight: .medium)
        
        forLabel.textAlignment = .center
                
        InAppPurchaseManager.shared.fetchAvailableProducts { [weak self] products in
            products.forEach { product in
                // TODO: NIKOLA
                // TODO: make sure this is displaying correctly
                let button = InAppPurchaseButton(value: product.price, currency: product.priceLocale.currencySymbol ?? "$")
                
                button.addAction(.init(handler: { _ in
                    InAppPurchaseManager.shared.purchase(product: product) { type, _, _ in
                        switch type {
                        case .disabled:
                            self?.showErrorMessage(type.message)
                        case .purchased:
                            // TODO: NIKOLA
                            // TODO: Make a request to the web-server to let them know about the purchase
//                            PrimalWalletRequest(type: /*NEW TYPE*/).publisher()
                            
                            break
                        case .failed:
                            self?.showErrorMessage(type.message)
                        }
                    }
                }), for: .touchUpInside)
                
                itemStack.addArrangedSubview(button)
            }
        }
    }
}

final class InAppPurchaseButton: MyButton {
    private let currencyLabel = UILabel()
    private let amountLabel = UILabel()
    
    init(value: NSDecimalNumber, currency: String) {
        super.init(frame: .zero)
        
        let hStack = UIStackView([currencyLabel, amountLabel])
        hStack.alignment = .top
        
        addSubview(hStack)
        hStack.centerToSuperview()
        
        currencyLabel.text = currency
        amountLabel.text = NumberFormatter().string(from: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
