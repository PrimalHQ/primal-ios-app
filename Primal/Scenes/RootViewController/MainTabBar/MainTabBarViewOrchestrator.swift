//
//  MainTabBarViewOrchestrator.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.4.26..
//

import UIKit
import Lottie

final class MainTabBarViewOrchestrator: NSObject, Themeable {
    weak var controller: MainTabBarController?

    lazy var buttons: [UIButton] = tabs.map { _ in UIButton() }

    let buttonStackParent = UIView()
    private(set) lazy var vStack = UIStackView(arrangedSubviews: [navigationBorder, buttonStackParent, safeAreaSpacer])
    private let safeAreaSpacer = UIView()
    private let circleBorderView = ThemeableView().constrainToSize(64).setTheme {
        $0.backgroundColor = .background
        $0.layer.borderColor = UIColor.background3.cgColor
    }
    private let navigationBorder = UIView().constrainToSize(height: 1)
    private lazy var circleWalletButton = ThemeableButton().constrainToSize(52).setTheme { [weak self] in
        let isWalletSelected = (self?.controller?.currentPageIndex ?? 0) == 2

        $0.backgroundColor = isWalletSelected ? .foreground : .background3
        $0.tintColor = isWalletSelected ? .background : .foreground3

        $0.setImage(isWalletSelected ? UIImage(named: "walletSpecialButtonPressed") : UIImage(named: "walletSpecialButton"), for: .normal)
    }

    private var animationView = LottieAnimationView(animation: AnimationType.walletLightning.animation)

    lazy var buttonStack = UIStackView(arrangedSubviews: buttons)

    private var nativeTabBar: UITabBar?
    private var collapsedTabBarButton: UIButton?

    private var notificationsFrozen = false

    var isExcited: Bool = false

    private var tabs: [MainTab] { controller?.tabs ?? [] }

    var tabBarContainerView: UIView {
        if #available(iOS 26.0, *), let nativeTabBar { return nativeTabBar }
        return vStack
    }

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

    init(controller: MainTabBarController) {
        self.controller = controller
        super.init()
    }

    func setup() {
        guard let controller else { return }

        if #available(iOS 26.0, *) {
            setupNativeTabBar()
        } else {
            setupCustomTabBar()
        }

        controller.view.addSubview(animationView)
        animationView.isHidden = true
        animationView.isUserInteractionEnabled = false

        if #available(iOS 26.0, *), let nativeTabBar {
            animationView.constrainToSize(width: 375, height: 100).centerToView(nativeTabBar)
        } else {
            addCircleWalletButton()
            animationView.constrainToSize(width: 375, height: 100).centerToView(circleWalletButton)

            zip(buttons, tabs).forEach { button, tab in
                button.addAction(.init(handler: { [weak self] _ in
                    self?.controller?.menuButtonPressedForTab(tab)
                }), for: .touchUpInside)
            }
        }

        updateButtons()
    }

    func updateTheme() {
        if #available(iOS 26.0, *), let nativeTabBar {
            nativeTabBar.tintColor = .foreground
            nativeTabBar.unselectedItemTintColor = .foreground.withAlphaComponent(0.75)
            updateNativeNotificationsTabItemImage()
        }

        updateButtons()

        navigationBorder.backgroundColor = .background3
    }

    func targetTransformForTabBarState(hidden: Bool, excited: Bool) -> CGAffineTransform {
        var t = CGAffineTransform.identity
        if hidden {
            let translation = tabBarContainerView.bounds.height + 10
            t = t.concatenating(CGAffineTransform(translationX: 0, y: translation))
        }
        if excited, #available(iOS 26.0, *) {
            t = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        return t
    }

    func setIsExcited(_ excited: Bool) {
        guard excited != isExcited else { return }
        isExcited = excited

        let currentlyHidden = tabBarContainerView.transform.ty != 0

        if currentlyHidden {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.collapsedTabBarButton?.transform = excited ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
            }
            return
        }

        let target = targetTransformForTabBarState(hidden: currentlyHidden, excited: excited)
        let apply = { self.tabBarContainerView.transform = target }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: apply)
    }

    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard let controller else { return }
        let currentNav = controller.navForTab(controller.currentTab)
        let collapsed = currentNav.viewControllers.count == 1

        if #available(iOS 26.0, *), collapsed {
            if hidden {
                let rootVC = currentNav.viewControllers.first as? MainTabBarRootViewController
                let title = rootVC?.collapsedTabBarTitle ?? controller.currentTab.tabTitle
                setTabBarCollapsed(text: title, icon: controller.currentTab.tabImage, animated: animated)
            } else {
                setTabBarExpanded(animated: animated)
            }
            return
        }

        removeCollapsedTabBar(animated: animated)

        let targetView = tabBarContainerView
        let newTransform = targetTransformForTabBarState(hidden: hidden, excited: isExcited)

        if !animated {
            targetView.transform = newTransform
            return
        }

        UIView.animate(withDuration: 0.3) {
            targetView.transform = newTransform
        }
    }

    @available(iOS 26.0, *)
    func setTabBarCollapsed(text: String, icon: UIImage?, animated: Bool = true) {
        guard let controller else { return }
        let button: CollapsedTabBarButton
        if let existing = collapsedTabBarButton as? CollapsedTabBarButton {
            button = existing
        } else {
            button = CollapsedTabBarButton()
            button.addAction(.init(handler: { [weak self] _ in
                guard let self, let controller = self.controller else { return }
                let nav = controller.navForTab(controller.currentTab)
                if let noteVC: NoteViewController = nav.topViewController?.findInChildren() ?? nav.topViewController as? NoteViewController {
                    noteVC.table.setContentOffset(noteVC.table.contentOffset, animated: false)
                    DispatchQueue.main.async {
                        noteVC.updateBarsHidden(false)
                    }
                } else {
                    setTabBarExpanded(animated: true)
                }
            }), for: .touchUpInside)
            controller.view.insertSubview(button, belowSubview: nativeTabBar ?? vStack)
            button.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: 21)
            collapsedTabBarButton = button
        }

        button.configure(text: text, icon: icon)
        button.alpha = 0
        button.transform = .init(scaleX: 4.5, y: 3)
        button.imageView?.transform = .init(scaleX: (1.0 / 4.5) * 0.5, y: (1.0 / 3) * 0.5)
        button.titleLabel?.transform = .init(scaleX: (1.0 / 4.5) * 0.5, y: (1.0 / 3) * 0.5)

        let showCollapsed = {
            button.alpha = 1
            button.transform = .identity
            button.imageView?.transform = .identity
            button.titleLabel?.transform = .identity
        }

        let hideTabBar1 = { [self] in
            tabBarContainerView.transform = .init(scaleX: 0.2, y: 0.2)
                .concatenating(.init(translationX: 0, y: 10))
        }
        let hideTabBar2 = { [self] in
            tabBarContainerView.alpha = 0
        }

        if animated {
            UIView.animate(withDuration: 0.3) {
                hideTabBar1()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                UIView.animate(withDuration: 0.1) {
                    hideTabBar2()
                }
            }

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
                showCollapsed()
            }
        } else {
            hideTabBar1()
            hideTabBar2()
            showCollapsed()
        }
    }

    func removeCollapsedTabBar(animated: Bool = true) {
        guard let collapsedTabBarButton else { return }
        self.collapsedTabBarButton = nil

        guard animated else {
            collapsedTabBarButton.removeFromSuperview()
            return
        }

        UIView.animate(withDuration: 0.05) {
            collapsedTabBarButton.imageView?.alpha = 0
            collapsedTabBarButton.titleLabel?.alpha = 0
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            collapsedTabBarButton.transform = .init(scaleX: 3, y: 1.7).translatedBy(x: 0, y: -7)
        } completion: { _ in
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
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
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

    func refreshNotificationsBadge() {
        guard !notificationsFrozen else { return }

        if #available(iOS 26.0, *), nativeTabBar != nil {
            updateNativeNotificationsTabItemImage()
            return
        }
        updateNotificationsTabButtonImage()
    }

    func showToast(_ message: String, icon: UIImage? = UIImage(named: "toastCheckmark")) {
        guard let controller else { return }
        let bar = tabBarContainerView
        let isTabBarHidden = bar.transform.ty != 0

        if isTabBarHidden {
            controller.view.showToast(message, icon: icon, extraPadding: 0)
        } else {
            bar.showToast(message, icon: icon, extraPadding: 95)
        }
    }

    func playThunderAnimation() {
        animationView.isHidden = false
        animationView.play(fromProgress: 0, toProgress: 1)
    }

    func updateButtons() {
        guard let controller else { return }

        if #available(iOS 26.0, *), let nativeTabBar {
            nativeTabBar.selectedItem = nativeTabBar.items?[safe: controller.currentPageIndex]
            return
        }
        circleWalletButton.updateTheme()
        for (index, button) in buttons.enumerated() {
            button.tintColor = index == controller.currentPageIndex ? .foreground : .foreground3

            let tab = tabs[index]
            let selected = index == controller.currentPageIndex
            let image: UIImage? = (tab == .notifications)
                ? imageForNotificationsTab(selected: selected, showingDot: controller.newNotifications > 0)
                : (selected ? tab.selectedTabImage : tab.tabImage)
            button.setImage(image, for: .normal)
        }
    }
}

private extension MainTabBarViewOrchestrator {
    static let tabBarHeight: CGFloat = {
        switch ChromeSize.current {
        case .small:    return 54
        case .regular:  return 60
        case .medium:   return 60
        case .large:    return 64
        }
    }()

    static let tabBarFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small:    return 9
        case .regular:  return 10
        case .medium:   return 10
        case .large:    return 11
        }
    }()

    @available(iOS 26.0, *)
    func nativeTabBarImage(_ image: UIImage?) -> UIImage? {
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
        guard let controller else { return }
        let tabBar = UITabBar()
        tabBar.delegate = self
        tabBar.items = tabs.enumerated().map { index, tab in
            let isNotifications = tab == .notifications
            let showingDot = isNotifications && controller.newNotifications > 0
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
        tabBar.selectedItem = tabBar.items?[safe: controller.currentPageIndex]
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

        controller.view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            tabBar.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor, constant: 13 - Self.tabBarHeight),
        ])

        nativeTabBar = tabBar
    }

    @available(iOS 26.0, *)
    func updateNativeNotificationsTabItemImage(showingDot: Bool? = nil) {
        guard let controller,
              let tabBar = nativeTabBar,
              let item = tabBar.items?[safe: 3] else { return }
        let dotVisible = showingDot ?? (controller.newNotifications > 0)
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
        guard let controller else { return }
        controller.view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.bottom, .horizontal])
        safeAreaSpacer.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

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
            self?.controller?.menuButtonPressedForTab(.wallet)
        }), for: .touchUpInside)
    }

    func imageForNotificationsTab(selected: Bool, showingDot: Bool) -> UIImage? {
        if showingDot {
            return NotificationsTabIconComposer.composedIcon(
                tint: selected ? .foreground : .foreground3, forNativeBar: false)
        }
        return selected ? MainTab.notifications.selectedTabImage : MainTab.notifications.tabImage
    }

    func updateNotificationsTabButtonImage(showingDot: Bool? = nil) {
        guard let controller,
              let index = tabs.firstIndex(of: .notifications),
              let button = buttons[safe: index] else { return }
        let dotVisible = showingDot ?? (controller.newNotifications > 0)
        button.setImage(
            imageForNotificationsTab(selected: index == controller.currentPageIndex, showingDot: dotVisible),
            for: .normal
        )
    }
}

extension MainTabBarViewOrchestrator: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let tab = tabs[safe: item.tag] else { return }
        controller?.menuButtonPressedForTab(tab)
    }
}
