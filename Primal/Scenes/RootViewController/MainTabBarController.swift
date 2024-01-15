//
//  MainTabBarController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

extension UIViewController {
    var mainTabBarController: MainTabBarController? {
        parent as? MainTabBarController ?? parent?.mainTabBarController
    }
}

enum MainTab: String {
    case home, explore, wallet, messages, notifications
    
    var tabImage: UIImage? {
        UIImage(named: "tabIcon-\(rawValue)")?.scalePreservingAspectRatio(size: 20).withRenderingMode(.alwaysTemplate)
    }
    
    var selectedTabImage: UIImage? {
        UIImage(named: "selectedTabIcon-\(rawValue)")?.scalePreservingAspectRatio(size: 20).withRenderingMode(.alwaysTemplate)
    }
}

final class MainTabBarController: UIViewController, Themeable {
    lazy var home = FeedNavigationController()
    lazy var explore = MainNavigationController(rootViewController: MenuContainerController(child: ExploreViewController()))
    lazy var wallet = MainNavigationController(rootViewController: MenuContainerController(child: WalletHomeViewController()))
    lazy var messages = MainNavigationController(rootViewController: MenuContainerController(child: ChatListViewController()))
    lazy var notifications = MainNavigationController(rootViewController: MenuContainerController(child: NotificationsViewController()))

    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    lazy var buttons = tabs.map { _ in UIButton() }

    let notificationIndicator = NotificationsIndicator()
    let messagesIndicator = NotificationsIndicator()
    
    private let buttonStackParent = UIView()
    private lazy var vStack = UIStackView(arrangedSubviews: [navigationBorder, buttonStackParent, safeAreaSpacer])
    private let safeAreaSpacer = UIView()
    private let circleBorderView = ThemeableView().constrainToSize(64).setTheme {
        $0.backgroundColor = .background
        $0.layer.borderColor = UIColor.background3.cgColor
    }
    private let navigationBorder = UIView().constrainToSize(height: 1)
    private lazy var circleWalletButton = ThemeableButton().constrainToSize(52).setTheme { [weak self] in
        let isWalletSelected = (self?.currentPageIndex ?? 0) == 2
        
        $0.backgroundColor = isWalletSelected ? .foreground : .background3
        $0.tintColor = isWalletSelected ? .background : .foreground3
        $0.setImage(isWalletSelected ? UIImage(named: "walletSpecialButtonPressed") : UIImage(named: "walletSpecialButton"), for: .normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let tab = tabs[safe: currentPageIndex] else { return super.preferredStatusBarStyle }
        return navForTab(tab).preferredStatusBarStyle
    }

    lazy var buttonStack = UIStackView(arrangedSubviews: buttons)

    var cancellables: Set<AnyCancellable> = []
    
    private let tabs: [MainTab] = [.home, .explore, .wallet, .notifications, .messages]

    var hasNewNotifications = false {
        didSet {
            notificationIndicator.isHidden = !hasNewNotifications
        }
    }
    
    var hasNewMessages = false {
        didSet {
            messagesIndicator.isHidden = !hasNewMessages
        }
    }

    var currentPageIndex = WalletSettings.startInWallet ? 2 : 0 {
        didSet {
            updateButtons()
        }
    }
    
    var showTabBarBorder: Bool {
        get { !navigationBorder.isHidden }
        set {
            navigationBorder.alpha = newValue ? 1 : 0
            circleBorderView.alpha = newValue ? 1 : 0
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hideForMenu() {
        UIView.animate(withDuration: 0.3) {
            self.buttonStack.alpha = 0
            self.circleWalletButton.alpha = 0
            self.showTabBarBorder = false
        }
    }

    func showButtons() {
        UIView.animate(withDuration: 0.3) {
            self.buttonStack.alpha = 1
            self.circleWalletButton.alpha = 1
            self.showTabBarBorder = true
        }
    }

    func updateTheme() {
        view.backgroundColor = .background
        safeAreaSpacer.backgroundColor = .background
        buttonStackParent.backgroundColor = .background

        updateButtons()

        [home, explore, wallet, messages, notifications].forEach {
            $0.updateThemeIfThemeable()
        }
        
        navigationBorder.backgroundColor = .background3
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        if !animated {
            vStack.transform = hidden ? .init(translationX: 0, y: vStack.bounds.height + 10) : .identity
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.vStack.transform = hidden ? .init(translationX: 0, y: self.vStack.bounds.height + 10) : .identity
        }
    }
    
    func navForTab(_ tab: MainTab) -> UINavigationController {
        switch tab {
        case .home:
            return home
        case .explore:
            return explore
        case .wallet:
            return wallet
        case .messages:
            return messages
        case .notifications:
            return notifications
        }
    }
    
    func switchToTab(_ tab: MainTab, open vc: UIViewController? = nil) {
        let nav: UINavigationController = navForTab(tab)
        
        if false == pageVC.viewControllers?.contains(where: { $0 == nav }) {
            let index = tabs.firstIndex(of: tab) ?? 6
            pageVC.setViewControllers([nav],
                                      direction: currentPageIndex < index ? .forward : .reverse,
                                      animated: true
            )
            currentPageIndex = index
        }
        
        if let vc {
            nav.pushViewController(vc, animated: true)
        }
    }
}

private extension MainTabBarController {
    func setup() {
        updateTheme()
        
        pageVC.willMove(toParent: self)
        addChild(pageVC) // Add child VC
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview()
        
        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.bottom, .horizontal])
        safeAreaSpacer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        buttonStackParent.addSubview(buttonStack)
        buttonStack.pinToSuperview().constrainToSize(height: 56)
        buttonStack.distribution = .fillEqually
        
        buttonStack.addSubview(notificationIndicator)
        buttonStack.addSubview(messagesIndicator)
        if let imageView = buttons.dropLast().last?.imageView {
            notificationIndicator.pin(to: imageView, edges: [.top, .trailing], padding: -6)
        }
        if let imageView = buttons.last?.imageView {
            messagesIndicator.pin(to: imageView, edges: [.top, .trailing], padding: -6)
        }
        notificationIndicator.isHidden = true
        messagesIndicator.isHidden = true

        pageVC.didMove(toParent: self) // Notify child VC
        pageVC.setViewControllers([WalletSettings.startInWallet ? wallet : home], direction: .forward, animated: false)

        vStack.axis = .vertical

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .dropFirst()
            .sink { _ in
                PrimalEndpointsManager.instance.checkIfNecessary()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    Connection.reconnect()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        RelaysPostbox.instance.reconnect()
                    }
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                Connection.disconnect()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .primalNoteLink)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] note in
                self?.switchToTab(.home, open: ThreadViewController(threadId: note))
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .primalProfileLink)
            .compactMap { $0.object as? String }
            .map { HexKeypair.npubToHexPubkey($0) ?? $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pubkey in
                self?.switchToTab(.home, open: ProfileViewController(profile: .init(data: .init(pubkey: pubkey))))
            }
            .store(in: &cancellables)
        
        updateButtons()
        addCircleWalletButton()
        
        zip(buttons, tabs).forEach { button, tab in
            button.addAction(.init(handler: { [weak self] _ in
                self?.menuButtonPressedForTab(tab)
            }), for: .touchUpInside)
        }
    }
    
    func addCircleWalletButton() {
        vStack.insertSubview(circleBorderView, at: 0)
        circleBorderView.pinToSuperview(edges: .top, padding: -7).centerToSuperview(axis: .horizontal)
        circleBorderView.layer.borderWidth = 1
        circleBorderView.layer.cornerRadius = 32
        
        let frontCover = ThemeableView().constrainToSize(62).setTheme { $0.backgroundColor = .background }
        frontCover.layer.cornerRadius = 31
        vStack.addSubview(frontCover)
        frontCover.pinToSuperview(edges: .top, padding: -6).centerToSuperview(axis: .horizontal)
        
        circleWalletButton.layer.cornerRadius = 26
        vStack.addSubview(circleWalletButton)
        circleWalletButton.pinToSuperview(edges: .top, padding: -1).centerToSuperview(axis: .horizontal)
        
        circleWalletButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.menuButtonPressedForTab(.wallet)
        }), for: .touchUpInside)
    }
    
    func updateButtons() {
        circleWalletButton.updateTheme()
        for (index, button) in buttons.enumerated() {
            button.tintColor = index == currentPageIndex ? .foreground : .foreground3
            
            button.setImage(index == currentPageIndex ? tabs[index].selectedTabImage : tabs[index].tabImage, for: .normal)
        }
    }

    func menuButtonPressedForTab(_ tab: MainTab) {
        let nav = navForTab(tab)
        guard pageVC.viewControllers?.contains(nav) == true else {
            switchToTab(tab)
            return
        }

        if nav.viewControllers.count > 1 {
            nav.popToRootViewController(animated: true)
            return
        }

        if let tableViews: [UITableView] = nav.topViewController?.view.findAllSubviews(), !tableViews.isEmpty {
            tableViews.forEach {
                if $0.indexPathsForVisibleRows?.isEmpty == false {
                    $0.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
                }
            }
            return
        }

        guard let scrollViews: [UIScrollView] = nav.topViewController?.view.findAllSubviews() else {
            return
        }
        scrollViews.forEach {
            if $0.delegate?.scrollViewShouldScrollToTop?($0) ?? true {
                $0.setContentOffset(.zero, animated: true)
            }
        }
    }
}

final class NotificationsIndicator: UIView, Themeable {
    private let innerCircleView = UIView()
    
    init() {
        super.init(frame: .zero)
     
        constrainToSize(11)
        
        addSubview(innerCircleView)
        innerCircleView.constrainToSize(8).centerToSuperview()
        
        layer.cornerRadius = 5.5
        innerCircleView.layer.cornerRadius = 4
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background
        innerCircleView.backgroundColor = .accent
    }
}
