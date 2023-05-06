//
//  MainTabBarController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit

extension UIViewController {
    var mainTabBarController: MainTabBarController? {
        parent as? MainTabBarController ?? parent?.mainTabBarController
    }
}

class MainTabBarController: UIViewController {
    lazy var home = FeedNavigationController(feed: feed)
    
    let feed: Feed
    let pageVC = UIPageViewController(nibName: nil, bundle: nil)
    
    let buttons = (1...5).map {
        let button = UIButton()
        button.setImage(UIImage(named: "tabIcon\($0)"), for: .normal)
        return button
    }
    
    init(feed: Feed) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainTabBarController {
    func setup() {
        let hStack = UIStackView(arrangedSubviews: buttons)
        let vStack = UIStackView(arrangedSubviews: [pageVC.view, hStack])
        
        addChild(pageVC) // Add child VC
        
        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.horizontal, .top]).pinToSuperview(edges: .bottom, safeArea: true)
        
        pageVC.didMove(toParent: self) // Notify child VC
        
        pageVC.setViewControllers([home], direction: .forward, animated: false)
        
        hStack.distribution = .fillEqually
        hStack.constrainToSize(height: 68)
        
        vStack.axis = .vertical
    }
}
