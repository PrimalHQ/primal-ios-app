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
import GenericJSON
import AVFoundation
import PrimalShared

enum MainTab: String {
    case home, reads, wallet, notifications, explore

    var tabTitle: String {
        switch self {
        case .home:             return "Feeds"
        case .reads:            return "Reads"
        case .wallet:           return "Wallet"
        case .notifications:    return "Alerts"
        case .explore:          return "Explore"
        }
    }

    var tabImage: UIImage? {
        if #available(iOS 26.0, *) { return UIImage(named: "tabIcon2-\(rawValue)") }

        return UIImage(named: "tabIcon-\(rawValue)")
    }

    var selectedTabImage: UIImage? {
        if #available(iOS 26.0, *) { return UIImage(named: "tabIcon2-\(rawValue)") }

        return UIImage(named: "selectedTabIcon-\(rawValue)")
    }
}

final class MainTabBarController: UIViewController, Themeable {
    lazy var home = MainNavigationController(rootViewController: HomeFeedViewController(), hideNavigationBar: true)
    lazy var reads = MainNavigationController(rootViewController: ReadsViewController(), hideNavigationBar: true)
    lazy var wallet = MainNavigationController(rootViewController: WalletHomeViewController(), hideNavigationBar: true)
    lazy var notifications = MainNavigationController(rootViewController: NotificationsViewController(), hideNavigationBar: true)
    lazy var explore = MainNavigationController(rootViewController: ExploreViewController(), hideNavigationBar: true)

    let vcParentView = UIView()
    let noConnectionView = NoConnectionView().constrainToSize(height: 44)
    let remoteSignerView = RemoteSignerPillView().constrainToSize(height: 44)
    lazy var indicatorStack = UIStackView(axis: .vertical, [noConnectionView, remoteSignerView])
    
    lazy var buttons = tabs.map { _ in UIButton() }

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
    
    var childSafeAreaInsets = UIEdgeInsets.zero { didSet { children.forEach { $0.additionalSafeAreaInsets = childSafeAreaInsets } } }
    
    @Published var oldRemoteSignerPopup: RemoteSignerPendingEventsController?
    
    private let tabs: [MainTab] = [.home, .reads, .wallet, .notifications, .explore]
    
    private var nativeTabBar: UITabBar?
    private var collapsedTabBarButton: UIButton?

    var tabBarContainerView: UIView {
        if #available(iOS 26.0, *), let nativeTabBar { return nativeTabBar }
        return vStack
    }

    var continousConnection: ContinuousConnection?
    var deeplinkCancellable: AnyCancellable?
    
    let chatManager = ChatManager()
    
    private var notificationsFrozen = false

    var newNotifications: Int = 0 {
        didSet {
            if notificationsFrozen || newNotifications == oldValue { return }

            if #available(iOS 26.0, *), nativeTabBar != nil {
                updateNativeNotificationsTabItemImage()
                return
            }
            updateNotificationsTabButtonImage()
        }
    }

    var currentPageIndex = WalletSettings.startInWallet ? 2 : 0 {
        didSet {
            updateButtons()
        }
    }
    
    var currentTab: MainTab { tabs[safe: currentPageIndex] ?? .home }
    
    var showTabBarBorder: Bool {
        get {
            if #available(iOS 26.0, *), nativeTabBar != nil { return true }
            return navigationBorder.alpha > 0.1
        }
        set {
            if #available(iOS 26.0, *), nativeTabBar != nil { return }
            navigationBorder.alpha = newValue ? 1 : 0
            circleBorderView.alpha = newValue ? 1 : 0
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
        
        chatManager.updateChatCount()
    }
    
    deinit {
        continousConnection?.end()
    }
    
    var runOnce = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard runOnce else { return }
        runOnce = false
        let userId = IdentityManager.instance.userHexPubkey
        let migratePublisher = WalletManager.instance.$activeWallet
            .filter({ $0?.wallet is Wallet.Primal && $0?.userId == userId })
            .map { _ in MigrateWalletPopupController() as UIViewController }

        let detectedPublisher = WalletManager.instance.$walletSetupState
            .filter({ $0 != .normal && IdentityManager.instance.userHexPubkey == userId })
            .map { WalletDetectedPopupController(isDiscontinued: $0 == .walletDiscontinued) as UIViewController }

        migratePublisher.merge(with: detectedPublisher)
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] popup in
                self?.smartPresent(popup)
            }
            .store(in: &cancellables)
    }


    var updateChildren = false
    func updateTheme() {
        view.backgroundColor = .background

        if #available(iOS 26.0, *), let nativeTabBar {
            nativeTabBar.tintColor = .foreground
            nativeTabBar.unselectedItemTintColor = .foreground.withAlphaComponent(0.75)
            updateNativeNotificationsTabItemImage()
        }

        updateButtons()

        if updateChildren {
            [home, reads, wallet, notifications, explore].forEach {
                $0.updateThemeIfThemeable()
            }
        }

        navigationBorder.backgroundColor = .background3
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        let currentNav = navForTab(currentTab)
        let collapsed = currentNav.viewControllers.count == 1
        
        if #available(iOS 26.0, *), collapsed {
            if hidden {
                let rootVC = currentNav.viewControllers.first as? MainTabBarRootViewController
                let title = rootVC?.collapsedTabBarTitle ?? currentTab.tabTitle
                setTabBarCollapsed(text: title, icon: currentTab.tabImage, animated: animated)
            } else {
                setTabBarExpanded(animated: animated)
            }
            return
        }
    
        removeCollapsedTabBar(animated: animated)
        
        let targetView = tabBarContainerView
        
        if !animated {
            targetView.transform = hidden ? .init(translationX: 0, y: targetView.bounds.height + 10) : .identity
            return
        }

        UIView.animate(withDuration: 0.3) {
            targetView.transform = hidden ? .init(translationX: 0, y: targetView.bounds.height + 10) : .identity
        }
    }
    
    @available(iOS 26.0, *)
    func setTabBarCollapsed(text: String, icon: UIImage?, animated: Bool = true) {
        let button: CollapsedTabBarButton
        if let existing = collapsedTabBarButton as? CollapsedTabBarButton {
            button = existing
        } else {
            button = CollapsedTabBarButton()
            button.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                let nav = navForTab(currentTab)
                if let noteVC: NoteViewController = nav.topViewController?.findInChildren() ?? nav.topViewController as? NoteViewController {
                    noteVC.table.setContentOffset(noteVC.table.contentOffset, animated: false)
                    noteVC.updateBarsHidden(false)
                } else {
                    setTabBarExpanded(animated: true)
                }
            }), for: .touchUpInside)
            view.addSubview(button)
            button.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: 21)
            collapsedTabBarButton = button
        }

        button.configure(text: text, icon: icon)
        button.alpha = 0
        button.transform = .init(scaleX: 0.2, y: 0.2)

        let showCollapsed = {
            button.alpha = 1
            button.transform = .identity
        }
        let hideTabBar = { [self] in
            tabBarContainerView.alpha = 0
            tabBarContainerView.transform = .init(scaleX: 0.2, y: 0.2)
                .concatenating(.init(translationX: 0, y: tabBarContainerView.bounds.height / 4))
        }

        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
                hideTabBar()
                showCollapsed()
            }
        } else {
            hideTabBar()
            showCollapsed()
        }
    }

    
    func removeCollapsedTabBar(animated: Bool = true) {
        guard let collapsedTabBarButton else { return }
        self.collapsedTabBarButton = nil
        
        let hideCollapsed = {
            collapsedTabBarButton.alpha = 0
            collapsedTabBarButton.transform = .init(scaleX: 0.2, y: 0.2)
        }

        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
                hideCollapsed()
            } completion: { _ in
                collapsedTabBarButton.removeFromSuperview()
            }
        } else {
            hideCollapsed()
            collapsedTabBarButton.removeFromSuperview()
        }
    }
    
    func setTabBarExpanded(animated: Bool = true) {
        removeCollapsedTabBar(animated: animated)
        
        let showTabBar = { [self] in
            tabBarContainerView.alpha = 1
            tabBarContainerView.transform = .identity
        }
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
                showTabBar()
            }
        } else {
            showTabBar()
        }
    }

    func freezeNotificationCount() {
        notificationsFrozen = true
        if #available(iOS 26.0, *), nativeTabBar != nil {
            updateNativeNotificationsTabItemImage(showingDot: false)
        } else {
            updateNotificationsTabButtonImage(showingDot: false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self else { return }
            notificationsFrozen = false
            if #available(iOS 26.0, *), nativeTabBar != nil {
                updateNativeNotificationsTabItemImage()
            } else {
                updateNotificationsTabButtonImage()
            }
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
        let bar = tabBarContainerView
        let isTabBarHidden = bar.transform != .identity

        if isTabBarHidden {
            view.showToast(message, icon: icon, extraPadding: 0)
        } else {
            bar.showToast(message, icon: icon, extraPadding: 95)
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
        
        nav.additionalSafeAreaInsets = childSafeAreaInsets
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
        
        if let userDefaults = UserDefaults(suiteName: "group.primal") {
            userDefaults.set(IdentityManager.instance.userHexPubkey, forKey: "currentUserPubkey")
            userDefaults.synchronize()
        }
        
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
        
        if #available(iOS 26.0, *) {
            setupNativeTabBar()
        } else {
            setupCustomTabBar()
        }

        indicatorStack.spacing = 8
        indicatorStack.isUserInteractionEnabled = false
        view.addSubview(indicatorStack)
        indicatorStack
            .pinToSuperview(edges: .horizontal, padding: 12)
            .pinToSuperview(edges: .top, padding: 60, safeArea: true)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .dropFirst()
            .sink { _ in
                PrimalEndpointsManager.instance.checkIfNecessary()
                Connection.reconnect()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    RelaysPostbox.instance.reconnect()
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
        
        let remoteSignerButton = UIButton().constrainToSize(36)
        remoteSignerButton.isHidden = true
        view.addSubview(remoteSignerButton)
        remoteSignerButton.centerToView(remoteSignerView.iconView)
        remoteSignerButton.addAction(.init(handler: { [weak self] _ in
            self?.smartPresent(RemoteSignerRootController(.activeSessions))
        }), for: .touchUpInside)
        
        Publishers.CombineLatest(
            RemoteSignerManager.instance.pendingActionsPublisher.receive(on: DispatchQueue.main),
            $oldRemoteSignerPopup
        )
        .sink { [weak self] events, oldPopup in
            guard let self else { return }
            
            let groups = events.groupByFilter { $0.sessionId }
            
            if let oldPopup, oldPopup.presentingViewController != nil || oldPopup.presentedViewController != nil {
                if let events = groups[oldPopup.sessionId] {
                    oldPopup.allEvents = events
                    return
                }
                
                oldPopup.dismiss(animated: true)
            }
            
            guard let first = groups.first else {
                oldRemoteSignerPopup = nil
                return
            }
            
            let new = RemoteSignerPendingEventsController(sessionId: first.key, events: first.value)
            smartPresent(RemoteSignerRootController(.custom(new)))
            oldRemoteSignerPopup = new
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(RemoteSignerManager.instance.isActivePublisher, NwcServiceManager.shared.isServiceActivePublisher)
            .map { $0 || $1 }
            .sink { [weak self] isActive in
                self?.remoteSignerView.isOff = !isActive
                remoteSignerButton.isHidden = !isActive
                
                UIApplication.shared.isIdleTimerDisabled = isActive
            }
            .store(in: &cancellables)
        
        if #available(iOS 16.1, *) {
            NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
                .sink { _ in
                    guard
                        RemoteSignerManager.instance.isActive || NwcServiceManager.shared.isServiceActive,
                        VideoPlaybackManager.instance.autoPlay
                    else { return }
                    
                    RemoteSignerActivityManager.instance.playSong()
                }
                .store(in: &cancellables)
        }
        
        let didEnterForegroundPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).map({ _ in true })
        let delay5SecondsForegroundPublisher = didEnterForegroundPublisher.delay(for: .seconds(5), scheduler: RunLoop.main).map({ _ in false })
        let didJustEnterForegroundPublisher = Publishers.Merge(didEnterForegroundPublisher, delay5SecondsForegroundPublisher)
        
        Publishers.CombineLatest(
            didJustEnterForegroundPublisher.prepend(false),
            Connection.regular.cantConnectPublisher.removeDuplicates()
        ).receive(on: DispatchQueue.main).sink { [weak self] didJustEnterForeground, cantConnect in
            self?.noConnectionView.hasConnection = didJustEnterForeground || !cantConnect
        }
        .store(in: &cancellables)
        
        DispatchQueue.main.async { [self] in
            RootViewController.instance.$navigateTo
                .filter { $0 != nil }
                .delay(for: 0.5, scheduler: RunLoop.main)
                .sink { [weak self] to in
                    guard let self, let to else { return }
                    RootViewController.instance.navigateTo = nil
                    
                    let (vc, tab): (UIViewController?, MainTab?) = {
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
                            let newPost = AdvancedEmbedPostViewController()
                            newPost.manager.textView.text = text
                            newPost.manager.addMedia(files)
                            return (newPost, nil)
                        case .live(let live):
                            return (LiveVideoPlayerController(live: live), nil)
                        case .url(let url):
                            return (SFSafariViewController(url: url), nil)
                        }
                    }()
                    
                    let presentLogic = {
                        if let tab {
                            self.switchToTab(tab, open: vc)
                            if vc == nil {
                                self.navForTab(tab).popToRootViewController(animated: true)
                            }
                        } else if let vc {
                            self.present(vc, animated: true)
                        }
                    }
                    
                    if let presentedViewController {
                        presentedViewController.dismiss(animated: true) {
                            presentLogic()
                        }
                    } else {
                        presentLogic()
                    }
                }
                .store(in: &cancellables)
        }
        
        updateButtons()

        view.addSubview(animationView)
        animationView.isHidden = true
        animationView.isUserInteractionEnabled = false

        if #available(iOS 26.0, *), let nativeTabBar {
            animationView.constrainToSize(width: 375, height: 100).centerToView(nativeTabBar)
        } else {
            addCircleWalletButton()
            animationView.constrainToSize(width: 375, height: 100).centerToView(circleWalletButton)

            zip(buttons, tabs).forEach { button, tab in
                button.addAction(.init(handler: { [weak self] _ in
                    self?.menuButtonPressedForTab(tab)
                }), for: .touchUpInside)
            }
        }
        
        Connection.regular.continuousConnectionCancellable(name: "live_events_from_follows", request: ["user_pubkey": .string(IdentityManager.instance.userHexPubkey)]) { event in
            LiveEventManager.instance.addLiveEvent(event)
        }
        .store(in: &cancellables)

        LiveEventManager.instance.startPeriodicRefresh()
    }
    
    static let tabBarHeight: CGFloat = {
        switch ChromeSize.current {
        case .small:    return 54
        case .regular:  return 60
        case .medium:   return 60
        case .large:    return 64
        }
    }()

    private static let tabBarFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small:    return 9
        case .regular:  return 10
        case .medium:   return 10
        case .large:    return 11
        }
    }()

    @available(iOS 26.0, *)
    private func nativeTabBarImage(_ image: UIImage?) -> UIImage? {
        image?.scalePreservingAspectRatio(size: NotificationsTabIconComposer.iconSize)
            .withRenderingMode(.alwaysTemplate)
            .withAlignmentRectInsets(.init(
                top: NotificationsTabIconComposer.nativeTabBarImageYOffset,
                left: 0,
                bottom: -NotificationsTabIconComposer.nativeTabBarImageYOffset,
                right: 0))
    }

    @available(iOS 26.0, *)
    func setupNativeTabBar() {
        let tabBar = UITabBar()
        tabBar.delegate = self
        tabBar.items = tabs.enumerated().map { index, tab in
            let isNotifications = tab == .notifications
            let showingDot = isNotifications && newNotifications > 0
            let image: UIImage?
            let selectedImage: UIImage?
            if showingDot {
                image = NotificationsTabIconComposer.composedIcon(
                    tint: .foreground, forNativeBar: true)
                selectedImage = NotificationsTabIconComposer.composedIcon(
                    tint: .foreground, forNativeBar: true)
            } else {
                image = nativeTabBarImage(tab.tabImage)
                selectedImage = nativeTabBarImage(tab.selectedTabImage)
            }
            let item = UITabBarItem(title: tab.tabTitle, image: image, tag: index)
            item.selectedImage = selectedImage
            return item
        }
        tabBar.selectedItem = tabBar.items?[safe: currentPageIndex]
        tabBar.tintColor = .foreground
        tabBar.unselectedItemTintColor = .foreground.withAlphaComponent(0.75)

        let fontSize = Self.tabBarFontSize
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(withSize: fontSize, weight: .regular),
            .foregroundColor: UIColor.foreground.withAlphaComponent(0.75)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(withSize: fontSize, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]
        
        let offset: CGFloat = {
            switch ChromeSize.current {
            case .small:    return 3
            case .regular:  return 2
            case .medium:   return 2
            case .large:    return 1
            }
        }()
        
        let titleOffset = UIOffset(horizontal: 0, vertical: offset)
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = titleOffset
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = titleOffset
        tabBar.standardAppearance = appearance

        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 13 - Self.tabBarHeight),
        ])

        nativeTabBar = tabBar
    }

    @available(iOS 26.0, *)
    private func updateNativeNotificationsTabItemImage(showingDot: Bool? = nil) {
        guard let tabBar = nativeTabBar,
              let item = tabBar.items?[safe: 3] else { return }
        let dotVisible = showingDot ?? (newNotifications > 0)
        if dotVisible {
            item.image = NotificationsTabIconComposer.composedIcon(
                tint: .foreground, forNativeBar: true)
            item.selectedImage = NotificationsTabIconComposer.composedIcon(
                tint: .foreground, forNativeBar: true)
        } else {
            item.image = nativeTabBarImage(MainTab.notifications.tabImage)
            item.selectedImage = nativeTabBarImage(MainTab.notifications.selectedTabImage)
        }
    }


    func setupCustomTabBar() {
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

        vStack.axis = .vertical
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
        if #available(iOS 26.0, *), let nativeTabBar {
            nativeTabBar.selectedItem = nativeTabBar.items?[safe: currentPageIndex]
            return
        }
        circleWalletButton.updateTheme()
        for (index, button) in buttons.enumerated() {
            button.tintColor = index == currentPageIndex ? .foreground : .foreground3

            let tab = tabs[index]
            let selected = index == currentPageIndex
            let image: UIImage? = (tab == .notifications)
                ? imageForNotificationsTab(selected: selected, showingDot: newNotifications > 0)
                : (selected ? tab.selectedTabImage : tab.tabImage)
            button.setImage(image, for: .normal)
        }
    }

    private func imageForNotificationsTab(selected: Bool, showingDot: Bool) -> UIImage? {
        if showingDot {
            return NotificationsTabIconComposer.composedIcon(
                tint: selected ? .foreground : .foreground3, forNativeBar: false)
        }
        return selected ? MainTab.notifications.selectedTabImage : MainTab.notifications.tabImage
    }

    private func updateNotificationsTabButtonImage(showingDot: Bool? = nil) {
        guard let index = tabs.firstIndex(of: .notifications),
              let button = buttons[safe: index] else { return }
        let dotVisible = showingDot ?? (newNotifications > 0)
        button.setImage(
            imageForNotificationsTab(selected: index == currentPageIndex, showingDot: dotVisible),
            for: .normal
        )
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

extension MainTabBarController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        menuButtonPressedForTab(tabs[item.tag])
    }
}

final class NumberedNotificationIndicator: UIView, Themeable {
    var number: Int {
        didSet {
            update()
        }
    }
    
    var color: () -> UIColor = { .accent } {
        didSet {
            updateTheme()
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
        backgroundColor = color()
    }
}

