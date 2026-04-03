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
    private let profileImage = UserImageView(height: 52)
    private let nameLabel = UILabel()
    private let checkbox1 = VerifiedView()
    private let domainLabel = UILabel()
    private let followingLabel = UILabel()
    private let followersLabel = UILabel()
    private let mainStack = UIStackView()

    private let premiumIndicator = NumberedNotificationIndicator()
    private let notificationIndicator = NumberedNotificationIndicator()

    private let profileImageButton = UIButton()
    private let followingDescLabel = UILabel()
    private let followersDescLabel = UILabel()
    private let themeButton = UIButton()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func updateTheme() {
        view.backgroundColor = .background

        themeButton.setImage(.themeButton, for: .normal)
        themeButton.tintColor = .foreground3

        nameLabel.textColor = .foreground

        [domainLabel, followersDescLabel, followingDescLabel, followersLabel, followingLabel].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
            $0.textColor = .foreground5
        }
        [followersLabel, followingLabel].forEach { $0.textColor = .extraColorMenu }
    }
}

private extension MenuController {
    func setup() {
        updateTheme()

        let profileImageRow = UIStackView([profileImage, UIView()])

        let barcodeButton = UIButton()
        barcodeButton.setImage(UIImage(named: "barcode"), for: .normal)
        let titleStack = UIStackView(arrangedSubviews: [nameLabel, checkbox1, barcodeButton])
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followingDescLabel, followersLabel, followersDescLabel])

        let profile = MenuItemButton(title: "PROFILE", image: .menuSidebarProfile)
        let premium = MenuItemButton(title: "PREMIUM", image: .menuSidebarPremium)
        let messages = MenuItemButton(title: "MESSAGES", image: .menuSidebarMessages)
        let bookmarks = MenuItemButton(title: "BOOKMARKS", image: .menuSidebarBookmarks)
        let remoteLogin = MenuItemButton(title: "Remote Login", image: .remoteSessionIcon.scalePreservingAspectRatio(size: 18))
        let redeemCode = MenuItemButton(title: "Scan Code", image: .barcode.scalePreservingAspectRatio(size: 18))
        let settings = MenuItemButton(title: "SETTINGS", image: .menuSidebarSettings)
        let signOut = MenuItemButton(title: "SIGN OUT", image: .menuSidebarSignout)

        let buttonsStack = UIStackView(arrangedSubviews: [profile, premium, messages, bookmarks, remoteLogin, redeemCode, settings, signOut])
        [
            profileImageRow, titleStack, domainLabel, followStack,
            buttonsStack, UIView(), themeButton
        ]
        .forEach { mainStack.addArrangedSubview($0) }

        profileImageRow.pinToSuperview(edges: .horizontal)

        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading, padding: 34)
            .pinToSuperview(edges: .trailing, padding: 80)
            .pinToSuperview(edges: .top, padding: 70)
            .pinToSuperview(edges: .bottom, padding: 80, safeArea: true)
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(15, after: profileImageRow)
        mainStack.setCustomSpacing(18, after: titleStack)
        mainStack.setCustomSpacing(10, after: domainLabel)
        mainStack.setCustomSpacing(44, after: followStack)

        view.addSubview(notificationIndicator)
        notificationIndicator.pin(to: messages, edges: .top, padding: 4).pinToSuperview(edges: .leading, padding: 150)

        view.addSubview(premiumIndicator)
        premiumIndicator.pin(to: premium, edges: .top, padding: 4).pinToSuperview(edges: .leading, padding: 137)

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
            let avatarImage = UserImageView(height: 24)

            LoginManager.instance.$loadedProfiles.receive(on: DispatchQueue.main)
                .sink { users in
                    if avatarImage.animatedImageView.image == nil, let user = users.first(where: { $0.data.npub == npub }) {
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

        profileImageRow.alignment = .center

        let manageAccountsButton = ThemeableButton().setTheme {
            $0.configuration = .simpleImage(npubs.count < 2 ? .addAccount : .moreAccounts)
            $0.tintColor = .foreground2
        }
        profileImageRow.addArrangedSubview(manageAccountsButton)

        manageAccountsButton.addAction(.init(handler: { [weak self] _ in
            self?.present(PopupAccountSwitchingController(), animated: true)
        }), for: .touchUpInside)

        nameLabel.font = .appFont(withSize: 16, weight: .bold)

        barcodeButton.addAction(.init(handler: { [weak self] _ in self?.showVC(ProfileQRController()) }), for: .touchUpInside)
        messages.addAction(.init(handler: { [weak self] _ in self?.showVC(MessagesViewController()) }), for: .touchUpInside)
        bookmarks.addAction(.init(handler: { [weak self] _ in self?.showVC(PublicBookmarksViewController()) }), for: .touchUpInside)
        premium.addAction(.init(handler: { [weak self] _ in self?.showVC(PremiumViewController()) }), for: .touchUpInside)
        redeemCode.addAction(.init(handler: { [weak self] _ in
            self?.present(ScanAnythingController(), animated: true)
        }), for: .touchUpInside)

        remoteLogin.addAction(.init(handler: { [weak self] _ in
            self?.present(ScanAnythingController(style: .remoteLogin), animated: true)
        }), for: .touchUpInside)

        profile.addTarget(self, action: #selector(profilePressed), for: .touchUpInside)
        settings.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        signOut.addTarget(self, action: #selector(signoutPressed), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(themeButtonPressed), for: .touchUpInside)
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePressed)))

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
        show(viewController, sender: nil)
    }

    func update(_ user: ParsedUser) {
        profileImage.setUserImage(user)

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
    let imageView = UIImageView().constrainToSize(20)

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
            .font: UIFont.appFont(withSize: 18.2, weight: .regular),
            .kern: 0.2,
            .foregroundColor: isPressed ? UIColor.foreground : UIColor.foreground3
        ])
        imageView.tintColor = isPressed ? .foreground : .foreground3
    }
}
