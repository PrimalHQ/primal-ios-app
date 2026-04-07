//
//  NotificationsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import UIKit
import GenericJSON

final class NotificationsViewController: PrimalPageController, PrimalNavigationBarController {
    static let tabSubtitles = ["All notifications", "Zaps", "Replies", "Mentions"]

    let primalNavigationBar = PrimalNavigationBar()
    let navBarBackground = UIView()

    private var cancellables: Set<AnyCancellable> = []

    let postButtonParent = UIView()
    let postButton = NewPostButton()

    init() {
        super.init(tabs: [
            ("ALL", { NotificationFeedViewController(tab: .all) }),
            ("ZAPS", { NotificationFeedViewController(tab: .zaps) }),
            ("REPLIES", { NotificationFeedViewController(tab: .replies) }),
            ("MENTIONS", { NotificationFeedViewController(tab: .mentions) })
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    override func updateTheme() {
        super.updateTheme()

        primalNavigationBar.updateTheme()
        navBarBackground.backgroundColor = .background
    }
}

private extension NotificationsViewController {
    func setup() {
        // Replace tabSelectionView's top constraint from safe area to nav bar bottom
        for constraint in view.constraints where constraint.firstItem === tabSelectionView && constraint.firstAttribute == .top {
            constraint.isActive = false
        }

        navBarBackground.backgroundColor = .background
        view.addSubview(navBarBackground)
        navBarBackground.pinToSuperview(edges: [.horizontal, .top])

        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)

        tabSelectionView.topAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor, constant: -10).isActive = true
        navBarBackground.bottomAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor).isActive = true

        primalNavigationBar.title = "Alert"
        primalNavigationBar.showChevron = false
        primalNavigationBar.onAvatarTapped = { [weak self] in
            guard let self else { return }
            MenuController().present(from: self)
        }

        $currentTab
            .sink { [weak self] tab in
                guard let self else { return }
                self.primalNavigationBar.subtitle = Self.tabSubtitles[tab]
            }
            .store(in: &cancellables)

        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedEmbedPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
    }
}
