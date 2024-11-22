//
//  AdvancedSearchController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import UIKit

class AdvancedSearchController: UIViewController {
    lazy var nav = AdvancedSearchNavigationController(manager: manager)
    let manager: AdvancedSearchManager
    
    init(manager: AdvancedSearchManager = .init()) {
        self.manager = manager
        manager.isFromAdvancedSearchScreen = true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pullBar = UIView().constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground
        pullBar.layer.cornerRadius = 2.5
        
        view.backgroundColor = .background4
        
        nav.willMove(toParent: self)
        addChild(nav)
        nav.didMove(toParent: self)
        
        let stack = UIStackView(axis: .vertical, [SpacerView(height: 12, priority: .required), pullBar, SpacerView(height: 8, priority: .required), nav.view])
        stack.alignment = .center
        view.addSubview(stack)
        stack.pinToSuperview()
        nav.view.pinToSuperview(edges: .horizontal)
        
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
    }
}


class AdvancedSearchNavigationController: MainNavigationController {
    let manager: AdvancedSearchManager
    
    init(manager: AdvancedSearchManager) {
        self.manager = manager
        super.init(rootViewController: AdvancedSearchHomeController(manager: manager))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func updateAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .background4
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground2
        ]
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}
