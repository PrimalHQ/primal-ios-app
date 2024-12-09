//
//  PremiumLegendAmountController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.11.24..
//

import FLAnimatedImage
import UIKit

class PremiumLegendAmountController: UIViewController {
    enum State {
        case existingUser(PremiumState)
        case name(String)
        
        var name: String {
            switch self {
            case .existingUser(let premiumState):
                return premiumState.name
            case .name(let string):
                return string
            }
        }
    }
    
    
    let balanceView = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let slider = GenericSliderView()
    
    let state: State
    init(state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let action = LargeRoundedButton(title: "Pay Now")
        
        let sliderStack = UIStackView(axis: .vertical, [slider, UIStackView([
            UILabel("$1000", color: .foreground4, font: .appFont(withSize: 16, weight: .semibold)),
            UIView(),
            UILabel("1 BTC", color: .foreground4, font: .appFont(withSize: 16, weight: .semibold))
        ])])
        
        let mainStack = UIStackView(axis: .vertical, [userStackView(), balanceView, sliderStack, action])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 44, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        balanceView.largeAmountLabel.centerToView(view, axis: .horizontal)
        
        title = "Become a Primal Legend"
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        slider.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            let minSats = CGFloat(Double(1000).usdToSAT)
            let maxSats = CGFloat(Double.BTC_TO_SAT)
            
            balanceView.balance = Int((slider.value * (maxSats - minSats)) + minSats)
        }), for: .valueChanged)
        
        action.addAction(.init(handler: { [unowned self] _ in
            let balance = balanceView.balance

            show(PremiumLegendPayController(name: state.name, amount: balance), sender: nil)
        }), for: .touchUpInside)
        
        balanceView.animateBalanceChange = false
        balanceView.balance = Int(Double(1000).usdToSAT)
    }
    
    func userStackView() -> UIView {
        let image = FLAnimatedImageView().constrainToSize(80)
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        if let user = IdentityManager.instance.parsedUser {
            image.setUserImage(user, size: .init(width: 80, height: 80))
        }
        
        let checkbox = VerifiedView().constrainToSize(24)
        
        let nameLabel = UILabel(state.name, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
        
//        let avatarButton = UIButton(configuration: .accent("Customize avatar", font: .appFont(withSize: 14, weight: .regular)))
        
        let titleView = PremiumUserTitleView()
        titleView.titleLabel.text = "Legend"
        titleView.subtitleLabel.text = "\(Calendar.current.component(.year, from: Date()))"

        let userStack = UIStackView(axis: .vertical, [
            image, SpacerView(height: 16),
            nameStack, SpacerView(height: 20),
            titleView, //SpacerView(height: 20),
//            avatarButton, UILabel("(you can always do this later)", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
        ])
        
        userStack.alignment = .center
        
        return userStack
    }
}

