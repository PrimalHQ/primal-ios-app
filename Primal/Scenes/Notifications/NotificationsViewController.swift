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
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.rightBarButtonItem = customSearchButton(scope: .myNotifications)
    }
}
