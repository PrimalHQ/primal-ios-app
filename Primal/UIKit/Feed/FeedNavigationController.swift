//
//  FeedNavigationController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit

final class ReadNavigationController: MainNavigationController {
    init(feed: SocketManager) {
        super.init(rootViewController: MenuContainerController(child: ReadViewController(), feed: feed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FeedNavigationController: MainNavigationController {
    init(feed: SocketManager) {
        super.init(rootViewController: MenuContainerController(child: HomeFeedViewController(feed: feed), feed: feed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainNavigationController: UINavigationController, Themeable {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
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
}
