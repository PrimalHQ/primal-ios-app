//
//  OnboardingParentViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI

final class OnboardingParentViewController: UINavigationController {
    init() {
        super.init(rootViewController: OnboardingStartViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 24, weight: .semibold),
            .foregroundColor: UIColor(rgb: 0xCCCCCC)
        ]
        
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
}
