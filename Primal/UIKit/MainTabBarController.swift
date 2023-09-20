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

enum MainTab {
    case home, read, explore, messages, notifications
}

final class MainTabBarController: UIViewController, Themeable {
    lazy var home = FeedNavigationController()
    lazy var read = ReadNavigationController()
    lazy var explore = MainNavigationController(rootViewController: MenuContainerController(child: ExploreViewController()))
    lazy var messages = MainNavigationController(rootViewController: MenuContainerController(child: ChatListViewController()))
    lazy var notifications = MainNavigationController(rootViewController: MenuContainerController(child: NotificationsViewController()))

    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    lazy var buttons = (1...5).map { _ in
        UIButton()
    }

    let notificationIndicator = UIImageView(image: Theme.current.tabBarDotImage)
    
    let buttonStackParent = UIView()
    lazy var vStack = UIStackView(arrangedSubviews: [navigationBorder, buttonStackParent, safeAreaSpacer])
    let safeAreaSpacer = UIView()
    let closeMenuButton = UIButton()
    let navigationBorder = UIView().constrainToSize(height: 1)

    lazy var buttonStack = UIStackView(arrangedSubviews: buttons)
    private var foregroundObserver: NSObjectProtocol?
    private var noteObserver: NSObjectProtocol?
    private var profileObserver: NSObjectProtocol?

    var cancellables: Set<AnyCancellable> = []

    var hasNewNotifications = false {
        didSet {
            notificationIndicator.isHidden = !hasNewNotifications
        }
    }

    var currentPageIndex = 0 {
        didSet {
            updateButtons()
        }
    }
    
    var buttonIndex: Int {
        if currentPageIndex < 1 {
            return currentPageIndex
        }
        return currentPageIndex + 1
    }

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
        if let noteObserver {
            NotificationCenter.default.removeObserver(noteObserver)
        }
        if let profileObserver {
            NotificationCenter.default.removeObserver(profileObserver)
        }

        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    func showCloseMenuButton() {
        closeMenuButton.alpha = 0
        closeMenuButton.isHidden = false
        closeMenuButton.setImage(UIImage(named: "tabIcon\(buttonIndex + 1)")?.scalePreservingAspectRatio(size: 20).withRenderingMode(.alwaysTemplate), for: .normal)
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
        safeAreaSpacer.backgroundColor = .background
        buttonStackParent.backgroundColor = .background

        notificationIndicator.image = Theme.current.tabBarDotImage
        
        closeMenuButton.tintColor = .foreground

        updateButtons()

        [home, read, explore, messages, notifications].forEach {
            $0.updateThemeIfThemeable()
        }
        
        navigationBorder.backgroundColor = .background3
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        if !animated {
            notificationIndicator.alpha = hidden ? 0 : 1
            notificationIndicator.transform = hidden ? .init(translationX: 0, y: vStack.bounds.height) : .identity
            vStack.transform = hidden ? .init(translationX: 0, y: vStack.bounds.height) : .identity
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.vStack.transform = hidden ? .init(translationX: 0, y: self.vStack.bounds.height) : .identity
            self.notificationIndicator.transform = hidden ? .init(translationX: 0, y: self.vStack.bounds.height) : .identity
            self.notificationIndicator.alpha = hidden ? 0 : 1
        }
    }
    
    func switchToTab(_ tab: MainTab, open vc: UIViewController? = nil) {
        let nav: UINavigationController = {
            switch tab {
            case .home:
                return home
            case .read:
                return read
            case .explore:
                return explore
            case .messages:
                return messages
            case .notifications:
                return notifications
            }
        }()
        
        pageVC.setViewControllers([nav], direction: .forward, animated: true)
        currentPageIndex = indexForNav(nav)
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
        
        view.addSubview(notificationIndicator)
        if let imageView = buttons.last?.imageView {
            notificationIndicator.pin(to: imageView, edges: [.top, .trailing], padding: -6)
        }
        notificationIndicator.isHidden = true

        pageVC.didMove(toParent: self) // Notify child VC
        pageVC.setViewControllers([home], direction: .forward, animated: false)

        vStack.axis = .vertical

        view.addSubview(closeMenuButton)
        closeMenuButton.constrainToSize(width: 70, height: 56).pin(to: buttonStack, edges: [.trailing, .top])

        closeMenuButton.setImage(UIImage(named: "tabIcon1")?.scalePreservingAspectRatio(size: 20).withRenderingMode(.alwaysTemplate), for: .normal)
        closeMenuButton.isHidden = true

        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { notification in
            Connection.instance.reconnect()
        }
        noteObserver = NotificationCenter.default.addObserver(forName: .primalNoteLink, object: nil, queue: .main) { [weak self] notification in
            if let note = notification.object as? String {
                if let self {
                    Connection.instance.$isConnected
                        .filter({ $0 })
                        .first()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            self.menuButtonPressedForNav(self.home)
                            let vc = ThreadViewController(threadId: note)
                            self.home.pushViewController(vc, animated: true)
                        }
                        .store(in: &cancellables)
                }
            }
        }
        profileObserver = NotificationCenter.default.addObserver(forName: .primalProfileLink, object: nil, queue: .main) { [weak self] notification in
            guard
                let self,
                let npub = notification.object as? String,
                let hex = HexKeypair.npubToHexPubkey(npub)
                else {
                return
            }

            Connection.instance.$isConnected
                .filter({ $0 })
                .first()
                .receive(on: DispatchQueue.main)
                .sinkAsync { _ in
                    let parsedUser = await ProfileManager.instance.requestProfileInfo(hex)

                    self.menuButtonPressedForNav(self.home)
                    let vc = ProfileViewController(profile: parsedUser)
                    self.home.pushViewController(vc, animated: true)
                }
                .store(in: &cancellables)
        }

        for (index, button) in buttons.enumerated() {
            button.setImage(UIImage(named: "tabIcon\(index + 1)")?.scalePreservingAspectRatio(size: 20).withRenderingMode(.alwaysTemplate), for: .normal)
        }

        buttons.remove(at: 1).removeFromSuperview() // REMOVE READ FOR NOW

        [home, explore, messages, notifications].forEach { nav in
            buttons[indexForNav(nav)].addAction(.init(handler: { [weak self] _ in
                self?.menuButtonPressedForNav(nav)
            }), for: .touchUpInside)
        }
    }

    func updateButtons() {
        for (index, button) in buttons.enumerated() {
            button.tintColor = index == currentPageIndex ? .foreground : .foreground3
        }
    }

    func indexForNav(_ nav: UINavigationController) -> Int {
        switch nav {
        case home:          return 0
        case explore:       return 1
        case messages:      return 2
        case notifications: return 3
        default:            return 0
        }
    }

    func menuButtonPressedForNav(_ nav: UINavigationController) {
        guard pageVC.viewControllers?.contains(nav) == true else {
            pageVC.setViewControllers([nav],
                    direction: currentPageIndex < indexForNav(nav) ? .forward : .reverse,
                    animated: true
            )
            currentPageIndex = indexForNav(nav)
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
