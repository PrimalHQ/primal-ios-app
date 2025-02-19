//
//  NotificationsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import UIKit
import GenericJSON

final class NotificationsViewController: PrimalPageController {
    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
    init() {
        super.init(tabs: [
            ("ALL", { NotificationFeedViewController(tab: .all) }),
            ("ZAPS", { NotificationFeedViewController(tab: .zaps) }),
            ("REPLIES", { NotificationFeedViewController(tab: .replies) }),
            ("MENTIONS", { NotificationFeedViewController(tab: .mentions) }),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        title = "Notifications"
        
        navigationItem.rightBarButtonItem = customSearchButton(scope: .myNotifications)
        
        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(NewPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.rightBarButtonItem = customSearchButton(scope: .myNotifications)
    }
}
