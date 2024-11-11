//
//  PremiumLearnMoreController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.11.24..
//

import UIKit

class PremiumLearnMoreController: PrimalPageController {
    init() {
        super.init(tabs: [
            ("WHY PREMIUM", { PremiumLearnMoreWhyController() })
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
