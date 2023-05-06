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

class MenuContainerController: UIViewController {
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
    
    override var navigationItem: UINavigationItem {
        get { child.navigationItem }
    }
    
    private var isShowingMenu = false
    private var childLeftConstraint: NSLayoutConstraint?
    private var cancellables: Set<AnyCancellable> = []
    
    let child: UIViewController
    let feed: Feed
    init(child: UIViewController, feed: Feed) {
        self.child = child
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let menuButton = mainTabBarController?.closeMenuButton else { return }
        menuButton.removeTarget(self, action: #selector(closeMenuTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(closeMenuTapped), for: .touchUpInside)
    }
    
    func animateOpen() {
        open()
                
        coverView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.child.view.transform = .identity
            self.navigationController?.navigationBar.transform = .identity
            
            self.coverView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func animateClose() {
        close()
        
        UIView.animate(withDuration: 0.3) {
            self.child.view.transform = .identity
            self.navigationController?.navigationBar.transform = .identity
            
            self.view.layoutIfNeeded()
        }
    }
    
    func open() {
        mainStack.alpha = 1
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        childLeftConstraint?.isActive = true
        coverView.isHidden = false
        mainTabBarController?.showCloseMenuButton()
    }
    
    func close() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        childLeftConstraint?.isActive = false
        coverView.isHidden = true
        mainTabBarController?.showButtons()
    }
}

private extension MenuContainerController {
    func setup() {
        let titleStack = UIStackView(arrangedSubviews: [nameLabel, checkbox1])
        let usernameStack = UIStackView(arrangedSubviews: [usernameLabel, checkbox2, checkDomainLabel])
        let followingDescLabel = UILabel()
        let followersDescLabel = UILabel()
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followingDescLabel, followersLabel, followersDescLabel])
        let buttonsStack = UIStackView(arrangedSubviews: [
            MenuItemButton(title: "PROFILE"), MenuItemButton(title: "BLOCKED USERS"),
            MenuItemButton(title: "NOSTR RELAYS"), MenuItemButton(title: "SETTINGS")
        ])
        let signOut = MenuItemButton(title: "SIGN OUT")
        
        [
            profileImage, titleStack, usernameStack, followStack,
            buttonsStack, UIView(), signOut
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
        nameLabel.textColor = .white
        
        [usernameLabel, checkDomainLabel, followersDescLabel, followingDescLabel, followersLabel, followingLabel].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
            $0.textColor = UIColor(rgb: 0x666666)
        }
        [followersLabel, followingLabel].forEach { $0.textColor = UIColor(rgb: 0xD9D9D9) }
        
        let image = UIButton()
        image.addTarget(self, action: #selector(openMenuTapped), for: .touchUpInside)
        image.constrainToSize(36)
        image.setImage(UIImage(named: "ProfilePicture"), for: .normal)
        child.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: image)
        
        view.addSubview(coverView)
        coverView.pin(to: child.view)
        coverView.backgroundColor = .black.withAlphaComponent(0.5)
        coverView.isHidden = true
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenuTapped)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeMenuTapped))
        swipe.direction = .left
        coverView.addGestureRecognizer(swipe)
        
        signOut.addTarget(self, action: #selector(signoutPressed), for: .touchUpInside)
        
        feed.$currentUser.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let user else { return }
            self?.update(user)
        }
        .store(in: &cancellables)
        
        feed.$currentUserStats.receive(on: DispatchQueue.main).sink { [weak self] stats in
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
        
        nameLabel.text = user.displayName
        usernameLabel.text = user.name
        checkDomainLabel.text = user.getDomainNip05()
        
        [checkbox1, checkbox2].forEach { $0.isHidden = user.nip05.isEmpty }
    }
    
    @objc func signoutPressed() {
        do {
            try clear_keypair()
            RootViewController.instance.reset()
        } catch {
            showErrorMessage(error.localizedDescription)
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
        case .began, .changed:
            mainStack.alpha = 1
            let translation = sender.translation(in: self.view)
            child.view.transform = .init(translationX: max(0, translation.x), y: min(0, -translation.x / 4))
            navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -translation.x / 4 + 10))
        case .possible:
            break
        case .ended:
            let translation = sender.translation(in: self.view)
            let velocity = sender.velocity(in: self.view)
            if translation.x > 50, velocity.x > 0.1 {
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

class MenuItemButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(UIColor(rgb: 0xAAAAAA), for: .normal)
        titleLabel?.font = .appFont(withSize: 20, weight: .black)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
