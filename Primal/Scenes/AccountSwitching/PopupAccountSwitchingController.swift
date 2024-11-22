//
//  PopupAccountSwitchingController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.2.24..
//

import Combine
import UIKit
import FLAnimatedImage

final class PopupAccountSwitchingController: UIViewController {
    let editButton = UIButton(configuration: .gray("Edit"))
    let doneButton = UIButton(configuration: .gray("Done"))
    
    let buttonStack = UIStackView()
    
    let startingNpubs = LoginManager.instance.loggedInNpubs().prefix(4).joined()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        LoginManager.instance.loadProfiles()
    }
}

private extension PopupAccountSwitchingController {
    func setupPickMode() {
        doneButton.isHidden = true
        editButton.isHidden = false
        
        buttonStack.subviews.forEach { $0.removeFromSuperview() }
        
        let npubs = LoginManager.instance.loggedInNpubs()
        
        npubs.map({ AccountSwitchingView(npub: $0) }).forEach { buttonStack.addArrangedSubview($0) }
        
        buttonStack.layoutIfNeeded()
        
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.custom(resolver: { context in
                let count = npubs.count
                
                return 220 + CGFloat(count) * 60
            })]
            pc.animateChanges {
                pc.invalidateDetents()
            }
        }
    }
    
    func setupEditMode() {
        doneButton.isHidden = false
        editButton.isHidden = true
        
        buttonStack.subviews.forEach { $0.removeFromSuperview() }
        
        let npubs = LoginManager.instance.loggedInNpubs()
        
        npubs.map({ AccountEditingView(npub: $0) }).forEach { buttonStack.addArrangedSubview($0) }
        
        buttonStack.layoutIfNeeded()
        
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.large()]
            pc.animateChanges {
                pc.invalidateDetents()
            }
        }
    }
    
    func finishEditMode() {
        setupPickMode()
        
        if LoginManager.instance.loggedInNpubs().prefix(4).joined() != startingNpubs {
            RootViewController.instance.reset()
        }
    }
    
    func setup() {
        let titleLabel = UILabel()
        titleLabel.text = "Accounts"
        titleLabel.font = .appFont(withSize: 20, weight: .bold)
        titleLabel.textColor = .foreground
        
        let titleView = UIView()
        titleView.addSubview(titleLabel)
        titleLabel.centerToSuperview()
        
        titleView.addSubview(editButton)
        titleView.addSubview(doneButton)
        editButton.pinToSuperview(edges: .vertical).pinToSuperview(edges: .leading, padding: 16)
        doneButton.centerToView(editButton)
        
        let npubs = LoginManager.instance.loggedInNpubs()
        
        view.backgroundColor = .background2
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.centerToSuperview().pinToSuperview(edges: .vertical)
        
        let title = UILabel()
        
        let signup = UIButton(configuration: .accent("Create a new account"), primaryAction: .init(handler: { [weak self] _ in
            let presenting = self?.presentingViewController
            self?.finishEditMode()
            self?.dismiss(animated: true) {
                presenting?.show(OnboardingParentViewController(.signup), sender: nil)
            }
        }))
        let login = UIButton(configuration: .accent("Add an existing account"), primaryAction: .init(handler: { [weak self] _ in
            let presenting = self?.presentingViewController
            self?.finishEditMode()
            self?.dismiss(animated: true) {
                presenting?.show(OnboardingParentViewController(.login), sender: nil)
            }
        }))
        
        [signup, login].forEach { $0.setContentHuggingPriority(.required, for: .vertical) }
        
        let extraButtonStack = UIStackView(axis: .vertical, [signup, login])
        extraButtonStack.spacing = 14
        extraButtonStack.alignment = .leading
        
        let scrollStack = UIStackView(axis: .vertical, [buttonStack, SpacerView(height: 10), extraButtonStack])
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.addSubview(scrollStack)
        scrollStack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 12)
        scrollStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24).isActive = true
        let scrollHeight = scrollView.heightAnchor.constraint(equalToConstant: (CGFloat(npubs.count) * 59) + 95)
        scrollHeight.priority = .defaultLow
        scrollHeight.isActive = true
        scrollView.showsVerticalScrollIndicator = false
        
        let stack = UIStackView(arrangedSubviews: [
            pullBarParent,      SpacerView(height: 20),
            titleView,          SpacerView(height: 26),
            scrollView,         UIView()
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 16, safeArea: true).pinToSuperview(edges: .horizontal)
        stack.axis = .vertical
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 4
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        title.text = "My Nostr Feeds"
        title.font = .appFont(withSize: 32, weight: .semibold)
        title.textColor = .foreground
        
        setupPickMode()
        
        editButton.addAction(.init(handler: { [weak self] _ in
            self?.setupEditMode()
        }), for: .touchUpInside)
        
        doneButton.addAction(.init(handler: { [weak self] _ in
            self?.finishEditMode()
        }), for: .touchUpInside)
    }
}

final class AccountEditingView: UIView {
    var cancellables: Set<AnyCancellable> = []
    init(npub: String) {
        super.init(frame: .zero)
        
        let imageView = UserImageView(height: 36)
        let nameLabel = UILabel()
        let subLabel = UILabel()
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.textColor = .foreground
        
        subLabel.font = .appFont(withSize: 14, weight: .regular)
        subLabel.textColor = .foreground4
        
        let minusButton = UIButton(configuration: .simpleImage(UIImage(named: "deleteCell")), primaryAction: .init(handler: { [weak self] _ in
            
            let alert = UIAlertController(title: "Are you sure you want to sign out?", message: "If you didn't save your private key, it will be irretrievably lost", preferredStyle: .alert)
            alert.addAction(.init(title: "Sign out", style: .destructive) { _ in
                _ = ICloudKeychainManager.instance.removeKeypair(npub)
                self?.removeFromSuperview()
            })
            
            alert.addAction(.init(title: "Cancel", style: .cancel))
            (RootViewController.instance.presentedViewController ?? RootViewController.instance).present(alert, animated: true)
        }))
        
        let nameStack = UIStackView(axis: .vertical, [nameLabel, subLabel])
        let mainStack = UIStackView([minusButton.constrainToSize(36), imageView, nameStack])
        
        mainStack.spacing = 8
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 10)
        mainStack.alignment = .center
        
        LoginManager.instance.$loadedProfiles.receive(on: DispatchQueue.main)
            .sink { users in
                guard let user = users.first(where: { $0.data.npub == npub }) else { return }
             
                imageView.setUserImage(user)
                nameLabel.text = user.data.firstIdentifier
                subLabel.text = user.data.nip05
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class AccountSwitchingView: UIView {
    var cancellables: Set<AnyCancellable> = []
    init(npub: String) {
        super.init(frame: .zero)
        
        let imageView = UserImageView(height: 36)
        let nameLabel = UILabel()
        let subLabel = UILabel()
        let check = UIImageView(image: UIImage(named: "accountSwitchCheck"))
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.textColor = .foreground
        
        subLabel.font = .appFont(withSize: 14, weight: .regular)
        subLabel.textColor = .foreground4
        
        check.tintColor = .foreground3
        check.isHidden = true
        
        if LoginManager.instance.loggedInNpubs().first == npub {
            check.isHidden = false
            backgroundColor = .background3
            layer.cornerRadius = 8
        }
        
        let nameStack = UIStackView(axis: .vertical, [nameLabel, subLabel])
        let mainStack = UIStackView([imageView, nameStack, UIView(), check])
        
        mainStack.spacing = 8
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 10)
        mainStack.transform = .init(translationX: 0, y: -1)
        mainStack.alignment = .center
        
        addGestureRecognizer(BindableTapGestureRecognizer(action: {
            _ = LoginManager.instance.loginReset(npub)
        }))
        
        LoginManager.instance.$loadedProfiles.receive(on: DispatchQueue.main)
            .sink { users in
                guard let user = users.first(where: { $0.data.npub == npub }) else { return }
             
                imageView.setUserImage(user)
                nameLabel.text = user.data.firstIdentifier
                subLabel.text = user.data.nip05
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
