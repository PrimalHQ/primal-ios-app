//
//  PremiumLearnMoreController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.11.24..
//

import UIKit

class PremiumLearnMoreController: PrimalPageController {
    enum Tab: Int {
        case why = 0
        case features = 1
        case faq = 2
    }
    
    init(startingTab: Tab = .why) {
        super.init(tabs: [
            ("WHY PREMIUM", { PremiumLearnMoreWhyController() }),
            ("FEATURES", { PremiumLearnMoreFeaturesController() }),
            ("FAQ", { PremiumLearnMoreFAQController() })
        ], startingTab: startingTab.rawValue)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primal Premium"
        navigationItem.leftBarButtonItem = customBackButton
        
        tabSelectionView.distribution = .fill
        tabSelectionView.stack.addArrangedSubview(UIView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
}
