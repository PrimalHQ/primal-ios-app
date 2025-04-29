//
//  PremiumOnboardingHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.11.24..
//

import UIKit
import StoreKit

extension UIButton.Configuration {
    static func bigCancel() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init("Cancel", attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .regular)
        ]))
        config.baseForegroundColor = .foreground
        return config
    }
}

extension SKProduct {
    var localizedPrice: String {
        var string = price.doubleValue.localized()
        if let symbol = priceLocale.currencySymbol {
            string = symbol + string
        } else if let name = priceLocale.currency?.identifier {
            string = "\(string) \(name)"
        }
        
        return string
    }
}

final class PremiumOnboardingHomeViewController: UIViewController, Themeable {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        updateTheme()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
    }
}

private extension PremiumOnboardingHomeViewController {
    func setup() {
        let topStack = UIStackView([
            ThemeableImageView().constrainToSize(45).setTheme { $0.image = Theme.current.logoIcon },
            ThemeableImageView(image: UIImage(named: "primalPremium")).setTheme { $0.tintColor = .foreground }
        ])
        topStack.alignment = .center
        topStack.spacing = 14
        
        let introLabel = ThemeableLabel("Subscribe to Primal Premium to get:", textColor: { .foreground3 }, font: .appFont(withSize: 16, weight: .regular))
        
        let learnView = LearnAboutPremiumView()
        
        let princeInfoView = PremiumPriceInfoView()
        let termsAndConditions = TermsAndConditionsView()
        
        let secondLabel = ThemeableLabel("Start by reserving your Primal Name:", textColor: { .foreground3 }, font: .appFont(withSize: 16, weight: .regular))
        
        let action = LargeRoundedButton(title: "Find Primal Name")
        let cancel = ThemeableButton().setTheme { $0.configuration = .bigCancel() }
        
        let midStack = UIStackView(axis: .vertical, [
            introLabel, SpacerView(height: 20, priority: .defaultLow),
            learnView, SpacerView(height: 40, priority: .defaultLow),
            princeInfoView
        ])
        midStack.alignment = .center
        
        let botStack = UIStackView(axis: .vertical, [
            secondLabel, SpacerView(height: 16, priority: .defaultLow),
            action, SpacerView(height: 20, priority: .defaultLow),
            termsAndConditions
        ])
        
        let mainStack = UIStackView(axis: .vertical, [
            topStack,
            midStack,
            botStack
        ])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .top, safeArea: true)
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
        
        cancel.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
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

class PremiumPriceInfoView: UIStackView {
    lazy var monthlyPriceLabel = priceLabel()
    lazy var yearlyPriceLabel = priceLabel()
    
    init() {
        super.init(frame: .zero)
        
        let leftSideParent = UIView().constrainToSize(height: 38)
        let monthlyLabel = infoLabel("monthly")
        
        leftSideParent.addSubview(monthlyLabel)
        monthlyLabel.pinToSuperview(edges: [.horizontal, .bottom])
        leftSideParent.addSubview(monthlyPriceLabel)
        monthlyPriceLabel.pinToSuperview(edges: .top).centerToSuperview(axis: .horizontal)
        
        let rightSideParent = UIView().constrainToSize(height: 38)
        let yearlyLabel = infoLabel("annually")
        
        rightSideParent.addSubview(yearlyLabel)
        yearlyLabel.pinToSuperview(edges: [.horizontal, .bottom])
        rightSideParent.addSubview(yearlyPriceLabel)
        yearlyPriceLabel.pinToSuperview(edges: .top).centerToSuperview(axis: .horizontal)
        yearlyPriceLabel.transform = .init(translationX: -1, y: 0)
        
        let or = ThemeableView().constrainToSize(24).setTheme { $0.backgroundColor = .foreground4 }
        or.layer.cornerRadius = 12
        let orLabel = ThemeableLabel("or", textColor: { .background }, font: .appFont(withSize: 15, weight: .bold))
        or.addSubview(orLabel)
        orLabel.centerToSuperview()
                
        addArrangedSubview(leftSideParent)
        addArrangedSubview(or)
        addArrangedSubview(rightSideParent)
        
        orLabel.transform = .init(translationX: 0, y: -2)
        
        spacing = 28
        alignment = .center
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        
    }
    
    private func priceLabel() -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground }
        label.font = .appFont(withSize: 20, weight: .bold)
        label.text = "---"
        return label
    }

    private func infoLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        return label
    }
}

class LearnAboutPremiumView: UIView, Themeable {
    let learnMoreButton = ThemeableButton().constrainToSize(height: 44).setTheme {
        $0.backgroundColor = .background3
        $0.setTitleColor(.accent2, for: .normal)
        $0.setTitleColor(.accent2.withAlphaComponent(0.6), for: .highlighted)
    }
    
    init() {
        super.init(frame: .zero)
        let rightStack = UIStackView(axis: .vertical, [
            LearnAboutPremiumChecklistView(title: "Primal Name", items: ["Verified nostr address", "Bitcoin lightning address", "VIP profile on primal.net"]),
            LearnAboutPremiumChecklistView(title: "Nostr Tools", items: ["Media hosting", "Advanced search", "Premium paid relay", "Nostr account backup"])
        ])
        rightStack.spacing = 22
        rightStack.isLayoutMarginsRelativeArrangement = true
        rightStack.directionalLayoutMargins = .init(top: 22, leading: 106, bottom: 22, trailing: 8)
        learnMoreButton.titleLabel?.font = .appFont(withSize: 15, weight: .regular)
        learnMoreButton.setTitle("Learn More About Premium", for: .normal)
        
        let mainStack = UIStackView(axis: .vertical, [rightStack, learnMoreButton])
        addSubview(mainStack)
        mainStack.pinToSuperview()
                
        
        let checkmark = ThemeableImageView(image: UIImage(named: "verifiedBackgroundLarge")).setTheme { $0.tintColor = .accent }
        let checkbox = UIImageView(image: UIImage(named: "verifiedCheckLarge"))
        checkmark.addSubview(checkbox)
        checkbox.centerToSuperview()
        addSubview(checkmark)
        checkmark.pinToSuperview(edges: .top, padding: 25).pinToSuperview(edges: .leading, padding: 24)
        
        if let toolsView = rightStack.arrangedSubviews.last {
            let ostrich = ThemeableImageView(image: UIImage(named: "ostrichLarge")).setTheme { $0.tintColor = .accent }
            addSubview(ostrich)
            ostrich.pin(to: toolsView, edges: .top).pinToSuperview(edges: .leading, padding: 24)
        }
        
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background4
        layer.borderColor = UIColor.background3.cgColor
    }
}

class LearnAboutPremiumChecklistView: UIStackView {
    init(title: String, items: [String]) {
        super.init(frame: .zero)
        
        let titleLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        titleLabel.font = .appFont(withSize: 20, weight: .bold)
        titleLabel.text = title
        addArrangedSubview(titleLabel)
        
        items.forEach { addArrangedSubview(LearnAboutPremiumChecklistItem($0)) }
        
        axis = .vertical
        spacing = 4
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LearnAboutPremiumChecklistItem: UIStackView {
    init(_ text: String) {
        super.init(frame: .zero)
        
        let check = ThemeableView().constrainToSize(4).setTheme { $0.backgroundColor = .foreground3 }
        check.layer.cornerRadius = 2
        addArrangedSubview(check)
        
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        addArrangedSubview(label)
        
        alignment = .center
        spacing = 8
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
