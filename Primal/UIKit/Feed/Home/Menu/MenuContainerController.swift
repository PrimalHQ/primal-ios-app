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

extension UIViewController {
    var menuContainer: MenuContainerController? {
        parent as? MenuContainerController ?? parent?.menuContainer
    }
}

final class MenuContainerController: UIViewController, Themeable {
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let checkbox1 = UIImageView(image: UIImage(named: "verifiedBadge"))
    private let usernameLabel = UILabel()
    private let checkbox2 = UIImageView(image: UIImage(named: "menuVerifiedBadge"))
    private let checkDomainLabel = UILabel()
    private let followingLabel = UILabel()
    private let followersLabel = UILabel()
    private let mainStack = UIStackView()
    private let coverView = UIView()
    private let menuProfileImage = UIImageView()
    
    private let profileImageButton = UIButton()
    private let followingDescLabel = UILabel()
    private let followersDescLabel = UILabel()
    private let themeButton = UIButton()
    
    override var navigationItem: UINavigationItem {
        get { child.navigationItem }
    }
    
    private var isShowingMenu = false
    private var childLeftConstraint: NSLayoutConstraint?
    private var cancellables: Set<AnyCancellable> = []
    
    let child: UIViewController
    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        close()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let menuButton = mainTabBarController?.closeMenuButton else { return }
        menuButton.removeTarget(self, action: #selector(closeMenuTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(closeMenuTapped), for: .touchUpInside)
    }
    
    func animateOpen() {
        open()
                
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.child.view.transform = .identity
            self.coverView.transform = .identity
            self.mainStack.transform = .identity
            self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: self.view.frame.width - 68, y: 0)
            
            self.coverView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func animateClose() {
        close()
        
        UIView.animate(withDuration: 0.3) {
            self.child.view.transform = .identity
            self.coverView.transform = .identity
            self.mainStack.transform = CGAffineTransform(translationX: -300, y: 0)
            self.navigationController?.navigationBar.transform = .identity
            
            self.view.layoutIfNeeded()
        }
    }
    
    func open() {
        mainStack.alpha = 1
        
        childLeftConstraint?.isActive = true
        coverView.isHidden = false
        mainTabBarController?.showCloseMenuButton()
    }
    
    func resetNavigationTabBar() {
        mainTabBarController?.showButtons()
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.navigationBar.transform = .identity
        }
    }
    
    func close() {
        childLeftConstraint?.isActive = false
        coverView.alpha = 0
        coverView.isHidden = true
        mainTabBarController?.showButtons()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        themeButton.setImage(Theme.current.menuButtonImage, for: .normal)
        
        nameLabel.textColor = .foreground
        
        profileImageButton.backgroundColor = .background
        
        coverView.backgroundColor = .background.withAlphaComponent(0.5)
        
        [usernameLabel, checkDomainLabel, followersDescLabel, followingDescLabel, followersLabel, followingLabel].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
            $0.textColor = .foreground5
        }
        [followersLabel, followingLabel].forEach { $0.textColor = .extraColorMenu }
        
        child.updateThemeIfThemeable()
    }
}

private extension MenuContainerController {
    func setup() {
        updateTheme()
        
        let titleStack = UIStackView(arrangedSubviews: [nameLabel, checkbox1, UIImageView(image: UIImage(named: "barcode"))])
        let usernameStack = UIStackView(arrangedSubviews: [usernameLabel, checkbox2, checkDomainLabel])
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followingDescLabel, followersLabel, followersDescLabel])
        
        let signOut = MenuItemButton(title: "SIGN OUT")
        let settings = MenuItemButton(title: "SETTINGS")
        let buttonsStack = UIStackView(arrangedSubviews: [MenuItemButton(title: "PROFILE"), settings, signOut])
        
        [
            profileImage, titleStack, usernameStack, followStack,
            buttonsStack, UIView(), themeButton
        ]
        .forEach { mainStack.addArrangedSubview($0) }
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .top, padding: 70)
            .pinToSuperview(edges: .bottom)
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(17, after: profileImage)
        mainStack.setCustomSpacing(13, after: titleStack)
        mainStack.setCustomSpacing(10, after: usernameStack)
        mainStack.setCustomSpacing(40, after: followStack)
        mainStack.alpha = 0
        
        buttonsStack.axis = .vertical
        buttonsStack.alignment = .leading
        buttonsStack.spacing = 30
        
        titleStack.alignment = .center
        titleStack.spacing = 4
        titleStack.setCustomSpacing(12, after: checkbox1)
        
        usernameStack.alignment = .center
        usernameStack.spacing = 1
        
        followersDescLabel.text = "Followers"
        followingDescLabel.text = "Following"
        followStack.spacing = 4
        followStack.setCustomSpacing(16, after: followingDescLabel)
        
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
        
        profileImage.constrainToSize(52)
        profileImage.layer.cornerRadius = 26
        profileImage.layer.masksToBounds = true
        
        nameLabel.font = .appFont(withSize: 16, weight: .black)
        
        let menuButtonParent = UIView()
        profileImageButton.addTarget(self, action: #selector(toggleMenuTapped), for: .touchUpInside)
        menuProfileImage.layer.cornerRadius = 16
        menuProfileImage.layer.masksToBounds = true
        menuProfileImage.isUserInteractionEnabled = false
        
        menuButtonParent.addSubview(profileImageButton)
        profileImageButton.constrainToSize(44).pinToSuperview()
        menuButtonParent.addSubview(menuProfileImage)
        menuProfileImage.constrainToSize(32).centerToSuperview()
        child.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButtonParent)
        
        view.addSubview(coverView)
        coverView.pin(to: child.view)
        coverView.isHidden = true
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenuTapped)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeMenuTapped))
        swipe.direction = .left
        coverView.addGestureRecognizer(swipe)
        
        settings.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        signOut.addTarget(self, action: #selector(signoutPressed), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(themeButtonPressed), for: .touchUpInside)
        
        IdentityManager.the.$user.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let user else { return }
            self?.update(user)
        }
        .store(in: &cancellables)
        
        IdentityManager.the.$userStats.receive(on: DispatchQueue.main).sink { [weak self] stats in
            guard let stats, let self else { return }
            
            self.followersLabel.text = "\(stats.followers_count)"
            self.followingLabel.text = "\(stats.follows_count)"
        }
        .store(in: &cancellables)
    }
    
    func update(_ user: PrimalUser) {
        profileImage.kf.setImage(with: URL(string: user.picture), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 52, height: 52))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        menuProfileImage.kf.setImage(with: URL(string: user.picture), options: [
            .processor(DownsamplingImageProcessor(size: .init(width: 32, height: 32))),
            .scaleFactor(UIScreen.main.scale)
        ])
        
        nameLabel.text = user.displayName
        usernameLabel.text = user.name
        checkDomainLabel.text = user.getDomainNip05()
        
        [checkbox1, checkbox2].forEach { $0.isHidden = user.nip05.isEmpty }
    }
    
    // MARK: - Objc methods
    
    @objc func settingsButtonPressed() {
        show(SettingsMainViewController(), sender: nil)
        resetNavigationTabBar()
    }
    
    @objc func themeButtonPressed() {
        switch Theme.current.kind {
        case .sunriseWave:
            Theme.defaultTheme = SunsetWave.instance
        case .sunsetWave:
            Theme.defaultTheme = SunriseWave.instance
        }
    }
    
    @objc func signoutPressed() {
        let alert = UIAlertController(title: "Are you sure you want to sign out?", message: "If you didn't save your nsec, it will be irretrievably lost", preferredStyle: .alert)
        alert.addAction(.init(title: "Sign out", style: .destructive) { _ in
            do {
                try clear_keypair()
                RootViewController.instance.reset()
            } catch {
                self.showErrorMessage(error.localizedDescription)
            }
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
            fallthrough
        case .changed:
            mainStack.alpha = 1
            let translation = sender.translation(in: self.view)
            
            let percent = (translation.x / 300).clamp(0, 1)
            
            coverView.alpha = percent
            mainStack.transform = .init(translationX: (1 - percent) * -300, y: 0)
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
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 20, weight: .black)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        setTitleColor(.foreground2, for: .normal)
        setTitleColor(.foreground2.withAlphaComponent(0.5), for: .highlighted)
    }
}
