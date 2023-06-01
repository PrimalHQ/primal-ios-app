//
//  MainTabBarController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit

extension UIViewController {
    var mainTabBarController: MainTabBarController? {
        parent as? MainTabBarController ?? parent?.mainTabBarController
    }
}

final class MainTabBarController: UIViewController, Themeable {
    lazy var home = FeedNavigationController()
    lazy var read = ReadNavigationController()
    lazy var explore = MainNavigationController(rootViewController: MenuContainerController(child: ExploreViewController()))
    lazy var messages = MainNavigationController(rootViewController: MenuContainerController(child: MessagesViewController()))
    lazy var notifications = MainNavigationController(rootViewController: MenuContainerController(child: NotificationsViewController()))
    
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    lazy var buttons = (1...5).map { _ in UIButton() }
    
    var currentPageIndex = 0 {
        didSet {
            updateButtons()
        }
    }
    
    let closeMenuButton = UIButton()
    
    lazy var buttonStack = UIStackView(arrangedSubviews: buttons)
    private var foregroundObserver: NSObjectProtocol?

    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }
    
    func showCloseMenuButton() {
        closeMenuButton.alpha = 0
        closeMenuButton.isHidden = false
        closeMenuButton.setImage(UIImage(named: "tabIcon\(currentPageIndex + 1)"), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.buttonStack.alpha = 0
            self.closeMenuButton.alpha = 1
        }
    }
    
    func showButtons() {
        UIView.animate(withDuration: 0.3) {
            self.buttonStack.alpha = 1
            self.closeMenuButton.alpha = 0
        } completion: { _ in
            self.closeMenuButton.isHidden = true
        }
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        closeMenuButton.tintColor = .foreground
        closeMenuButton.backgroundColor = .background

        buttons.forEach { $0.backgroundColor = .background }
        
        updateButtons()
        
        [home, read, explore, messages, notifications].forEach { $0.updateThemeIfThemeable() }
    }
}

private extension MainTabBarController {
    func setup() {
        updateTheme()
        
        let vStack = UIStackView(arrangedSubviews: [pageVC.view, buttonStack])
        pageVC.willMove(toParent: self)
        addChild(pageVC) // Add child VC
        
        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.horizontal, .top]).pinToSuperview(edges: .bottom, safeArea: true)
        
        pageVC.didMove(toParent: self) // Notify child VC
        pageVC.setViewControllers([home], direction: .forward, animated: false)
        
        buttonStack.distribution = .fillEqually
        buttonStack.constrainToSize(height: 68)
        
        vStack.axis = .vertical
        
        view.addSubview(closeMenuButton)
        closeMenuButton.constrainToSize(width: 68, height: 68).pin(to: buttonStack, edges: [.trailing, .top])

        closeMenuButton.setImage(UIImage(named: "tabIcon1"), for: .normal)
        closeMenuButton.isHidden = true
        
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { notification in
            Connection.the.reconnect()
        }
        
        for (index, button) in buttons.enumerated() {
            button.setImage(UIImage(named: "tabIcon\(index + 1)"), for: .normal)
        }
        
        buttons[0].addTarget(self, action: #selector(homeButtonPressed), for: .touchUpInside)
        buttons[1].addTarget(self, action: #selector(readButtonPressed), for: .touchUpInside)
        buttons[2].addTarget(self, action: #selector(exploreButtonPressed), for: .touchUpInside)
        buttons[3].addTarget(self, action: #selector(messagesButtonPressed), for: .touchUpInside)
        buttons[4].addTarget(self, action: #selector(notificationsButtonPressed), for: .touchUpInside)
    }
    
    func updateButtons() {
        for (index, button) in buttons.enumerated() {
            button.tintColor = index == currentPageIndex ? .foreground : .foreground3
        }
    }
    
    @objc func readButtonPressed() {
        guard pageVC.viewControllers?.contains(read) == true else {
            pageVC.setViewControllers([read],
                direction: currentPageIndex == 0 ? .forward : .reverse,
                animated: true
            )
            currentPageIndex = 1
            return
        }
    }
    
    @objc func exploreButtonPressed() {
        guard pageVC.viewControllers?.contains(explore) == true else {
            pageVC.setViewControllers([explore],
                direction: currentPageIndex < 2 ? .forward : .reverse,
                animated: true
            )
            currentPageIndex = 2
            return
        }
    }
    
    @objc func messagesButtonPressed() {
        guard pageVC.viewControllers?.contains(messages) == true else {
            pageVC.setViewControllers([messages],
                direction: currentPageIndex < 3 ? .forward : .reverse,
                animated: true
            )
            currentPageIndex = 3
            return
        }
    }
    
    @objc func notificationsButtonPressed() {
        guard pageVC.viewControllers?.contains(notifications) == true else {
            pageVC.setViewControllers([notifications],
                direction: currentPageIndex < 4 ? .forward : .reverse,
                animated: true
            )
            currentPageIndex = 4
            return
        }
    }
    
    @objc func homeButtonPressed() {
        guard pageVC.viewControllers?.contains(home) == true else {
            pageVC.setViewControllers([home], direction: .reverse, animated: true)
            currentPageIndex = 0
            return
        }
        
        guard let homeVC = (home.topViewController as? MenuContainerController)?.child as? HomeFeedViewController else {
            home.popToRootViewController(animated: true)
            return
        }
        
        if !homeVC.posts.isEmpty {
            homeVC.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
