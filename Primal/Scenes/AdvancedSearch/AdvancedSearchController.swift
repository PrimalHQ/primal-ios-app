//
//  AdvancedSearchController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import UIKit
//
//class AdvancedSearchController: UIViewController {
//    lazy var nav = AdvancedSearchNavigationController(manager: manager)
//    let manager: AdvancedSearchManager
//    
//    init(manager: AdvancedSearchManager = .init()) {
//        self.manager = manager
//        manager.isFromAdvancedSearchScreen = true
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        nav.willMove(toParent: self)
//        addChild(nav)
//        nav.didMove(toParent: self)
//        
//        let stack = UIStackView(axis: .vertical, [SpacerView(height: 12, priority: .required), nav.view])
//        stack.alignment = .center
//        view.addSubview(stack)
//        stack.pinToSuperview()
//        nav.view.pinToSuperview(edges: .horizontal)
//        
//        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
//    }
//}
