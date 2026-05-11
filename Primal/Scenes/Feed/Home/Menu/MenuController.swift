//
//  MenuController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.26..
//

import Combine
import UIKit
import Kingfisher
import FLAnimatedImage

final class MenuController: UIViewController, Themeable, SearchBarButtonController {
    let primalNavigationBar = PrimalNavigationBar()
    let contentView = UIView()
    let navBarBackground = UIView()
    let searchBarButton = SearchBarButton()

    private var showsSearchBar = false

    private let nameLabel = UILabel()
    private let checkbox1 = VerifiedView()
    private let domainLabel = UILabel()
    private let followLabel = UILabel()
    private let mainStack = UIStackView()

    private let premiumIndicator = NumberedNotificationIndicator()
    private let messagesIndicator = NumberedNotificationIndicator()

    private let profileImageButton = UIButton()
    private let closeButton = UIButton(configuration: .accent18("Close"))

    private var lastUserStats: NostrUserProfileInfo?

    private var originalTitle = ""
    private var originalSubtitle = ""
    private var originalShowChevron = false

    private var cancellables: Set<AnyCancellable> = []

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func present(from vc: UIViewController) {
        if let navBarVC = vc.primalNavBarController {
            primalNavigationBar.title = navBarVC.primalNavigationBar.title
            primalNavigationBar.subtitle = navBarVC.primalNavigationBar.subtitle
            primalNavigationBar.showChevron = navBarVC.primalNavigationBar.showChevron
        }
        showsSearchBar = vc.searchBarButtonController != nil
        originalTitle = primalNavigationBar.title
        originalSubtitle = primalNavigationBar.subtitle
        originalShowChevron = primalNavigationBar.showChevron
        vc.present(self, animated: false) { [self] in
            animateIn()
        }
    }

    func updateTheme() {
        contentView.backgroundColor = .background5
        navBarBackground.backgroundColor = .background
        primalNavigationBar.updateTheme()

        nameLabel.textColor = .foreground

        domainLabel.font = .appFont(withSize: MenuSizes.nipLabelFontSize, weight: .regular)
        domainLabel.textColor = .foreground5

        updateFollowLabel()
    }

    private func updateFollowLabel() {
        let font = UIFont.appFont(withSize: MenuSizes.followingLabelFontSize, weight: .regular)
        let numberAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.extraColorMenu]
        let descAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.foreground5]

        let follows = lastUserStats?.follows ?? 0
        let followers = lastUserStats?.followers ?? 0

        let text = NSMutableAttributedString()
        text.append(.init(string: "\(follows.localized()) ", attributes: numberAttrs))
        text.append(.init(string: "Following", attributes: descAttrs))
        text.append(.init(string: " ", attributes: [.font: font, .kern: 4]))
        text.append(.init(string: "\(followers.localized()) ", attributes: numberAttrs))
        text.append(.init(string: "Followers", attributes: descAttrs))

        followLabel.attributedText = text
    }
}

private extension MenuController {
    func setup() {
        updateTheme()

        let barcodeButton = UIButton()
        barcodeButton.setImage(UIImage(named: "barcode")?.scalePreservingAspectRatio(size: MenuSizes.qrCodeSize), for: .normal)
        let titleStack = UIStackView(arrangedSubviews: [nameLabel, checkbox1, barcodeButton])

        let profile = MenuItemButton(title: "PROFILE", image: .menuSidebarProfile)
        let premium = MenuItemButton(title: "PREMIUM", image: .menuSidebarPremium)
        let messages = MenuItemButton(title: "MESSAGES", image: .menuSidebarMessages)
        let bookmarks = MenuItemButton(title: "BOOKMARKS", image: .menuSidebarBookmarks)
        let remoteLogin = MenuItemButton(title: "Remote Login", image: .remoteSessionIcon.scalePreservingAspectRatio(size: 18))
        let redeemCode = MenuItemButton(title: "Scan Code", image: .barcode.scalePreservingAspectRatio(size: 18))
        let settings = MenuItemButton(title: "SETTINGS", image: .menuSidebarSettings)
        let signOut = MenuItemButton(title: "SIGN OUT", image: .menuSidebarSignout)

        let row1 = UIStackView(axis: .horizontal, spacing: 8, [profile, premium, messages])
        let row2 = UIStackView(axis: .horizontal, spacing: 8, [bookmarks, remoteLogin, redeemCode])
        let row3 = UIStackView(axis: .horizontal, spacing: 8, [settings, signOut, UIView()])
        [row1, row2, row3].forEach { $0.distribution = .fillEqually }
        let buttonsStack = UIStackView(axis: .vertical, spacing: 8, [row1, row2, row3])
        let nnfStack = UIStackView(axis: .vertical, spacing: MenuSizes.nnfStackSpacing, [titleStack, domainLabel, followLabel])
        nnfStack.alignment = .leading
        
        let buttonStackParent = UIView()
        buttonStackParent.addSubview(buttonsStack)
        buttonsStack.pinToSuperview(edges: .horizontal).centerToSuperview(axis: .vertical)

        [nnfStack, buttonStackParent, UIView()].forEach { mainStack.addArrangedSubview($0) }
        mainStack.setCustomSpacing(MenuSizes.nnfToMenuButtonsSpacing, after: nnfStack)

        let botMenu = UIStackView([UIView(), closeButton])
        botMenu.isLayoutMarginsRelativeArrangement = true
        botMenu.layoutMargins = .init(top: 5, left: 16, bottom: 0, right: 16)
        let separator = SpacerView(height: 1, color: .background3, priority: .required)

        contentView.addSubview(mainStack)
        contentView.addSubview(separator)
        contentView.addSubview(botMenu)

        mainStack
            .pinToSuperview(edges: .leading, padding: 16)
            .pinToSuperview(edges: .trailing, padding: 16)
            .pinToSuperview(edges: .top, padding: 20)
        mainStack.bottomAnchor.constraint(equalTo: separator.topAnchor).isActive = true

        separator.pinToSuperview(edges: .horizontal)
        botMenu.pinToSuperview(edges: .horizontal)
        botMenu.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        botMenu.pinToSuperview(edges: .bottom, safeArea: true)
        mainStack.axis = .vertical
        mainStack.alignment = .fill

        buttonsStack.topAnchor.constraint(greaterThanOrEqualTo: nnfStack.bottomAnchor, constant: MenuSizes.nnfToMenuButtonsSpacing).isActive = true
        buttonsStack.bottomAnchor.constraint(lessThanOrEqualTo: separator.topAnchor, constant: -16).isActive = true

        contentView.addSubview(messagesIndicator)
        messagesIndicator.pin(to: messages, edges: .top, padding: 8).pin(to: messages, edges: .trailing, padding: 8)

        contentView.addSubview(premiumIndicator)
        premiumIndicator.pin(to: premium, edges: .top, padding: 8).pin(to: premium, edges: .trailing, padding: 8)

        contentView.backgroundColor = .background
        view.addSubview(contentView)
        contentView.pinToSuperview(edges: [.horizontal, .bottom])

        navBarBackground.backgroundColor = .background
        view.addSubview(navBarBackground)
        navBarBackground.pinToSuperview(edges: [.horizontal, .top])

        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)

        let headerBottom: NSLayoutYAxisAnchor
        if showsSearchBar {
            view.addSubview(searchBarButton)
            searchBarButton.topAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor, constant: 8).isActive = true
            searchBarButton.pinToSuperview(edges: .horizontal, padding: 16)

            let searchSeparator = SpacerView(height: 1, color: .background3)
            view.addSubview(searchSeparator)
            searchSeparator.topAnchor.constraint(equalTo: searchBarButton.bottomAnchor, constant: 12).isActive = true
            searchSeparator.pinToSuperview(edges: .horizontal)

            headerBottom = searchSeparator.bottomAnchor
            
            searchBarButton.onTap = { [weak self] in
                guard let self, let nav: UINavigationController = presentingViewController?.findInChildren() else { return }
                
                animateOut { [weak self] in
                    self?.dismiss(animated: false) {
                        SearchViewController.present(from: nav, advanced: false)
                    }
                }
            }
            searchBarButton.onConfigTap = { [weak self] in
                guard let self, let nav: UINavigationController = presentingViewController?.findInChildren() else { return }
                
                animateOut { [weak self] in
                    self?.dismiss(animated: false) {
                        SearchViewController.present(from: nav, advanced: true)
                    }
                }
            }
            
            primalNavigationBar.showBorder = false
        } else {
            headerBottom = primalNavigationBar.bottomAnchor
        }

        contentView.topAnchor.constraint(equalTo: headerBottom).isActive = true
        navBarBackground.bottomAnchor.constraint(equalTo: headerBottom).isActive = true

        primalNavigationBar.onAvatarTapped = { [weak self] in
            self?.dismissAnimated()
        }

        closeButton.addAction(.init(handler: { [weak self] _ in self?.dismissAnimated() }), for: .touchUpInside)

        contentView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)

        titleStack.alignment = .center
        titleStack.spacing = 4
        titleStack.setCustomSpacing(12, after: checkbox1)

        checkbox1.constrainToSize(MenuSizes.checkboxSize)

        let npubs = LoginManager.instance.loggedInNpubs()
        
        let profileImageRow = UIStackView(axis: .vertical, spacing: 24, [])
        contentView.addSubview(profileImageRow)
        profileImageRow
            .centerToView(primalNavigationBar.userImageView, axis: .horizontal)
            .pin(to: barcodeButton, edges: .top)

        for npub in npubs.dropFirst().prefix(2) {
            let avatarImage = UserImageView(height: MenuSizes.accountImageSize)

            LoginManager.instance.$loadedProfiles.receive(on: DispatchQueue.main)
                .sink { users in
                    if avatarImage.animatedImageView.image == nil, let user = users.first(where: { $0.data.npub == npub }) {
                        avatarImage.setUserImage(user)
                    }
                }
                .store(in: &cancellables)

            profileImageRow.addArrangedSubview(avatarImage)

            let button = UIView().constrainToSize(36)
            button.backgroundColor = .black.withAlphaComponent(0.01)
            view.addSubview(button)
            button.centerToView(avatarImage)
            button.addGestureRecognizer(BindableTapGestureRecognizer(action: {
                _ = LoginManager.instance.loginReset(npub)
            }))
        }

        profileImageRow.alignment = .center

        let manageAccountsButtonSize = MenuSizes.accountImageSize + 4
        let manageAccountsButton = ThemeableButton().constrainToSize(manageAccountsButtonSize).setTheme {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .capsule
            config.baseBackgroundColor = .background3
            config.baseForegroundColor = .foreground.withAlphaComponent(0.8)
            config.image = npubs.count < 2 ? .addAccount : .moreAccounts
            config.contentInsets = .zero
            $0.configuration = config
        }
        profileImageRow.addArrangedSubview(manageAccountsButton)

        manageAccountsButton.addAction(.init(handler: { [weak self] _ in
            self?.present(PopupAccountSwitchingController(), animated: true)
        }), for: .touchUpInside)

        buttonsStack.topAnchor.constraint(greaterThanOrEqualTo: profileImageRow.bottomAnchor, constant: 16).isActive = true

        nameLabel.font = .appFont(withSize: MenuSizes.profileNameFontSize, weight: .bold)

        barcodeButton.addAction(.init(handler: { [weak self] _ in self?.showVC(ProfileQRController()) }), for: .touchUpInside)
        messages.addAction(.init(handler: { [weak self] _ in self?.showVC(MessagesViewController()) }), for: .touchUpInside)
        bookmarks.addAction(.init(handler: { [weak self] _ in self?.showVC(PublicBookmarksViewController()) }), for: .touchUpInside)
        premium.addAction(.init(handler: { [weak self] _ in self?.showVC(PremiumViewController()) }), for: .touchUpInside)
        redeemCode.addAction(.init(handler: { [weak self] _ in
            self?.presentVC(ScanAnythingController())
        }), for: .touchUpInside)

        remoteLogin.addAction(.init(handler: { [weak self] _ in
            self?.presentVC(ScanAnythingController(style: .remoteLogin))
        }), for: .touchUpInside)

        profile.addTarget(self, action: #selector(profilePressed), for: .touchUpInside)
        settings.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        signOut.addTarget(self, action: #selector(signoutPressed), for: .touchUpInside)
        
        IdentityManager.instance.$parsedUser.compactMap({ $0 }).receive(on: DispatchQueue.main).sink { [weak self] user in
            self?.update(user)
        }
        .store(in: &cancellables)

        IdentityManager.instance.$userStats.receive(on: DispatchQueue.main).sink { [weak self] stats in
            guard let stats, let self else { return }

            self.lastUserStats = stats
            self.updateFollowLabel()
        }
        .store(in: &cancellables)

        Publishers.Merge(
            NotificationCenter.default.publisher(for: .visitPremiumNotification).map { _ in WalletManager.instance.premiumState },
            WalletManager.instance.$premiumState.debounce(for: 1, scheduler: RunLoop.main)
        )
        .map {
            if UserDefaults.standard.currentUserLastPremiumVisit.timeIntervalSinceNow > -7*24*3600 { return 0 }
            return ($0?.isExpired ?? true) ? 1 : 0
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.number, on: premiumIndicator)
        .store(in: &cancellables)
    }

    func showVC(_ viewController: UIViewController) {
        let nav: UINavigationController? = presentingViewController?.findInChildren()
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                nav?.pushViewController(viewController, animated: true)
            }
        }
    }

    func presentVC(_ viewController: UIViewController) {
        let presenter = presentingViewController
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                presenter?.present(viewController, animated: true)
            }
        }
    }

    func animateIn() {
        UIView.animate(withDuration: 0.35) { [self] in
            contentView.transform = .identity
            primalNavigationBar.chevronView.alpha = 0
        }
        UIView.transition(with: primalNavigationBar.titleLabel, duration: 0.35, options: .transitionCrossDissolve) { [self] in
            primalNavigationBar.title = "Account"
        }
        UIView.transition(with: primalNavigationBar.subtitleLabel, duration: 0.35, options: .transitionCrossDissolve) { [self] in
            primalNavigationBar.subtitle = "Options and settings"
        }
    }

    func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) { [self] in
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.height)
            primalNavigationBar.chevronView.alpha = originalShowChevron ? 1 : 0
        } completion: { _ in
            completion?()
        }
        UIView.transition(with: primalNavigationBar.titleLabel, duration: 0.25, options: .transitionCrossDissolve) { [self] in
            primalNavigationBar.title = originalTitle
        }
        UIView.transition(with: primalNavigationBar.subtitleLabel, duration: 0.25, options: .transitionCrossDissolve) { [self] in
            primalNavigationBar.subtitle = originalSubtitle
        }
    }

    func dismissAnimated() {
        animateOut { [weak self] in
            self?.dismiss(animated: false)
        }
    }

    func update(_ user: ParsedUser) {
        let user = user.data
        
        nameLabel.text = user.displayName.isEmpty ? user.name : user.displayName
        domainLabel.text = user.parsedNip
        checkbox1.user = user
    }

    @objc func profilePressed() {
        guard let profile = IdentityManager.instance.parsedUser else {
            IdentityManager.instance.requestUserProfile()
            return
        }
        showVC(ProfileViewController(profile: profile))
    }

    @objc func settingsButtonPressed() {
        showVC(SettingsMainViewController())
    }

    @objc func signoutPressed() {
        let alert = UIAlertController(title: "Are you sure you want to sign out?", message: "If you didn't save your private key, it will be irretrievably lost", preferredStyle: .alert)
        alert.addAction(.init(title: "Sign out", style: .destructive) { _ in
            LoginManager.instance.logout()
        })

        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

final class MenuItemButton: MyButton, Themeable {
    let title: String
    let image: UIImage?

    override var isPressed: Bool {
        didSet {
            updateTheme()
        }
    }

    let titleLabel = UILabel()
    let imageView = UIImageView().constrainToSize(MenuSizes.menuTileIconSize)

    init(title: String, image: UIImage?) {
        self.title = title.capitalized
        self.image = image
        super.init(frame: .zero)

        let stack = UIStackView(axis: .vertical, spacing: MenuSizes.menuTileIconLabelSpacing, [imageView, titleLabel])
        stack.alignment = .center

        addSubview(stack)
        stack.centerToSuperview()

        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        titleLabel.textAlignment = .center

        backgroundColor = .background3
        layer.cornerRadius = 12
        layer.masksToBounds = true

        constrainToAspect(1)

        updateTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        titleLabel.attributedText = .init(string: title, attributes: [
            .font: UIFont.appFont(withSize: MenuSizes.menuTileFontSize, weight: .regular),
            .kern: 0.2,
            .foregroundColor: isPressed ? UIColor.foreground : UIColor.foreground3,
            .paragraphStyle: {
                let p = NSMutableParagraphStyle()
                p.alignment = .center
                return p
            }()
        ])
        imageView.tintColor = isPressed ? .foreground : .foreground3
        backgroundColor = .background3
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

