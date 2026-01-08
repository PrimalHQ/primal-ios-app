//
//  RemoteSignerSignInController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28. 11. 2025..
//

import Combine
import UIKit
import GenericJSON
import PrimalShared

enum AppSignTrustLevel {
    case full, medium, low
    
    var name: String {
        "\(self)".capitalized + " Trust"
    }
    
    var desc: String {
        switch self {
        case .full:     return "I fully trust this app; auto-sign all requests"
        case .medium:   return "Auto-approve most common requests"
        case .low:      return "Ask me to approve each request"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .full:
            return .Signer.highTrust
        case .medium:
            return .Signer.mediumTrust
        case .low:
            return .Signer.lowTrust
        }
    }
    
    var trustLevel: TrustLevel {
        switch self {
        case .full:     return .full
        case .medium:   return .medium
        case .low:      return .low
        }
    }
}

class RemoteSignerSignInController: UIViewController {
    
    let tabSelectionView = TabSelectionView(tabs: ["LOGIN AS", "PERMISSIONS"], distribution: .fillEqually)
    let contentParent = UIView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var selectedNpub: String?
    var selectedUserButton: UserSelectionButton? {
        didSet {
            oldValue?.isSelected = false
            selectedUserButton?.isSelected = true
        }
    }
    
    var selectedTrust: AppSignTrustLevel = .medium
    var selectedTrustButton: TrustSelectionButton? {
        didSet {
            oldValue?.isSelected = false
            selectedTrustButton?.isSelected = true
        }
    }
    
    let connection: URL
    init(connection: URL) {
        self.connection = connection
        super.init(nibName: nil, bundle: nil)
        
        preferredContentSize = .init(width: 400, height: 640)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .background4
        
        let components = URLComponents(url: connection, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        func valueForItem(_ name: String) -> String? { queryItems.first(where: { $0.name == name })?.value }
        
        let titleLabel = UILabel(valueForItem("name") ?? "Application", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        let urlLabel = UILabel(valueForItem("url") ?? "Unknown url", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
        let appPubkey = connection.host() ?? ""
        let callback = valueForItem("callback")
        
        let iconView = UIImageView(image: .create(letter: String(titleLabel.text?.first ?? "A"), size: 48)).constrainToSize(48)
        
        if let image = valueForItem("image") {
            iconView.kf.setImage(with: URL(string: image))
        }
        
        let topStack = UIStackView(axis: .vertical, [SpacerView(height: 32), iconView, titleLabel, urlLabel])
        topStack.alignment = .center
        topStack.setCustomSpacing(8, after: iconView)
        
        contentParent.backgroundColor = .background5
        let buttonsParent = UIView()
        buttonsParent.backgroundColor = .background5
        
        let mainStack = UIStackView(axis: .vertical, [topStack, tabSelectionView, SpacerView(height: 1, color: .foreground6), contentParent, buttonsParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        let horizontalScroll = UIScrollView()
        contentParent.addSubview(horizontalScroll)
        horizontalScroll.pinToSuperview()
        horizontalScroll.showsHorizontalScrollIndicator = false
        horizontalScroll.isPagingEnabled = true
        horizontalScroll.delegate = self
        
        let leftContentParent = UIView()
        let rightContentParent = UIView()
        
        let contentStack = UIStackView([leftContentParent, rightContentParent])
        contentStack.distribution = .fillEqually
        horizontalScroll.addSubview(contentStack)
        contentStack.pinToSuperview()
        
        let leftScroll = UIScrollView()
        leftContentParent.addSubview(leftScroll)
        leftScroll.pinToSuperview()
        
        let leftContentStack = UIStackView(axis: .vertical, [])
        leftScroll.addSubview(leftContentStack)
        leftContentStack.pinToSuperview(padding: 24)
        leftContentStack.spacing = 12
        
        let rightScroll = UIScrollView()
        rightContentParent.addSubview(rightScroll)
        rightScroll.pinToSuperview()
        
        let rightContentStack = UIStackView(axis: .vertical, [])
        rightScroll.addSubview(rightContentStack)
        rightContentStack.pinToSuperview(padding: 24)
        rightContentStack.spacing = 12
        
        let trusts: [AppSignTrustLevel] = [.full, .medium, .low]
        for trust in trusts {
            let trustButton = TrustSelectionButton(trustLevel: trust)
            rightContentStack.addArrangedSubview(trustButton)
            if trust == selectedTrust {
                selectedTrustButton = trustButton
            }
                
            trustButton.addAction(.init(handler: { [weak self, weak trustButton] _ in
                self?.selectedTrust = trust
                self?.selectedTrustButton = trustButton
            }), for: .touchUpInside)
        }
        
        let cancelButton = UIButton()
        cancelButton.setAttributedTitle(.init(string: "Cancel", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 16, weight: .semibold)
        ]), for: .normal)
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.foreground6.cgColor
        let connectButton = UIButton(configuration: .accentPill(text: "Connect", font: .appFont(withSize: 16, weight: .semibold)))
        let buttonStack = UIStackView([cancelButton, connectButton]).constrainToSize(height: 40)
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        buttonsParent.addSubview(buttonStack)
        buttonStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, padding: 4, safeArea: true)
        
        LoginManager.instance.$loadedProfiles.sink { [weak self] users in
            leftContentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            let npubs = LoginManager.instance.loggedInNpubs().filter({ ICloudKeychainManager.instance.hasNsec($0) })
            
            npubs.forEach { npub in
                guard let user = users.first(where: { $0.data.npub == npub }) else { return }
                
                let button = UserSelectionButton(user: user)
                
                if self?.selectedNpub == nil {
                    self?.selectedNpub = user.data.npub
                    self?.selectedUserButton = button
                }
                
                leftContentStack.addArrangedSubview(button)
                
                button.addAction(.init(handler: { [weak button] _ in
                    self?.selectedNpub = user.data.npub
                    self?.selectedUserButton = button
                }), for: .touchUpInside)
            }
        }
        .store(in: &cancellables)
        
        tabSelectionView.$selectedTab.removeDuplicates().sink { [weak self] tab in
            guard let self, !horizontalScroll.isDragging else { return }
            horizontalScroll.setContentOffset(tab == 0 ? .zero : .init(x: contentParent.frame.width, y: 0), animated: true)
        }
        .store(in: &cancellables)
        
        NSLayoutConstraint.activate([
            contentStack.heightAnchor.constraint(equalTo: contentParent.heightAnchor),
            contentStack.widthAnchor.constraint(equalTo: contentParent.widthAnchor, multiplier: 2),
            leftContentStack.widthAnchor.constraint(equalTo: leftContentParent.widthAnchor, constant: -48),
            rightContentStack.widthAnchor.constraint(equalTo: rightContentParent.widthAnchor, constant: -48),
        ])
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        let relays = queryItems.filter({ $0.name == "relay" }).compactMap({ $0.value })
        
        connectButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let pubkey = selectedNpub?.npubToPubkey() else { return }
            
            dismiss(animated: true)
            Task { @MainActor in
                guard let connection = try await RemoteSignerManager.instance.initializeConnection(url: self.connection.absoluteString, userPubKey: pubkey, trustLevel: self.selectedTrust.trustLevel) else {
                    return
                }
                
                if #available(iOS 16.1, *), !RemoteSignerActivityManager.instance.isAudioAllowed {
                    try await Task.sleep(for: .seconds(3) + .milliseconds(300))
                    
                    RootViewController.instance.smartPresent(RemoteSignerRootController(.custom(RemoteSignerDisclosureController(connection: connection) {
                        if let callback, let deeplinkURL = URL(string: callback) {
                            UIApplication.shared.open(deeplinkURL)
                        }
                    })))
                } else {
                    try await Task.sleep(for: .seconds(1))
                    
                    if let callback, let deeplinkURL = URL(string: callback) {
                        await UIApplication.shared.open(deeplinkURL)
                    }
                }
            }
        }), for: .touchUpInside)
    }
}

extension RemoteSignerSignInController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging { return }
        tabSelectionView.set(tab: scrollView.contentOffset.x < contentParent.frame.width / 2 ? 0 : 1)
    }
}

class TrustSelectionButton: MyButton {
    let imageView = UIImageView().constrainToSize(40)
    let nameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let descLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    
    override var isPressed: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }
    
    init(trustLevel: AppSignTrustLevel) {
        super.init(frame: .zero)
        
        let nameStack = UIStackView(axis: .vertical, [nameLabel, descLabel])
        nameStack.spacing = 2
        
        let mainStack = UIStackView([imageView, nameStack])
        mainStack.alignment = .center
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 14).pinToSuperview(edges: .vertical, padding: 12)
        
        layer.cornerRadius = 12
        layer.borderColor = UIColor.accent.cgColor
        backgroundColor = .background3
        
        imageView.tintColor = Theme.inverse.foreground4
        
        imageView.image = trustLevel.icon
        nameLabel.text = trustLevel.name
        descLabel.text = trustLevel.desc
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


class UserSelectionButton: MyButton {
    let avatar = UserImageView(height: 40)
    let checkbox = VerifiedView().constrainToSize(15)
    let nameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let nipLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    
    override var isPressed: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }
    
    init(user: ParsedUser) {
        super.init(frame: .zero)
        
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.spacing = 4
        
        let nameSuperStack = UIStackView(axis: .vertical, [nameStack, nipLabel])
        nameSuperStack.spacing = 2
        nameSuperStack.alignment = .leading
        
        let mainStack = UIStackView([avatar, nameSuperStack])
        mainStack.alignment = .center
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 14).pinToSuperview(edges: .vertical, padding: 12)
        
        layer.cornerRadius = 12
        layer.borderColor = UIColor.accent.cgColor
        backgroundColor = .background3
        
        avatar.setUserImage(user)
        checkbox.user = user.data
        nameLabel.text = user.data.firstIdentifier
        nipLabel.text = user.data.secondIdentifier
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
