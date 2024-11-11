//
//  PremiumViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import Combine
import UIKit
import StoreKit

final class PremiumViewController: UIPageViewController, Themeable {
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = customBackButton
        
        WalletManager.instance.$premiumState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                if let state {
                    title = "Premium"
                    setViewControllers([PremiumHomeViewController(state: state)], direction: .forward, animated: false)
                } else {
                    setViewControllers([PremiumOnboardingHomeViewController()], direction: .forward, animated: false)
                }
                
                if navigationController?.topViewController == self {
                    let hasPremium = state != nil
                    navigationController?.setNavigationBarHidden(!hasPremium, animated: false)
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(!WalletManager.instance.hasPremium, animated: true)

        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
    }
}
