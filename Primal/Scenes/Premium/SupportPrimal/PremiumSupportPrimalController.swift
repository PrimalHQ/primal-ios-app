//
//  PremiumSupportPrimalController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.11.24..
//

import UIKit

class PremiumSupportPrimalController: UIViewController {
    let state: PremiumState?
    init(state: PremiumState?) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bigLabel = UILabel(
            "Be a part of the Nostr revolution and help us continue building for this ecosystem.",
            color: .foreground,
            font: .appFont(withSize: 15, weight: .regular)
        )
        bigLabel.textAlignment = .center
        bigLabel.numberOfLines = 0
        
        let rateView = SupportPrimalInfoView(
            title: "Leave a 5 Star Review",
            desc: "App Store reviews really help improve the visibility of Nostr apps at this early stage.",
            action: "Go to App Listing",
            topView: UIImageView(image: UIImage(named: "5stars"))
        )
        
        let verified = VerifiedView().constrainToSize(36)
        let buySubscription = SupportPrimalInfoView(
            title: "Buy a Subscription",
            desc: "Extend your existing subscription to gain peace of mind and help fund Primal.",
            action: "Buy Primal Premium",
            topView: UIImageView(image: UIImage(named: "checkmark40"))
        )
        
        let becomeLegend = SupportPrimalInfoView(
            title: "Become a Legend",
            desc: "Donate $1000 or more to gain permanent membership and exclusive perks!",
            action: "Become a Legend Now",
            topView: UIImageView(image: UIImage(named: "becomeLegendLogo"))
        )
        
        let stack = UIStackView(axis: .vertical, [bigLabel, rateView, buySubscription, becomeLegend])
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 16, safeArea: true)
        
        title = "Support Primal"
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        if let state {
            becomeLegend.isHidden = state.isLegend
            buySubscription.isHidden = state.isLegend || state.recurring
        }
        
        rateView.addGestureRecognizer(BindableTapGestureRecognizer(action: {
            guard
                let url = URL(string: "itms-apps://itunes.apple.com/app/id1673134518?action=write-review"),
                UIApplication.shared.canOpenURL(url)
            else { return }
                
            UIApplication.shared.open(url, options: [:], completionHandler: nil)    
        }))
        buySubscription.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            
            if let state {
                show(PremiumBuySubscriptionController(pickedName: state.name, state: .extendSubscription), sender: nil)
            } else {
                guard let nav = navigationController else { return }
                nav.pushViewController(PremiumSearchNameController(title: "Find Primal Name", callback: { name in
                    nav.pushViewController(PremiumBuySubscriptionController(pickedName: name, state: .onboardingFinish), animated: true)
                }), animated: true)
            }
        }))
        becomeLegend.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.show(PremiumBecomeLegendController(), sender: nil)
        }))
        
        [rateView, buySubscription, becomeLegend].forEach { $0.actionButton.isUserInteractionEnabled = false }
    }
}

private class SupportPrimalInfoView: UIView {
    let actionButton = UIButton()
    
    init(title: String, desc: String, action: String, topView: UIView) {
        super.init(frame: .zero)
        
        let titleLabel = UILabel(title, color: .foreground, font: .appFont(withSize: 22, weight: .semibold))
        let descLabel = UILabel(desc, color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        actionButton.configuration = .accent(action, font: .appFont(withSize: 14, weight: .regular))
        
        let stack = UIStackView(axis: .vertical, [topView, titleLabel, descLabel, actionButton])
        stack.spacing = 8
        stack.alignment = .center
        addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16).pinToSuperview(edges: .top, padding: 20)
        
        layer.cornerRadius = 12
        backgroundColor = .background5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
