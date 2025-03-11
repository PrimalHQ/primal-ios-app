//
//  MainTabBarController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit
import Lottie
import SafariServices

extension UIViewController {
    var mainTabBarController: MainTabBarController? {
        parent as? MainTabBarController ?? parent?.mainTabBarController
    }
}

enum MainTab: String {
    case home, reads, wallet, notifications, explore
    
    var tabImage: UIImage? {
        UIImage(named: "tabIcon-\(rawValue)")
    }
    
    var selectedTabImage: UIImage? {
        UIImage(named: "selectedTabIcon-\(rawValue)")
    }
}

final class MainTabBarController: UIViewController, Themeable {
    lazy var home = MainNavigationController(rootViewController: MenuContainerController(child: HomeFeedViewController()))
    lazy var reads = MainNavigationController(rootViewController: MenuContainerController(child: ReadsViewController()))
    lazy var wallet = MainNavigationController(rootViewController: MenuContainerController(child: WalletHomeViewController()))
    lazy var notifications = MainNavigationController(rootViewController: MenuContainerController(child: NotificationsViewController()))
    lazy var explore = MainNavigationController(rootViewController: MenuContainerController(child: ExploreViewController()))

    let vcParentView = UIView()

    lazy var buttons = tabs.map { _ in UIButton() }
    
    let notificationIndicator = NotificationsIndicator()
    
    private let buttonStackParent = UIView()
    private(set) lazy var vStack = UIStackView(arrangedSubviews: [navigationBorder, buttonStackParent, safeAreaSpacer])
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

    private var animationView = LottieAnimationView(animation: AnimationType.walletLightning.animation)
    
    lazy var buttonStack = UIStackView(arrangedSubviews: buttons)

    var cancellables: Set<AnyCancellable> = []
    
    private let tabs: [MainTab] = [.home, .reads, .wallet, .notifications, .explore]
    
    var continousConnection: ContinousConnection? {
        didSet {
            oldValue?.end()
        }
    }
    var deeplinkCancellable: AnyCancellable?
    
    let chatManager = ChatManager()
    var newMessageCount = 0 {
        didSet {
            for tab in tabs {
                (navForTab(tab).viewControllers.first as? MenuContainerController)?.newMessageCount = newMessageCount
            }
        }
    }
    
    var newNotifications: Int = 0 {
        didSet {
            if newNotifications == oldValue { return }
            
            notificationIndicator.isHidden = newNotifications < 1
        }
    }

    var currentPageIndex = WalletSettings.startInWallet ? 2 : 0 {
        didSet {
            updateButtons()
        }
    }
    
    var currentTab: MainTab { tabs[safe: currentPageIndex] ?? .home }
    
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
        
        chatManager.updateChatCount()
        chatManager.$newMessagesCount.removeDuplicates().receive(on: DispatchQueue.main)
            .sink { [weak self] newMessages in
                self?.newMessageCount = newMessages
            }
            .store(in: &cancellables)
    }
    
    deinit {
        continousConnection?.end()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    var updateChildren = false
    func updateTheme() {
        view.backgroundColor = .background

        updateButtons()

        if updateChildren {
            [home, reads, wallet, notifications, explore].forEach {
                $0.updateThemeIfThemeable()
            }
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
        case .reads:
            return reads
        case .wallet:
            return wallet
        case .notifications:
            return notifications
        case .explore:
            return explore
        }
    }
    
    func showToast(_ message: String, icon: UIImage? = UIImage(named: "toastCheckmark")) {
        let isTabBarHidden = vStack.transform != .identity
        
        if isTabBarHidden {
            view.showToast(message, icon: icon, extraPadding: 0)
        } else {
            vStack.showToast(message, icon: icon, extraPadding: 95)
        }
    }
    
    func switchToTab(_ tab: MainTab, open vc: UIViewController? = nil) {
        let nav: UINavigationController = navForTab(tab)
        let currentTab = navForTab(currentTab)
        
        defer {
            if let vc {
                nav.pushViewController(vc, animated: true)
            }
        }
        
        if nav == currentTab { return }
        
        nav.beginAppearanceTransition(true, animated: true)
        currentTab.beginAppearanceTransition(false, animated: true)
        
        nav.willMove(toParent: self)
        addChild(nav) // Add child VC
        vcParentView.addSubview(nav.view)
        nav.view.pinToSuperview()
        nav.didMove(toParent: self)
        
        currentPageIndex = tabs.firstIndex(of: tab) ?? 6
        
        nav.view.alpha = 0
        
        UIView.animate(withDuration: 5 / 30, delay: 0, options: [.curveEaseIn]) {
            currentTab.view.alpha = 0
            currentTab.view.transform = .init(translationX: 0, y: 40)
        } completion: { _ in
            currentTab.willMove(toParent: nil)
            currentTab.removeFromParent()
            currentTab.view.removeFromSuperview()
            currentTab.didMove(toParent: nil)
            
            currentTab.endAppearanceTransition()
            
            currentTab.view.alpha = 1
            currentTab.view.transform = .identity
        }
        
        UIView.animate(withDuration: 5 / 30, delay: 3 / 30, options: [.curveEaseOut]) {
            nav.view.alpha = 1
        } completion: { _ in
            nav.endAppearanceTransition()
        }
    }
    
    func playThunderAnimation() {
        animationView.isHidden = false
        animationView.play(fromProgress: 0, toProgress: 1)
    }
}

private extension MainTabBarController {
    func setup() {
        IdentityManager.instance.requestUserProfile()
        
        updateTheme()
        updateChildren = true
        
        view.addSubview(vcParentView)
        vcParentView.pinToSuperview()
        
        let nav = navForTab(currentTab)
        nav.willMove(toParent: self)
        addChild(nav) // Add child VC
        vcParentView.addSubview(nav.view)
        nav.view.pinToSuperview()
        nav.didMove(toParent: self)

        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.bottom, .horizontal])
        safeAreaSpacer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let background = ThemeableView().setTheme { $0.backgroundColor = .background }
        buttonStackParent.addSubview(background)
        background.pinToSuperview(edges: [.top, .horizontal]).pinToSuperview(edges: .bottom, padding: -100)
        
        buttonStackParent.addSubview(buttonStack)
        buttonStack
            .pinToSuperview(edges: [.horizontal, .top])
            .pinToSuperview(edges: .bottom, padding: -8)
            .constrainToSize(height: 56)
        buttonStack.distribution = .fillEqually
        
        buttonStack.addSubview(notificationIndicator)
        
        if let imageView = buttons.dropLast().last?.imageView {
            notificationIndicator.pin(to: imageView, edges: [.top, .trailing], padding: -4)
        }
        notificationIndicator.isHidden = true

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
        
        Connection.regular.isConnectedPublisher.filter { $0 }.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.continousConnection = Connection.regular.requestCacheContinous(name: "notification_counts", request: .object([
                "pubkey": .string(IdentityManager.instance.userHexPubkey)
            ])) { response in
                guard let resDict = response.arrayValue?.last?.objectValue else { return }
                
                var sum: Double = 0
                for type in NotificationType.allCases {
                    let key = String(type.rawValue)
                    sum += resDict[key]?.doubleValue ?? 0
                }
                
                DispatchQueue.main.async {
                    self?.newNotifications = Int(sum)
                }
            }
        }
        .store(in: &cancellables)
        
        DispatchQueue.main.async { [self] in
            RootViewController.instance.$navigateTo
                .filter { $0 != nil }
                .sink { [weak self] to in
                    guard let self, let to else { return }
                    RootViewController.instance.navigateTo = nil
                    
                    let (vc, tab) : (UIViewController?, MainTab?) = {
                        switch to {
                        case .profile(let pubkey):
                            return (ProfileViewController(profile: .init(data: .init(pubkey: pubkey))), .home)
                        case .note(let id):
                            return (ThreadViewController(threadId: id), .home)
                        case .article(let pubkey, let id):
                            return (LoadArticleController(kind: NostrKind.longForm.rawValue, identifier: id, pubkey: pubkey), .reads)
                        case .search(let text):
                            return (SearchNoteFeedController(feed: FeedManager(newFeed: PrimalFeed(
                                name: "Search",
                                spec: "{\"id\":\"advsearch\",\"query\":\"\(text)\"}",
                                description: "Primal search results",
                                feedkind: "search",
                                enabled: true
                            ))), .home)
                        case .tab(let mainTab):
                            return (nil, mainTab)
                        case .messages:
                            return (MessagesViewController(), .home)
                        case .bookmarks:
                            return (PublicBookmarksViewController(), .home)
                        case .premium:
                            return (PremiumViewController(), .home)
                        case .legends:
                            return (LegendListController(), .home)
                        case .newPost(let text, let files):
                            let newPost = NewPostViewController()
                            newPost.manager.textView.text = text
                            newPost.manager.addMedia(files)
                            return (newPost, nil)
                        }
                    }()
                                        
                    if let tab {
                        self.switchToTab(tab, open: vc)
                        if vc == nil {
                            self.navForTab(tab).popToRootViewController(animated: true)
                        }
                        
                        if self.presentedViewController as? SFSafariViewController != nil{
                            self.dismiss(animated: true)
                        }
                    } else if let vc {
                        (self.presentedViewController ?? self).present(vc, animated: true)
                    }
                }
                .store(in: &cancellables)
        }
        
        updateButtons()
        addCircleWalletButton()
        
        view.addSubview(animationView)
        animationView.isHidden = true
        animationView.isUserInteractionEnabled = false
        animationView.constrainToSize(width: 375, height: 100).centerToView(circleWalletButton)
        
        zip(buttons, tabs).forEach { button, tab in
            button.addAction(.init(handler: { [weak self] _ in
                self?.menuButtonPressedForTab(tab)
            }), for: .touchUpInside)
        }
    }
    
    func addCircleWalletButton() {
        buttonStackParent.insertSubview(circleBorderView, at: 0)
        circleBorderView.pinToSuperview(edges: .top, padding: -7).centerToSuperview(axis: .horizontal)
        circleBorderView.layer.borderWidth = 1
        circleBorderView.layer.cornerRadius = 32
        
        let frontCover = ThemeableView().constrainToSize(62).setTheme { $0.backgroundColor = .background }
        frontCover.layer.cornerRadius = 31
        buttonStackParent.addSubview(frontCover)
        frontCover.pinToSuperview(edges: .top, padding: -6).centerToSuperview(axis: .horizontal)
        
        circleWalletButton.layer.cornerRadius = 26
        buttonStackParent.addSubview(circleWalletButton)
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
        guard currentTab == tab else {
            switchToTab(tab)
            return
        }
        
        let nav = navForTab(tab)
        if nav.viewControllers.count > 1 {
            nav.popToRootViewController(animated: true)
            return
        }
        
        if tab == .home, let child: HomeFeedChildController = nav.viewControllers.first?.findInChildren() {
            child.feed.addAllFuturePosts()
        }

        if let tableViews: [UITableView] = nav.topViewController?.view.findAllSubviews(), !tableViews.isEmpty {
            tableViews.forEach {
                if $0.indexPathsForVisibleRows?.isEmpty == false {
                    for section in 0...3 {
                        if $0.numberOfRows(inSection: section) > 0 {
                            $0.scrollToRow(at: .init(row: 0, section: section), at: .top, animated: true)
                            return
                        }
                    }
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

final class NumberedNotificationIndicator: UIView, Themeable {
    var number: Int {
        didSet {
            update()
        }
    }
    
    private let label = UILabel()
    
    init(number: Int = 0) {
        self.number = number
        super.init(frame: .zero)
        
        addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .leading, padding: 3.5)
        label.font = .appFont(withSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center

        constrainToSize(height: 16)
        widthAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
        layer.cornerRadius = 8
        
        updateTheme()
        update()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func update() {
        if number <= 0 {
            isHidden = true
            return
        }
        
        isHidden = false
        
        if number > 99 {
            label.text = "99+"
            return
        }
        
        label.text = "\(number)"
    }
    
    func updateTheme() {
        backgroundColor = .accent
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
