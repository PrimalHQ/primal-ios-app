//
//  PremiumPrimalOGHomeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.12.24..
//



import UIKit
import StoreKit

final class PremiumPrimalOGHomeController: UIViewController, Themeable {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        updateTheme()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension PremiumPrimalOGHomeController {
    func setup() {
        title = "Primal OG"
        
        let descStack = UIStackView(axis: .vertical, [
            UILabel("The Primal OG tier was created to recognize",color: .foreground, font: .appFont(withSize: 15, weight: .regular)),
            UILabel("those users who signed up to Primal",color: .foreground, font: .appFont(withSize: 15, weight: .regular)),
            UILabel("Premium in the first year.",color: .foreground, font: .appFont(withSize: 15, weight: .regular))
        ])
        descStack.alignment = .center
        descStack.spacing = 6
        
        let introLabel = ThemeableLabel("Subscribe to Primal Premium to get:", textColor: { .foreground3 }, font: .appFont(withSize: 16, weight: .regular))
        
        let learnView = LearnAboutPremiumView()
        
        let princeInfoView = PremiumPriceInfoView()
        
        let secondLabel = ThemeableLabel("Start by reserving your Primal Name:", textColor: { .foreground3 }, font: .appFont(withSize: 16, weight: .regular))
        
        let action = LargeRoundedButton(title: "Find Primal Name")
        
        let midStack = UIStackView(axis: .vertical, [
            introLabel, SpacerView(height: 20),
            learnView, SpacerView(height: 40),
            princeInfoView
        ])
        midStack.alignment = .center
        
        let botStack = UIStackView(axis: .vertical, [
            secondLabel, SpacerView(height: 16),
            action
        ])
        
        let mainStack = UIStackView(axis: .vertical, [
            descStack,
            midStack,
            botStack
        ])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .top, padding: 16, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        midStack.alignment = .center
        botStack.alignment = .center
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        learnView.pin(to: mainStack, edges: .horizontal)
        action.pin(to: mainStack, edges: .horizontal)
        
        learnView.learnMoreButton.addAction(.init(handler: { [weak self] _ in
            self?.show(PremiumLearnMoreController(), sender: nil)
        }), for: .touchUpInside)
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let nav = self?.navigationController else { return }
            nav.pushViewController(PremiumSearchNameController(title: "Find Primal Name", callback: { name in
                nav.pushViewController(PremiumBuySubscriptionController(pickedName: name, state: .onboardingFinish), animated: true)
            }), animated: true)
        }), for: .touchUpInside)
        
        InAppPurchaseManager.shared.fetchPremiumSubscriptions { products in
            if let monthly = products.first(where: { $0.id == InAppPurchaseManager.monthlyPremiumId }) {
                princeInfoView.monthlyPriceLabel.text = monthly.displayPrice
            }
            if let yearly = products.first(where: { $0.id == InAppPurchaseManager.yearlyPremiumId }) {
                princeInfoView.yearlyPriceLabel.text = yearly.displayPrice
            }
        }
    }
}
