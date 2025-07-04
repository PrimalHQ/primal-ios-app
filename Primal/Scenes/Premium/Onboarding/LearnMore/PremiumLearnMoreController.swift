//
//  PremiumLearnMoreController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.11.24..
//

import UIKit
import Combine

class PremiumLearnMoreController: PrimalPageController {
    enum Tab: Int {
        case premium = 0
        case pro = 1
        case features = 2
        case faq = 3
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(startingTab: Tab = .premium) {
        super.init(tabs: [
            ("PREMIUM", { PremiumLearnMoreWhyController() }),
            ("PRO", { PremiumLearnMoreProController() }),
            ("FEATURES", { PremiumLearnMoreFeaturesController() }),
            ("FAQ", { PremiumLearnMoreFAQController() })
        ], startingTab: startingTab.rawValue)
        
        $currentTab.sink { [weak self] tab in
            guard let self, let tab = Tab(rawValue: tab) else { return }
            switch tab {
            case .premium:
                title = "Primal Premium"
            case .pro:
                title = "Primal Pro"
            case .features:
                title = "Premium & Pro Features"
            case .faq:
                title = "Premium & Pro FAQ"
            }
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = customBackButton
        
        tabSelectionView.distribution = .fill
        tabSelectionView.stack.addArrangedSubview(UIView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
}
