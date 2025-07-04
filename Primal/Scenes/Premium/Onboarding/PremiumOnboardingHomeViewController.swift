//
//  PremiumOnboardingHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.11.24..
//

import Combine
import UIKit
import StoreKit

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

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
    @Published var isViewingPro: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
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
    var premiumInfoItems: [String] { [
        "Verified Nostr Address",
        "Custom Lightning Address",
        "VIP profile on primal.net",
        "Advanced Nostr search",
        "Premium paid relay",
        "10GB media storage",
        "1GB max file size"
    ] }
    
    var proInfoItems: [String] { [
        "Everything in Premium, and",
        "Primal Studio",
        "Legend Status on Primal",
        "100GB media storage",
        "10GB max file size"
    ] }
    
    func setup() {
        let introLabel = ThemeableLabel("Upgrade your Primal experience today.", textColor: { .foreground3 }, font: .appFont(withSize: 18, weight: .regular))
        
        let termsAndConditions = TermsAndConditionsView()
        
        let learnAboutButton = UIButton()
        let pageIndicator = PrimalProgressView(progress: 0, total: 2, bottomPadding: 0)
        pageIndicator.secondaryColor = .foreground6
        
        let botStack = UIStackView(axis: .vertical, [
            pageIndicator, SpacerView(height: 4),
            learnAboutButton, SpacerView(height: 12, priority: .defaultLow),
            termsAndConditions
        ])
        
        let topStack = UIStackView(axis: .vertical, [])
        let mainStack = UIStackView(axis: .vertical, [topStack, UIView(), botStack])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .vertical, safeArea: true)
        
        topStack.alignment = .center
        botStack.alignment = .center
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        
        let cardWidth: CGFloat = 275
        let premiumInfoView = LearnAboutPremiumView(title: "Premium", tint: .accent, items: premiumInfoItems).constrainToSize(width: cardWidth)
        let proInfoView = LearnAboutPremiumView(title: "Pro", tint: .pro, items: proInfoItems, hideFirstCheckbox: true)
        if let premium = WalletManager.instance.premiumState, !premium.isExpired {
            topStack.addArrangedSubview(UILabel("Primal Pro", color: .foreground, font: .appFont(withSize: 36, weight: .bold)))
            introLabel.text = "Upgrade to the highest level of visibility, features and recognition across the network, and get access to professional tools."
            introLabel.textAlignment = .center
            introLabel.numberOfLines = 0
            introLabel.font = .appFont(withSize: 15, weight: .regular)
            
            isViewingPro = true
            pageIndicator.isHidden = true
            
            view.addSubview(proInfoView)
            proInfoView.pinToSuperview(edges: .horizontal, padding: 36)
            proInfoView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 30).isActive = true
            if RootViewController.instance.view.frame.height > 700 {
                proInfoView.constrainToSize(height: 410)
            }
        } else {
            introLabel.adjustsFontSizeToFitWidth = true
            proInfoView.constrainToSize(width: cardWidth)
            
            let spacerView = UIView()
            let stack = UIStackView([premiumInfoView, SpacerView(width: 16), proInfoView, spacerView])
            
            let scrollView = UIScrollView().constrainToSize(height: 450)
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.isPagingEnabled = true
            scrollView.addSubview(stack)
            scrollView.delegate = self
            
            stack.pinToSuperview(edges: [.top, .trailing]).pinToSuperview(edges: .leading, padding: 24)
            
            view.addSubview(scrollView)
            scrollView.pinToSuperview(edges: .horizontal)
            scrollView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 24).isActive = true
            
            // we need to make this spacer just right size so that pro card is centred when the scroll view is fully scrolled
            spacerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -cardWidth / 2).isActive = true
            
            if RootViewController.instance.view.frame.height > 700 {
                [
                    UILabel("Primal", color: .foreground, font: .appFont(withSize: 36, weight: .bold)),
                    UILabel("Premium & Pro", color: .foreground, font: .appFont(withSize: 36, weight: .bold)),
                    SpacerView(height: 22)
                ]
                    .forEach { topStack.addArrangedSubview($0) }
                topStack.spacing = -8
            } else {
                parent?.title = "Premium & Pro"
            }
        }
        topStack.addArrangedSubview(introLabel)
        
        $isViewingPro.removeDuplicates().sink { isPro in
            UIView.transition(with: botStack, duration: 0.2, options: .transitionCrossDissolve) {
                learnAboutButton.configuration = isPro ? .coloredButton("Learn about Primal Pro", color: .pro) : .coloredButton("Learn about Primal Premium", color: .accent)
                pageIndicator.primaryColor = isPro ? .pro : .accent
                pageIndicator.currentPage = isPro ? 1 : 0
            }
        }
        .store(in: &cancellables)
        
        learnAboutButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(PremiumLearnMoreController(startingTab: isViewingPro ? .pro : .premium), sender: nil)
        }), for: .touchUpInside)
                
        premiumInfoView.actionButton.addAction(.init(handler: { [weak self] _ in
            guard let nav = self?.navigationController else { return }
            
            if let state = WalletManager.instance.premiumState {
                nav.pushViewController(PremiumBuySubscriptionController(pickedName: state.name, kind: .premium, state: .buySubscription), animated: true)
                return
            }
            
            nav.pushViewController(PremiumSearchNameController(title: "Find Primal Name", callback: { name in
                nav.pushViewController(PremiumBuySubscriptionController(pickedName: name, kind: .premium, state: .onboardingFinish), animated: true)
            }), animated: true)
        }), for: .touchUpInside)
        
        proInfoView.actionButton.addAction(.init(handler: { [weak self] _ in
            guard let nav = self?.navigationController else { return }
            
            if let state = WalletManager.instance.premiumState {
                nav.pushViewController(PremiumBuySubscriptionController(pickedName: state.name, kind: .pro, state: .upgradeToPro), animated: true)
                return
            }
            
            nav.pushViewController(PremiumSearchNameController(title: "Find Primal Name", buttonTint: .pro, callback: { name in
                nav.pushViewController(PremiumBuySubscriptionController(pickedName: name, kind: .pro, state: .onboardingFinish), animated: true)
            }), animated: true)
        }), for: .touchUpInside)
        
        InAppPurchaseManager.shared.fetchPremiumSubscriptions { products in
            if let monthly = products.first(where: { $0.id == InAppPurchaseManager.monthlyPremiumId }) {
                premiumInfoView.monthly = monthly.displayPrice
                
                if let yearly = products.first(where: { $0.id == InAppPurchaseManager.yearlyPremiumId }) {
                    premiumInfoView.discount = Int((100 - (100 * yearly.price.doubleValue / (monthly.price.doubleValue * 12))).rounded())
                }
            }
            
            if let yearly = products.first(where: { $0.id == InAppPurchaseManager.yearlyPremiumId }) {
                premiumInfoView.yearly = yearly.displayPrice
            }
            
            if let monthly = products.first(where: { $0.id == InAppPurchaseManager.monthlyProId }) {
                proInfoView.monthly = monthly.displayPrice
                
                if let yearly = products.first(where: { $0.id == InAppPurchaseManager.yearlyProId }) {
                    proInfoView.discount = Int((100 - (100 * yearly.price.doubleValue / (monthly.price.doubleValue * 12))).rounded())
                }
            }
            
            if let yearly = products.first(where: { $0.id == InAppPurchaseManager.yearlyProId }) {
                proInfoView.yearly = yearly.displayPrice
            }
        }
    }
}

extension PremiumOnboardingHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isViewingPro = scrollView.contentOffset.x > 150
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

class LearnAboutPremiumView: UIView {
    let actionButton = UIButton().constrainToSize(height: 48)
    
    private let monthlyPriceLabel = UILabel()
    private lazy var yearlyLabel = UILabel("\(yearly) billed anually", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
    private lazy var discountView = PremiumDiscountView(discount: discount, color: tintColor)
    
    var monthly: String = "--" { didSet { updateMonthly() } }
    var yearly: String = "--" {
        didSet {
            yearlyLabel.text = "\(yearly) billed anually"
        }
    }
    var discount: Int = 10 { didSet { discountView.discount = discount } }
    
    init(title: String, tint: UIColor, items: [String], hideFirstCheckbox: Bool = false) {
        super.init(frame: .zero)
        tintColor = tint
        
        let stack = UIStackView(axis: .vertical, [])
        
        let primalLabel = UILabel("Primal", color: .foreground, font: .appFont(withSize: 24, weight: .bold))
        primalLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let titleStack = UIStackView([primalLabel, SpacerView(width: 2), UILabel(title, color: tint, font: .appFont(withSize: 24, weight: .bold))])
        stack.addArrangedSubview(titleStack)
        stack.setCustomSpacing(16, after: titleStack)
        
        updateMonthly()
        stack.addArrangedSubview(monthlyPriceLabel)
        stack.setCustomSpacing(6, after: monthlyPriceLabel)
        
        let yearlyStack = UIStackView([yearlyLabel, SpacerView(width: 4), discountView, UIView()])
        yearlyStack.alignment = .center
        stack.addArrangedSubview(yearlyStack)
        stack.setCustomSpacing(16, after: yearlyStack)
        
        var isFirst = true
        items.forEach {
            let checkListView = LearnAboutPremiumChecklistItem($0)
            if isFirst && hideFirstCheckbox {
                checkListView.check.isHidden = true
                isFirst = false
            }
            stack.addArrangedSubview(checkListView)
        }
        
        stack.addArrangedSubview(SpacerView(height: 0, priority: .init(1)))
        actionButton.configuration = .pill(text: "Buy \(title)", foregroundColor: .white, backgroundColor: tint, font: .appFont(withSize: 18, weight: .semibold))
        stack.addArrangedSubview(actionButton)
        
        stack.spacing = 10
        
        addSubview(stack)
        stack.pinToSuperview(padding: 16)
        
        layer.cornerRadius = 12
        backgroundColor = .background5
    }
    
    func updateMonthly() {
        let monthlyText = NSMutableAttributedString(string: monthly, attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 44, weight: .bold)
        ])
        monthlyText.append(.init(string: " /month", attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 20, weight: .regular)
        ]))
        monthlyPriceLabel.attributedText = monthlyText
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class PremiumDiscountView: UIView {
    var discount: Int { didSet { label.text = "Save \(discount)%" }}
    
    private lazy var label = UILabel("Save \(discount)%", color: .white, font: .appFont(withSize: 13, weight: .semibold))
    
    init(discount: Int, color: UIColor) {
        self.discount = discount
        super.init(frame: .zero)
        
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 6).centerToSuperview()
        
        constrainToSize(height: 22)
        layer.cornerRadius = 11
        backgroundColor = color.withAlphaComponent(0.4)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LearnAboutPremiumChecklistItem: UIStackView {
    let check = UIImageView(image: .premiumCheckList)
    
    init(_ text: String) {
        super.init(frame: .zero)
        
        check.tintColor = .foreground3
        check.setContentHuggingPriority(.required, for: .horizontal)
        addArrangedSubview(check)
        
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 16, weight: .regular)
        addArrangedSubview(label)
        
        alignment = .center
        spacing = 8
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
