//
//  PremiumCompleteSignupController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.11.24..
//

import Combine
import UIKit
import FLAnimatedImage
import StoreKit

class PremiumCompleteSignupController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    let pickedName: String
    init(pickedName: String) {
        self.pickedName = pickedName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension PremiumCompleteSignupController {
    func setup() {
        navigationItem.leftBarButtonItem = customBackButton
        title = "Congrats!"
        view.backgroundColor = .background
        
        let table = PremiumSearchTableView()
        
        let contentStack = UIStackView(axis: .vertical, [])
        contentStack.distribution = .equalSpacing
        
        let yearlyButton = PurchasePremiumButton(title: "Get Annual Plan")
        let monthlyButton = PurchasePremiumButton(title: "Get Monthly Plan")
        
        let learnMoreButton = AccentUIButton(title: "Learn about Premium", font: .appFont(withSize: 14, weight: .regular))
        let promoCodeButton = AccentUIButton(title: "Have a promo code?", font: .appFont(withSize: 14, weight: .regular))
        let actionStack = UIStackView([learnMoreButton, SpacerView(width: 1, color: .foreground6), promoCodeButton])
        actionStack.constrainToSize(height: 20)
        learnMoreButton.widthAnchor.constraint(equalTo: promoCodeButton.widthAnchor).isActive = true
        
        let mainStack = UIStackView(axis: .vertical, [
            UIView(),
            table, SpacerView(height: 30),
            learnMoreButton, SpacerView(height: 28),
            yearlyButton, SpacerView(height: 16),
            monthlyButton, SpacerView(height: 24),
            TermsAndConditionsView()
        ])
        
        if let userStack = userStackView() {
            mainStack.insertArrangedSubview(userStack, at: 1)
            mainStack.setCustomSpacing(24, after: userStack)
        }
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 24)
            .pinToSuperview(edges: .vertical, padding: 24, safeArea: true)
        
        table.addressRow.infoLabel.text = pickedName + "@primal.net"
        table.lightningRow.infoLabel.text = table.addressRow.infoLabel.text
        table.profileRow.infoLabel.text = "primal.net/" + pickedName
        
        learnMoreButton.addAction(.init(handler: { [weak self] _ in
            self?.show(PremiumLearnMoreWhyController(), sender: nil)
        }), for: .touchUpInside)
        
        InAppPurchaseManager.shared.fetchPremiumSubscriptions { [weak self] products in
            if let monthly = products.first(where: { $0.productIdentifier == InAppPurchaseManager.monthlyPremiumId }) {
                monthlyButton.priceLabel.text = monthly.localizedPrice
                
                monthlyButton.addAction(.init(handler: { _ in
                    self?.purchaseSubscription(product: monthly)
                }), for: .touchUpInside)
            }
            if let yearly = products.first(where: { $0.productIdentifier == InAppPurchaseManager.yearlyPremiumId }) {
                yearlyButton.priceLabel.text = yearly.localizedPrice
                
                yearlyButton.addAction(.init(handler: { _ in
                    self?.purchaseSubscription(product: yearly)
                }), for: .touchUpInside)
            }
        }
    }
    
    func purchaseSubscription(product: SKProduct) {
        RootViewController.instance.view.isUserInteractionEnabled = false
        
        InAppPurchaseManager.shared.purchase(product: product) { [weak self] alertType, product, transaction in
            switch alertType {
            case .disabled, .failed:
                RootViewController.instance.view.isUserInteractionEnabled = true
            case .purchased:
                RootViewController.instance.view.isUserInteractionEnabled = true
                
                guard
                    let self, let transaction,
                    let object = NostrObject.purchasePrimalPremium(pickedName: self.pickedName, transaction: transaction)
                else { return }
                
                Connection.wallet.requestCache(name: "membership_purchase_product", payload: ["event_from_user": object.toJSON()]) { result in
                    DispatchQueue.main.async {
                        print("MEMBERSHIP_PURCHASE_PRODUCT RESPONSE\n" + (result.encodeToString() ?? ""))
                        
                        if let message = result.first?.stringValue {
                            self.showErrorMessage(message)
                            return
                        }
                        
                        WalletManager.instance.refreshPremiumState()
                        
                        self.present(WalletTransferSummaryController(.success(title: "Success, payment received!", description: "Your subscription is now active.")), animated: true) {
                            
                            guard let premium = self.navigationController?.viewControllers.first(where: { $0 as? PremiumViewController != nil }) as? PremiumViewController else {
                                self.navigationController?.popViewController(animated: false)
                                self.navigationController?.popViewController(animated: false)
                                return
                            }
                            
                            self.navigationController?.popToViewController(premium, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    func userStackView() -> UIView? {
        guard let user = IdentityManager.instance.parsedUser else { return nil }
        let image = FLAnimatedImageView().constrainToSize(80)
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.setUserImage(user, size: .init(width: 80, height: 80))
        
        let checkbox = VerifiedView().constrainToSize(24)
        checkbox.isExtraVerified = true
        
        let nameLabel = UILabel(user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
        
        let userStack = UIStackView(axis: .vertical, [
            image, SpacerView(height: 16),
            nameStack,  SpacerView(height: 24),
            UILabel("Your Primal Name is available!", color: .init(rgb: 0x52CE0A), font: .appFont(withSize: 16, weight: .semibold))
        ])
        userStack.alignment = .center
        
        return userStack
    }
}

class PurchasePremiumButton: MyButton {
    let titleLabel = UILabel("", color: .white, font: .appFont(withSize: 18, weight: .semibold))
    let priceLabel = UILabel("---", color: .white, font: .appFont(withSize: 18, weight: .semibold))
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.6 : 1
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        titleLabel.centerToSuperview(axis: .vertical).pinToSuperview(edges: .leading, padding: 28)
        titleLabel.text = title
        
        addSubview(priceLabel)
        priceLabel.centerToSuperview(axis: .vertical).pinToSuperview(edges: .trailing, padding: 28)
        
        constrainToSize(height: 58)
        layer.cornerRadius = 29
        backgroundColor = .accent
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
