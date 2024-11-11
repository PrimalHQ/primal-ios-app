//
//  MenuHelper.swift
//  InteractiveSlideoutMenu
//
//  Created by Robert Chen on 2/7/16.
//  Copyright © 2016 Thorn Technologies, LLC. All rights reserved.
//

import Combine
import Foundation
import UIKit
import Kingfisher
import FLAnimatedImage

extension String { // TODO: Remove in 2025
    static let cachedUsersDefaultsKey = "cachedUsersDefaultsKey"
}

final class MenuContainerController: UIViewController, Themeable {
    private let profileImage = FLAnimatedImageView().constrainToSize(52)
    private let nameLabel = UILabel()
    private let checkbox1 = VerifiedView()
    private let domainLabel = UILabel()
    private let followingLabel = UILabel()
    private let followersLabel = UILabel()
    private let mainStack = UIStackView()
    private let coverView = UIView()
    private let menuProfileImage = FLAnimatedImageView()
    
    private let notificationIndicator = NumberedNotificationIndicator()
    
    private let profileImageButton = UIButton()
    private let followingDescLabel = UILabel()
    private let followersDescLabel = UILabel()
    private let themeButton = UIButton()
    
    var newMessageCount = 0 {
        didSet {
            notificationIndicator.number = newMessageCount
        }
    }
    
    override var navigationItem: UINavigationItem {
        get { child.navigationItem }
    }
    
    private var childLeftConstraint: NSLayoutConstraint?
    private var cancellables: Set<AnyCancellable> = []
    
    private(set) var isOpen = false
    
    let child: UIViewController
    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        close()
    }
    
    func animateOpen() {
        open()
        
        // Many ViewControllers modify the navigationBar during scrolling, so we will kill all active scrolling to stop them from messing with our navigationBar
        let scrollViews: [UIScrollView] = child.view.findAllSubviews()
        scrollViews.forEach { $0.setContentOffset($0.contentOffset, animated: false) }
                
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.child.view.transform = .identity
            self.coverView.transform = .identity
            self.mainStack.transform = .identity
            self.notificationIndicator.transform = .identity
            self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: self.view.frame.width - 68, y: 0)
            
            self.coverView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func animateClose(completion: (() -> Void)? = nil) {
        close()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.child.view.transform = .identity
            self.coverView.transform = .identity
            self.mainStack.transform = CGAffineTransform(translationX: -300, y: 0)
            self.notificationIndicator.transform = CGAffineTransform(translationX: -300, y: 0)
            self.navigationController?.navigationBar.transform = .identity
            
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    func open() {
        isOpen = true
        mainStack.alpha = 1
        
        childLeftConstraint?.isActive = true
        coverView.isHidden = false
        mainTabBarController?.hideForMenu()
        child.beginAppearanceTransition(false, animated: true)
    }
    
    func resetNavigationTabBar() {
        mainTabBarController?.showButtons()
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.navigationBar.transform = .identity
        }
    }
    
    func close() {
        isOpen = false
        childLeftConstraint?.isActive = false
        coverView.alpha = 0
        coverView.isHidden = true
        mainTabBarController?.showButtons()
        child.endAppearanceTransition()
    }
    
    var updateForChild = false
    func updateTheme() {
        view.backgroundColor = .background
        
        themeButton.setImage(Theme.current.menuButtonImage, for: .normal)
        
        nameLabel.textColor = .foreground
        
        profileImageButton.backgroundColor = .background.withAlphaComponent(0.01)
        
        coverView.backgroundColor = .background.withAlphaComponent(0.5)
        
        [domainLabel, followersDescLabel, followingDescLabel, followersLabel, followingLabel].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
            $0.textColor = .foreground5
        }
        [followersLabel, followingLabel].forEach { $0.textColor = .extraColorMenu }
        
        if updateForChild {
            child.updateThemeIfThemeable()
        }
    }
}

private extension MenuContainerController {
    func setup() {
        updateTheme()
        updateForChild = true
        
        let profileImageRow = UIStackView([profileImage, UIView()])
        
        let barcodeButton = UIButton()
        barcodeButton.setImage(UIImage(named: "barcode"), for: .normal)
        let titleStack = UIStackView(arrangedSubviews: [nameLabel, checkbox1, barcodeButton])
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followingDescLabel, followersLabel, followersDescLabel])
        
        let profile = MenuItemButton(title: "PROFILE")
        let premium = MenuItemButton(title: "PREMIUM")
        let messages = MenuItemButton(title: "MESSAGES")
        let bookmarks = MenuItemButton(title: "BOOKMARKS")
        let settings = MenuItemButton(title: "SETTINGS")
        let signOut = MenuItemButton(title: "SIGN OUT")
        
        let buttonsStack = UIStackView(arrangedSubviews: [profile, premium, messages, bookmarks, settings, signOut])
        [
            profileImageRow, titleStack, domainLabel, followStack,
            buttonsStack, UIView(), themeButton
        ]
        .forEach { mainStack.addArrangedSubview($0) }
        
        profileImageRow.pinToSuperview(edges: .horizontal)
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading, padding: 36)
            .pinToSuperview(edges: .trailing, padding: 80)
            .pinToSuperview(edges: .top, padding: 70)
            .pinToSuperview(edges: .bottom, padding: 80, safeArea: true)
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(15, after: profileImageRow)
        mainStack.setCustomSpacing(18, after: titleStack)
        mainStack.setCustomSpacing(10, after: domainLabel)
        mainStack.setCustomSpacing(44, after: followStack)
        mainStack.alpha = 0
        
        view.addSubview(notificationIndicator)
        notificationIndicator.pin(to: messages, edges: .top, padding: 4).pinToSuperview(edges: .leading, padding: 138)
        
        buttonsStack.axis = .vertical
        buttonsStack.alignment = .leading
        buttonsStack.spacing = 16
        
        titleStack.alignment = .center
        titleStack.spacing = 4
        titleStack.setCustomSpacing(12, after: checkbox1)
        
        checkbox1.transform = .init(scaleX: 1.15, y: 1.15)
        
        followersDescLabel.text = "Followers"
        followingDescLabel.text = "Following"
        followStack.spacing = 4
        followStack.setCustomSpacing(16, after: followingDescLabel)
        
        let npubs = LoginManager.instance.loggedInNpubs()

        for npub in npubs.dropFirst().prefix(3) {
            let avatarImage = FLAnimatedImageView().constrainToSize(24)
            avatarImage.isUserInteractionEnabled = true
            avatarImage.layer.cornerRadius = 12
            avatarImage.clipsToBounds = true
            avatarImage.contentMode = .scaleAspectFill

            LoginManager.instance.$loadedProfiles.receive(on: DispatchQueue.main)
                .sink { users in
                    if avatarImage.image == nil, let user = users.first(where: { $0.data.npub == npub }) {
                        avatarImage.setUserImage(user)
                    }
                }
                .store(in: &cancellables)

            profileImageRow.addArrangedSubview(SpacerView(width: 18))
            profileImageRow.addArrangedSubview(avatarImage)

            let button = UIView().constrainToSize(36)
            button.backgroundColor = .black.withAlphaComponent(0.01)
            view.addSubview(button)
            button.centerToView(avatarImage)
            button.addGestureRecognizer(BindableTapGestureRecognizer(action: {
                _ = LoginManager.instance.loginReset(npub)
            }))
        }
        
        addChild(child)
        view.addSubview(child.view)
        child.view.pinToSuperview(edges: .vertical)
        child.didMove(toParent: self)
        
        let drag = UIPanGestureRecognizer(target: self, action: #selector(childPanned))
        child.view.addGestureRecognizer(drag)
        
        let leading = child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leading.priority = .defaultHigh

        NSLayoutConstraint.activate([
            leading,
            child.view.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        childLeftConstraint = child.view.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -68)
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 26
        profileImage.layer.masksToBounds = true
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        
        let menuButtonParent = UIView()
        profileImageButton.addTarget(self, action: #selector(toggleMenuTapped), for: .touchUpInside)
        menuProfileImage.layer.cornerRadius = 16
        menuProfileImage.layer.masksToBounds = true
        menuProfileImage.isUserInteractionEnabled = false
        menuProfileImage.contentMode = .scaleAspectFill
        
        menuButtonParent.addSubview(profileImageButton)
        profileImageButton.constrainToSize(44).pinToSuperview()
        menuButtonParent.addSubview(menuProfileImage)
        menuProfileImage.constrainToSize(32).centerToSuperview(axis: .vertical).pinToSuperview(edges: .leading)
        child.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButtonParent)
        
        view.addSubview(coverView)
        coverView.pin(to: child.view)
        coverView.isHidden = true
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenuTapped)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeMenuTapped))
        swipe.direction = .left
        coverView.addGestureRecognizer(swipe)

        profileImageRow.alignment = .center

        let manageAccountsButton = ThemeableButton().setTheme {
            $0.configuration = .simpleImage(UIImage(named: npubs.count < 2 ? "addAccount" : "moreAccounts"))
            $0.tintColor = .foreground2
        }
        profileImageRow.addArrangedSubview(manageAccountsButton)
        
        manageAccountsButton.addAction(.init(handler: { [weak self] _ in
            self?.present(PopupAccountSwitchingController(), animated: true)
        }), for: .touchUpInside)
        
        barcodeButton.addAction(.init(handler: { [unowned self] _ in showViewController(ProfileQRController()) }), for: .touchUpInside)
        messages.addAction(.init(handler: { [unowned self] _ in showViewController(MessagesViewController()) }), for: .touchUpInside)
        bookmarks.addAction(.init(handler: { [unowned self] _ in showViewController(PublicBookmarksViewController()) }), for: .touchUpInside)
        premium.addAction(.init(handler: { [unowned self] _ in showViewController(PremiumViewController()) }), for: .touchUpInside)
        
        profile.addTarget(self, action: #selector(profilePressed), for: .touchUpInside)
        settings.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        signOut.addTarget(self, action: #selector(signoutPressed), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(themeButtonPressed), for: .touchUpInside)
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePressed)))
        profileImage.isUserInteractionEnabled = true
        
        IdentityManager.instance.$parsedUser.compactMap({ $0 }).receive(on: DispatchQueue.main).sink { [weak self] user in
            self?.update(user)
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.$userStats.receive(on: DispatchQueue.main).sink { [weak self] stats in
            guard let stats, let self else { return }
            
            self.followersLabel.text = stats.followers.localized()
            self.followingLabel.text = stats.follows.localized()
        }
        .store(in: &cancellables)
    }
    
    func update(_ user: ParsedUser) {
        profileImage.setUserImage(user)
        menuProfileImage.setUserImage(user)
        
        let user = user.data
        if user.displayName.isEmpty {
            if CheckNip05Manager.instance.isVerified(user) {
                nameLabel.text = user.parsedNip
            } else {
                nameLabel.text = user.name
            }
            domainLabel.isHidden = true
        } else {
            nameLabel.text = user.displayName
            if CheckNip05Manager.instance.isVerified(user) {
                domainLabel.text = user.parsedNip
            } else {
                domainLabel.text = user.name
            }
            domainLabel.isHidden = false
        }
        
        checkbox1.isHidden = user.nip05.isEmpty
        checkbox1.isExtraVerified = user.nip05.hasSuffix("@primal.net")
    }
    
    // MARK: - Objc methods
    @objc func profilePressed() {
        guard let profile = IdentityManager.instance.parsedUser else {
            IdentityManager.instance.requestUserProfile()
            return
        }
        showViewController(ProfileViewController(profile: profile))
    }
    
    @objc func settingsButtonPressed() {
        showViewController(SettingsMainViewController())
    }
    
    func showViewController(_ viewController: UIViewController) {
        show(viewController, sender: nil)
        resetNavigationTabBar()
    }
    
    @objc func themeButtonPressed() {
        ContentDisplaySettings.autoDarkMode = false
        switch Theme.current.kind {
        case .sunriseWave:
            Theme.defaultTheme = SunsetWave.instance
        case .sunsetWave:
            Theme.defaultTheme = SunriseWave.instance
        case .midnightWave:
            Theme.defaultTheme = IceWave.instance
        case .iceWave:
            Theme.defaultTheme = MidnightWave.instance
        }
    }
    
    @objc func signoutPressed() {
        let alert = UIAlertController(title: "Are you sure you want to sign out?", message: "If you didn't save your private key, it will be irretrievably lost", preferredStyle: .alert)
        alert.addAction(.init(title: "Sign out", style: .destructive) { _ in
            LoginManager.instance.logout()
        })
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func toggleMenuTapped() {
        if childLeftConstraint?.isActive == true {
            animateClose()
        } else {
            animateOpen()
        }
    }
    
    @objc func openMenuTapped() {
        animateOpen()
    }
    
    @objc func closeMenuTapped() {
        animateClose()
    }
    
    @objc func childPanned(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            coverView.isHidden = false
            child.beginAppearanceTransition(false, animated: true)
            (child as? NoteViewController)?.animateBarsToVisible()
            fallthrough
        case .changed:
            mainStack.alpha = 1
            let translation = sender.translation(in: self.view)
            
            let percent = (translation.x / 300).clamp(0, 1)
            let xTrans = (1 - percent) * -300
            
            coverView.alpha = percent
            mainStack.transform = .init(translationX: xTrans, y: 0)
            notificationIndicator.transform = .init(translationX: xTrans, y: 0)
            [child.view, navigationController?.navigationBar, coverView].forEach {
                $0?.transform = CGAffineTransform(translationX: max(0, translation.x), y: 0)
            }
        case .possible:
            break
        case .ended:
            let translation = sender.translation(in: self.view)
            let velocity = sender.velocity(in: self.view)
            if translation.x > 50, velocity.x > -0.1 {
                animateOpen()
            } else {
                animateClose()
            }
        case .cancelled, .failed:
            animateClose()
        @unknown default:
            break
        }
    }
}

final class MenuItemButton: UIButton, Themeable {
    init(title: String) {
        super.init(frame: .zero)
        
        setAttributedTitle(.init(string: title, attributes: [
            .font: UIFont.appFont(withSize: 18.2, weight: .regular),
            .kern: 0.2
        ]), for: .normal)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        setTitleColor(.foreground2, for: .normal)
        setTitleColor(.foreground2.withAlphaComponent(0.5), for: .disabled)
        setTitleColor(.foreground2.withAlphaComponent(0.5), for: .highlighted)
    }
}
