//
//  OnboardingParentViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

class OnboardingParentViewController: UINavigationController {
    init() {
        super.init(rootViewController: OnboardingStartViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 24, weight: .semibold),
            .foregroundColor: UIColor(rgb: 0xCCCCCC)
        ]
    }
}
