//
//  PremiumLegendAmountController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.11.24..
//

import FLAnimatedImage
import UIKit

class PremiumLegendAmountController: UIViewController {
    
    let balanceView = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let slider = GenericSliderView()

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
        
        title = "Pay Now"
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
            guard let name = WalletManager.instance.premiumState?.name else {
                guard let nav = navigationController else { return }
                show(PremiumSearchNameController(title: "Find Primal Name", callback: { name in
                    nav.show(PremiumLegendPayController(name: name, amount: balance), sender: nil)
                }), sender: nil)
                return
            }
            show(PremiumLegendPayController(name: name, amount: balance), sender: nil)
        }), for: .touchUpInside)
        
        balanceView.animateBalanceChange = false
        balanceView.balance = Int(Double(1000).usdToSAT)
    }
    
    func userStackView() -> UIView {
        guard let user = IdentityManager.instance.parsedUser else { return UIView()  }
        let image = FLAnimatedImageView().constrainToSize(80)
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.setUserImage(user, size: .init(width: 80, height: 80))
        
        let checkbox = VerifiedView().constrainToSize(24)
        
        let nameLabel = UILabel(user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
        
        let avatarButton = UIButton(configuration: .accent("Customize avatar", font: .appFont(withSize: 14, weight: .regular)))
        
        let titleView = PremiumUserTitleView()
        titleView.titleLabel.text = "Primal Legend"
        titleView.subtitleLabel.text = "Class of 2024"

        let userStack = UIStackView(axis: .vertical, [
            image, SpacerView(height: 16),
            nameStack, SpacerView(height: 20),
            titleView, SpacerView(height: 20),
            avatarButton, UILabel("(you can always do this later)", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
        ])
        
        userStack.alignment = .center
        
        return userStack
    }
}

