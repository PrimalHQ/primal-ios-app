//
//  NotificationsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit

final class NotificationsViewController: UIViewController, Themeable, TitleSwipeController {
    let primalNavigationBar = PrimalNavigationBar()
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    let postButtonParent = UIView()
    let postButton = NewPostButton()

    private var currentTab: NotificationFeedViewController.Tab = .all

    private var cachedTabVCs: [NotificationFeedViewController.Tab: NotificationFeedViewController] = [:]

    private func tabVC(_ tab: NotificationFeedViewController.Tab) -> NotificationFeedViewController {
        if let cached = cachedTabVCs[tab] { return cached }
        let new = NotificationFeedViewController(tab: tab)
        cachedTabVCs[tab] = new
        return new
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
        view.backgroundColor = .background

        primalNavigationBar.updateTheme()

        cachedTabVCs.values.forEach {
            ($0 as? Themeable)?.updateTheme()
            let views: [Themeable] = $0.view.findAllSubviews()
            for view in views { view.updateTheme() }
        }
    }

    func titleSubtitleToLeftOfCurrent() -> (title: String, subtitle: String)? {
        guard let prev = NotificationFeedViewController.Tab(rawValue: currentTab.rawValue - 1) else { return nil }
        return (prev.selectionTitle, prev.selectionSubtitle ?? "")
    }

    func titleSubtitleToRightOfCurrent() -> (title: String, subtitle: String)? {
        guard let next = NotificationFeedViewController.Tab(rawValue: currentTab.rawValue + 1) else { return nil }
        return (next.selectionTitle, next.selectionSubtitle ?? "")
    }
}

extension NotificationsViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let current = (viewController as? NotificationFeedViewController)?.notificationTab,
            let prev = NotificationFeedViewController.Tab(rawValue: current.rawValue - 1)
        else { return nil }
        return tabVC(prev)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let current = (viewController as? NotificationFeedViewController)?.notificationTab,
            let next = NotificationFeedViewController.Tab(rawValue: current.rawValue + 1)
        else { return nil }
        return tabVC(next)
    }
}

extension NotificationsViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            primalNavigationBar.cancelTransition()
            return
        }

        guard let newTab = (pageViewController.viewControllers?.first as? NotificationFeedViewController)?.notificationTab else { return }
        currentTab = newTab
        primalNavigationBar.completeTransition(newTitle: newTab.selectionTitle, newSubtitle: newTab.selectionSubtitle ?? "")
    }
}

private extension NotificationsViewController {
    func setup() {
        updateTheme()

        pageVC.willMove(toParent: self)
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        addChild(pageVC)
        pageVC.didMove(toParent: self)

        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([tabVC(currentTab)], direction: .forward, animated: false)

        view.addGestureRecognizer(TitleSwipeGesture(vc: self))

        addNavigationBar()
        primalNavigationBar.title = currentTab.selectionTitle
        primalNavigationBar.subtitle = currentTab.selectionSubtitle ?? ""
        primalNavigationBar.showChevron = true
        primalNavigationBar.onAvatarTapped = { [weak self] in
            guard let self else { return }
            MenuController().present(from: self)
        }
        primalNavigationBar.onTitleTapped = { [weak self] in
            guard let self else { return }
            GenericSelectionController(
                items: NotificationFeedViewController.Tab.allCases,
                selectedItem: currentTab
            ) { [weak self] tab in
                self?.setTab(tab)
            }.present(from: self)
        }

        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedEmbedPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing, padding: 13).pinToSuperview(edges: .bottom, padding: NewPostButton.bottomPadding, safeArea: true)
    }

    func setTab(_ tab: NotificationFeedViewController.Tab) {
        guard tab != currentTab else { return }
        pageVC.setViewControllers([tabVC(tab)], direction: .forward, animated: false)
        currentTab = tab
        primalNavigationBar.completeTransition(newTitle: tab.selectionTitle, newSubtitle: tab.selectionSubtitle ?? "")
    }
}
