//
//  WalletInAppPurchaseController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import UIKit
import Combine
import StoreKit

class WalletInAppPurchaseController: UIViewController, Themeable {
    private let satsLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
    private let stack = UIStackView(axis: .vertical, [])
    private var cancellables: Set<AnyCancellable> = []
    
    var product: SKProduct?
    var quote: WalletQuote?
  
    var countryCode = "USA"
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func updateTheme() {
        view.backgroundColor = .background4
    }
}

private extension WalletInAppPurchaseController {
    func label(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .foreground4
        label.font = .appFont(withSize: 16, weight: .semibold)
        return label
    }
    
    func containerView(_ view: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .background3
        container.layer.cornerRadius = 24
        container.constrainToSize(height: 48).addSubview(view)
        view.centerToSuperview()
        
        let containerParent = UIView()
        containerParent.addSubview(container)
        container.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 36)
        return containerParent
    }
    
    func setup() {
        updateTheme()
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.custom(resolver: { context in
                400
            })]
        }
                
        let satsCurrencyLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let satsStack = UIStackView([satsLabel, satsCurrencyLabel])
        satsStack.spacing = 8
        satsStack.alignment = .bottom
        
        let fiatLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        let fiatSymbolLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let fiatCurrencyLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let fiatStack = UIStackView([fiatSymbolLabel, fiatLabel, fiatCurrencyLabel])
        fiatStack.spacing = 8
        fiatStack.alignment = .bottom
        
        let action = LargeRoundedButton(title: "Purchase Now")
        
        [
            PullBarView(), SpacerView(height: 40),
            label("PAY"), SpacerView(height: 8),
            containerView(fiatStack), SpacerView(height: 49),
            label("TO RECIEVE"), SpacerView(height: 8),
            containerView(satsStack),
            UIView(),
            action
        ].forEach { stack.addArrangedSubview($0) }
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .bottom, padding: 32, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .top, padding: 18, safeArea: true)
        
        let fiatLoading = LoadingSpinnerView().constrainToSize(50)
        view.addSubview(fiatLoading)
        fiatLoading.centerToView(fiatStack)
        
        let satsLoading = LoadingSpinnerView().constrainToSize(50)
        view.addSubview(satsLoading)
        satsLoading.centerToView(satsStack)
        
        satsCurrencyLabel.text = "sats"
        
        fiatLabel.font = .appFont(withSize: 32, weight: .bold)
        satsLabel.font = .appFont(withSize: 32, weight: .bold)
        fiatCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        satsCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        fiatCurrencyLabel.transform = .init(translationX: 0, y: -5)
        satsCurrencyLabel.transform = .init(translationX: 0, y: -5)
        
        fiatSymbolLabel.font = .appFont(withSize: 16, weight: .medium)
        fiatSymbolLabel.transform = .init(translationX: 0, y: -15)
        
        satsStack.isHidden = true
        fiatStack.isHidden = true
        
        satsLoading.play()
        fiatLoading.play()
        
        let mainLoadingParent = UIView()
        let smallLoading = LoadingSpinnerView()
        mainLoadingParent.addSubview(smallLoading)
        smallLoading.centerToSuperview().constrainToSize(70)
        mainLoadingParent.backgroundColor = .background.withAlphaComponent(0.5)
        
        view.addSubview(mainLoadingParent)
        mainLoadingParent.pinToSuperview()
        mainLoadingParent.isHidden = true
        
        if let storefront = SKPaymentQueue.default().storefront {
            countryCode = storefront.countryCode
        }
        
        InAppPurchaseManager.shared.fetchAvailableProducts { [weak self] products in
            products.forEach { product in
                guard let self = self else { return }
                self.product = product
                fiatSymbolLabel.text = product.priceLocale.currencySymbol
                fiatCurrencyLabel.text = product.priceLocale.currency?.identifier
                fiatLabel.text = product.price.stringValue
                fiatStack.isHidden = false
                fiatLoading.isHidden = true
                fiatLoading.stop()
                
                PrimalWalletRequest(type: .quote(productId: product.productIdentifier, countryCode: self.countryCode)).publisher()
                    .receive(on: DispatchQueue.main).sink { [weak self] result in
                        guard let quote = result.quote else { return }
                        
                        satsStack.isHidden = false
                        satsLoading.isHidden = true
                        satsLoading.stop()
                        
                        self?.quote = quote
                        let amount = Double(quote.amount_btc) ?? 0
                        self?.satsLabel.text = Int(amount * .BTC_TO_SAT).localized()
                    }.store(in: &self.cancellables)
                return
            }
        }
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let product = self?.product, let quote = self?.quote else { return }
            
            self?.view.isUserInteractionEnabled = true
            self?.isModalInPresentation = true
            mainLoadingParent.isHidden = false
            smallLoading.play()
            
            InAppPurchaseManager.shared.purchase(product: product) { type, product, transaction in
                switch type {
                case .disabled, .failed:
                    self?.view.isUserInteractionEnabled = false
                    self?.isModalInPresentation = false
                    mainLoadingParent.isHidden = true
                    smallLoading.stop()
                case .purchased:
                    guard
                        let transaction,
                        let transactionId = transaction.transactionIdentifier
                    else { break }

                    PrimalWalletRequest(type: .inAppPurchase(transactionId: transactionId, quote: quote.quote_id))
                        .publisher()
                        .receive(on: DispatchQueue.main)
                        .sink { result in
                            self?.view.isUserInteractionEnabled = false
                            self?.isModalInPresentation = false
                            mainLoadingParent.isHidden = true
                            smallLoading.stop()
                            
                            if let message = result.message {
                                self?.present(WalletTransferSummaryController(.failure(navTitle: "Payment Failed", title: "Unable to send", message: "We were not able to send sats to your wallet. Please contact us at support@primal.net and we will assist you.")), animated: true)
                            } else {
                                self?.dismiss(animated: true)
                            }
                        }.store(in: &self!.cancellables)
                }
            }
        }), for: .touchUpInside)
    }
}

final class PullBarView: UIView {
    init() {
        super.init(frame: .zero)
        let pullBar = UIView()
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        addSubview(pullBar)
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal).constrainToSize(width: 60, height: 5)
        pullBar.layer.cornerRadius = 2.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
