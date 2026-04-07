//
//  NotificationsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import UIKit
import GenericJSON

final class NotificationsViewController: UIViewController, Themeable, PrimalNavigationBarController {
    let primalNavigationBar = PrimalNavigationBar()

    let postButtonParent = UIView()
    let postButton = NewPostButton()

    private var cancellables: Set<AnyCancellable> = []

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        mainTabBarController?.freezeNotificationCount()
    }

    func updateTheme() {
        primalNavigationBar.updateTheme()
    }
}

private extension NotificationsViewController {
    func setup() {
        let feedVC = NotificationFeedViewController(tab: .all)

        addChild(feedVC)
        view.addSubview(feedVC.view)
        feedVC.view.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        feedVC.didMove(toParent: self)

        addNavigationBar()
        primalNavigationBar.title = "Notifications"
        primalNavigationBar.subtitle = "All notifications"
        primalNavigationBar.showChevron = false
        primalNavigationBar.onAvatarTapped = { [weak self] in
            guard let self, let profile = IdentityManager.instance.parsedUser else { return }
            show(ProfileViewController(profile: profile), sender: nil)
        }

        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedEmbedPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)

        updateTheme()
    }
}
