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

final class MenuController: UIViewController, Themeable {
    let primalNavigationBar = PrimalNavigationBar()
    let contentView = UIView()
    let navBarBackground = UIView()

    private let nameLabel = UILabel()
    private let checkbox1 = VerifiedView()
    private let domainLabel = UILabel()
    private let followLabel = UILabel()
    private let mainStack = UIStackView()

    private let premiumIndicator = NumberedNotificationIndicator()
    private let notificationIndicator = NumberedNotificationIndicator()

    private let profileImageButton = UIButton()
    private let themeButton = UIButton()
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

        themeButton.setImage(.themeButton, for: .normal)
        themeButton.tintColor = .foreground3

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
        text.append(.init(string: "   ", attributes: [.font: font, .kern: 4]))
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

        let buttonsStack = UIStackView(arrangedSubviews: [profile, premium, messages, bookmarks, remoteLogin, redeemCode, settings, signOut])
        let nnfStack = UIStackView(axis: .vertical, spacing: MenuSizes.nnfStackSpacing, [titleStack, domainLabel, followLabel])
        nnfStack.alignment = .leading
        [
            nnfStack,
            buttonsStack, UIView(), themeButton
        ]
        .forEach { mainStack.addArrangedSubview($0) }

        let botMenu = UIStackView([UIView(), closeButton])
        botMenu.isLayoutMarginsRelativeArrangement = true
        botMenu.layoutMargins = .init(top: 5, left: 16, bottom: 0, right: 16)
        let separator = SpacerView(height: 1, color: .background3, priority: .required)

        contentView.addSubview(mainStack)
        contentView.addSubview(separator)
        contentView.addSubview(botMenu)

        mainStack
            .pinToSuperview(edges: .leading, padding: 18)
            .pinToSuperview(edges: .trailing, padding: 80)
            .pinToSuperview(edges: .top, padding: 20)
        mainStack.bottomAnchor.constraint(equalTo: separator.topAnchor).isActive = true

        separator.pinToSuperview(edges: .horizontal)
        botMenu.pinToSuperview(edges: .horizontal)
        botMenu.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        botMenu.pinToSuperview(edges: .bottom, safeArea: true)
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(MenuSizes.nnfToMenuButtonsSpacing, after: nnfStack)

        contentView.addSubview(notificationIndicator)
        notificationIndicator.pin(to: messages, edges: .top, padding: 4).pinToSuperview(edges: .leading, padding: 150)

        contentView.addSubview(premiumIndicator)
        premiumIndicator.pin(to: premium, edges: .top, padding: 4).pinToSuperview(edges: .leading, padding: 137)

        contentView.backgroundColor = .background
        view.addSubview(contentView)
        contentView.pinToSuperview(edges: [.horizontal, .bottom])

        navBarBackground.backgroundColor = .background
        view.addSubview(navBarBackground)
        navBarBackground.pinToSuperview(edges: [.horizontal, .top])

        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)

        contentView.topAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor).isActive = true
        navBarBackground.bottomAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor).isActive = true

        primalNavigationBar.onAvatarTapped = { [weak self] in
            self?.dismissAnimated()
        }

        closeButton.addAction(.init(handler: { [weak self] _ in self?.dismissAnimated() }), for: .touchUpInside)

        contentView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)

        buttonsStack.axis = .vertical
        buttonsStack.alignment = .leading
        buttonsStack.spacing = MenuSizes.menuButtonsStackSpacing

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

        for npub in npubs.dropFirst().prefix(3) {
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

        let manageAccountsButton = ThemeableButton().setTheme {
            let baseIcon: UIImage = npubs.count < 2 ? .addAccount : .moreAccounts
            $0.configuration = .simpleImage(baseIcon.scalePreservingAspectRatio(size: MenuSizes.accountImageSize))
            $0.tintColor = .foreground2
        }
        profileImageRow.addArrangedSubview(manageAccountsButton)

        manageAccountsButton.addAction(.init(handler: { [weak self] _ in
            self?.present(PopupAccountSwitchingController(), animated: true)
        }), for: .touchUpInside)

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
        themeButton.addTarget(self, action: #selector(themeButtonPressed), for: .touchUpInside)
        
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

    @objc func themeButtonPressed() {
        ContentDisplaySettings.autoDarkMode = false
        switch Theme.current.kind {
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
    let imageView = UIImageView().constrainToSize(MenuSizes.menuButtonIconSize)

    init(title: String, image: UIImage?) {
        self.title = title.capitalized
        self.image = image
        super.init(frame: .zero)

        let stack = UIStackView([imageView, titleLabel])
        stack.alignment = .center
        stack.spacing = 12

        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 8)

        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        updateTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        titleLabel.attributedText = .init(string: title, attributes: [
            .font: UIFont.appFont(withSize: MenuSizes.menuButtonFontSize, weight: .regular),
            .kern: 0.2,
            .foregroundColor: isPressed ? UIColor.foreground : UIColor.foreground3
        ])
        imageView.tintColor = isPressed ? .foreground : .foreground3
    }
}
