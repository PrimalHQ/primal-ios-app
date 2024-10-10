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
        
        let button = UIButton()
        button.setImage(.init(named: "settingsIcon"), for: .normal)
        button.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsNotificationsViewController(), sender: nil)
        }), for: .touchUpInside)
        navigationItem.rightBarButtonItem = .init(customView: button)
    }
}
