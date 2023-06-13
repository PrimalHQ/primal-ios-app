//
//  FeedNavigationController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit

final class ReadNavigationController: MainNavigationController {
    init() {
        super.init(rootViewController: MenuContainerController(child: ReadViewController()))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FeedNavigationController: MainNavigationController {
    init() {
        super.init(rootViewController: MenuContainerController(child: HomeFeedViewController(feed: FeedManager())))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainNavigationController: UINavigationController, Themeable, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
            
        interactivePopGestureRecognizer?.delegate = self
        
        updateTheme()
    }
    
    func updateTheme() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.background
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 20, weight: .semibold),
            .foregroundColor: UIColor.foreground
        ]
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        viewControllers.forEach { $0.updateThemeIfThemeable() }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
