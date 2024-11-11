//
//  PremiumBuySubscriptionController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.11.24..
//

import Combine
import UIKit
import FLAnimatedImage
import StoreKit

class PremiumBuySubscriptionController: UIViewController {
    
    enum State {
        case onboardingFinish, extendSubscription, buySubscription
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    let loader = LoadingSpinnerView().constrainToSize(100)
    
    let pickedName: String
    let state: State
    init(pickedName: String, state: State) {
        self.pickedName = pickedName
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        view.addSubview(loader)
        loader.centerToSuperview()
        loader.isHidden = true
    }
}

private extension PremiumBuySubscriptionController {
    func setup() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        switch state {
        case .onboardingFinish:
            title = "Congrats!"
        case .extendSubscription:
            title = "Extend Subscription"
        case .buySubscription:
            title = "Buy Subscription"
        }
        
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
            table,
            actionStack, SpacerView(height: 28),
            yearlyButton, SpacerView(height: 16),
            monthlyButton, SpacerView(height: 24),
            TermsAndConditionsView()
        ])
        
        if state == .extendSubscription {
            mainStack.insertArrangedSubview(SpacerView(height: 16), at: 2)
            let label = UILabel("Your subscription will be extended by the number of months you buy.", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
            label.textAlignment = .center
            label.numberOfLines = 0
            mainStack.insertArrangedSubview(label, at: 2)
            mainStack.insertArrangedSubview(SpacerView(height: 16), at: 2)
        } else {
            mainStack.insertArrangedSubview(SpacerView(height: 30), at: 2)
        }
        
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
            if let monthly = products.first(where: { $0.id == InAppPurchaseManager.monthlyPremiumId }) {
                monthlyButton.priceLabel.text = monthly.displayPrice
                
                monthlyButton.addAction(.init(handler: { _ in
                    self?.purchaseSubscription(product: monthly)
                }), for: .touchUpInside)
            }
            if let yearly = products.first(where: { $0.id == InAppPurchaseManager.yearlyPremiumId }) {
                yearlyButton.priceLabel.text = yearly.displayPrice
                
                yearlyButton.addAction(.init(handler: { _ in
                    self?.purchaseSubscription(product: yearly)
                }), for: .touchUpInside)
            }
        }
    }
    
    func purchaseSubscription(product: StoreKit.Product) {
        RootViewController.instance.view.isUserInteractionEnabled = false
        loader.isHidden = false
        loader.play()
        
        InAppPurchaseManager.shared.purchase(product: product) { [weak self] result in
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    let jws = verification.jwsRepresentation
                    guard
                        let self,
                        let object = NostrObject.purchasePrimalPremium(pickedName: self.pickedName, transaction: transaction, verification: jws)
                    else { return }
                    
                    
                    
                    Connection.wallet.requestCache(name: "membership_purchase_product", payload: ["event_from_user": object.toJSON()]) { result in
                        DispatchQueue.main.async {
                            print("MEMBERSHIP_PURCHASE_PRODUCT RESPONSE\n" + (result.encodeToString() ?? ""))
                            
                            self.loader.isHidden = true
                            RootViewController.instance.view.isUserInteractionEnabled = true
                            
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
                case .unverified(_, let error):
                    self?.loader.isHidden = true
                    RootViewController.instance.view.isUserInteractionEnabled = true
                    RootViewController.instance.showErrorMessage(title: "The Primal Premium subscription purchase failed. Please try again.", error.localizedDescription)
                    print("Purchase error: \(error)")
                }
            case nil:
                self?.loader.isHidden = true
                RootViewController.instance.view.isUserInteractionEnabled = true
                RootViewController.instance.showErrorMessage(title: "The Primal Premium subscription purchase failed. Please try again.", "Check your apple pay settings")
            case .userCancelled:
                self?.loader.isHidden = true
                RootViewController.instance.view.isUserInteractionEnabled = true
            case .pending:
                self?.loader.isHidden = true
                RootViewController.instance.view.isUserInteractionEnabled = true
                RootViewController.instance.showErrorMessage(title: "Your Primal Premium subscription purchase is pending. Once it completes, the Premium features will be enabled.")
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
        
        let nameLabel = UILabel(pickedName, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
                
        let userStack = UIStackView(axis: .vertical, [image, SpacerView(height: 16), nameStack])
        userStack.alignment = .center
        
        if state == .onboardingFinish {
            userStack.setCustomSpacing(24, after: nameStack)
            userStack.addArrangedSubview(UILabel("Your Primal Name is available!", color: .init(rgb: 0x52CE0A), font: .appFont(withSize: 16, weight: .semibold)))
        }
        
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
