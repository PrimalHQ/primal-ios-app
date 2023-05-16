//
//  FeedNavigationController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit

class ReadNavigationController: MainNavigationController {
    init(feed: Feed) {
        super.init(rootViewController: MenuContainerController(child: ReadViewController(), feed: feed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedNavigationController: MainNavigationController {
    init(feed: Feed) {
        super.init(rootViewController: MenuContainerController(child: HomeFeedViewController(feed: feed), feed: feed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 24, weight: .semibold),
            .foregroundColor: UIColor(rgb: 0xCCCCCC)
        ]
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
}
