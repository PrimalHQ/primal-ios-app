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

class MainTabBarController: UIViewController {
    lazy var home = FeedNavigationController(feed: feed)
    
    let feed: Feed
    let pageVC = UIPageViewController(nibName: nil, bundle: nil)
    
    lazy var buttons = (1...5).map {
        let button = UIButton()
        button.setImage(UIImage(named: "tabIcon\($0)"), for: .normal)
        return button
    }
    
    let closeMenuButton = UIButton()
    
    lazy var buttonStack = UIStackView(arrangedSubviews: buttons)
    private var foregroundObserver: NSObjectProtocol?

    init(feed: Feed) {
        self.feed = feed
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
}

private extension MainTabBarController {
    @objc func homeButtonPressed() {
        guard pageVC.viewControllers?.contains(home) == true else {
            pageVC.setViewControllers([home], direction: .reverse, animated: true)
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
    
    func setup() {
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
        
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            feed.reconnect()
        }
        
        buttons[0].addTarget(self, action: #selector(homeButtonPressed), for: .touchUpInside)
    }
}
