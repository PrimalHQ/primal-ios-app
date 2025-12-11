//
//  RemoteSignerActiveSessionsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 5. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

extension UIButton.Configuration {
    static func disabled(_ text: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.attributedTitle = .init(text, attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: UIColor.foreground5
        ]))
        config.baseBackgroundColor = .background3
        return config
    }
}

class RemoteSignerActiveSessionsController: UIViewController {
    
    let contentParent = UIView()
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var selectedSessions = Set<String>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        preferredContentSize = .init(width: 400, height: 190)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .background4
        
        let titleLabel = UILabel("Active Sessions", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        let selectButton = UIButton(configuration: .accent("Select All", font: .appFont(withSize: 16, weight: .regular)))
        
        let topStack = UIStackView([titleLabel, selectButton])
        topStack.alignment = .center
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = .init(top: 30, left: 26, bottom: 20, right: 26)
        
        let buttonsParent = UIView()
        
        let mainStack = UIStackView(axis: .vertical, [topStack, contentParent, buttonsParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        let scroll = UIScrollView()
        contentParent.addSubview(scroll)
        scroll.pinToSuperview()
        
        let contentStack = UIStackView(axis: .vertical, [])
        scroll.addSubview(contentStack)
        contentStack.pinToSuperview(padding: 24)
        contentStack.spacing = 12
        
        let settingsButton = UIButton()
        settingsButton.setAttributedTitle(.init(string: "Settings", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 16, weight: .semibold)
        ]), for: .normal)
        settingsButton.layer.cornerRadius = 20
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.foreground6.cgColor
        let disConnectButton = UIButton(configuration: .accentPill(text: "End Session", font: .appFont(withSize: 16, weight: .semibold)))
        let buttonStack = UIStackView([settingsButton, disConnectButton]).constrainToSize(height: 40)
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        buttonsParent.addSubview(buttonStack)
        buttonStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, padding: 4, safeArea: true)
        
        Publishers.CombineLatest(RemoteSigningManager.instance.$activeSessions, LoginManager.instance.$loadedProfiles)
            .sink { [weak self] sessions, profiles in
                contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
                self?.preferredContentSize = .init(width: 400, height: 190 + 70 * sessions.count)
                
                if sessions.isEmpty {
                    self?.dismiss(animated: true)
                }
                
                sessions.forEach { session in
                    let user = profiles.first(where: { $0.data.pubkey == session.userPubKey }) ?? .init(data: .init(pubkey: session.userPubKey))
                    
                    let button = RemoteSignerSessionSelectionButton(user: user, session: session)
                    button.isSelected = self?.selectedSessions.contains(session.sessionId) ?? false
                    contentStack.addArrangedSubview(button)
                    
                    button.addAction(.init(handler: { _ in
                        guard let self else { return }
                        if self.selectedSessions.contains(session.sessionId) {
                            self.selectedSessions.remove(session.sessionId)
                        } else {
                            self.selectedSessions.insert(session.sessionId)
                        }
                    }), for: .touchUpInside)
                }
            }
            .store(in: &cancellables)
        
        NSLayoutConstraint.activate([
            contentStack.widthAnchor.constraint(equalTo: contentParent.widthAnchor, constant: -48),
        ])
        
        $selectedSessions.sink { selected in
            let all = RemoteSigningManager.instance.activeSessions.map { $0.sessionId }
            
            selectButton.configuration = .accent(selected.count == all.count ? "Deselect All" : "Select All", font: .appFont(withSize: 16, weight: .regular))
            
            zip(all, contentStack.arrangedSubviews).forEach { id, button in
                (button as? RemoteSignerSessionSelectionButton)?.isSelected = selected.contains(id)
            }
            
            if selected.count == 1 {
                settingsButton.configuration = .plain()
                settingsButton.layer.borderWidth = 1
                settingsButton.isEnabled = true
                
                settingsButton.setAttributedTitle(.init(string: "Settings", attributes: [
                    .foregroundColor: UIColor.foreground3,
                    .font: UIFont.appFont(withSize: 16, weight: .semibold)
                ]), for: .normal)
            } else {
                settingsButton.layer.borderWidth = 0
                settingsButton.setAttributedTitle(.init(string: "Settings", attributes: [
                    .foregroundColor: UIColor.foreground5,
                    .font: UIFont.appFont(withSize: 16, weight: .semibold)
                ]), for: .normal)
                settingsButton.configuration = .disabled("Settings")
                settingsButton.isEnabled = false
            }
            
            if selected.isEmpty {
                disConnectButton.isEnabled = false
                disConnectButton.configuration = .disabled("End Session")
            } else {
                disConnectButton.isEnabled = true
                disConnectButton.configuration = .accentPill(text: "End Session", font: .appFont(withSize: 16, weight: .semibold))
            }
        }
        .store(in: &cancellables)
        
        selectButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if self.selectedSessions.count == RemoteSigningManager.instance.activeSessions.count {
                self.selectedSessions = []
            } else {
                self.selectedSessions = Set(RemoteSigningManager.instance.activeSessions.map(\.sessionId))
            }
        }), for: .touchUpInside)
        
        settingsButton.addAction(.init(handler: { [weak self] _ in
            guard
                let self,
                let sessionId = selectedSessions.first,
                let clientPubKey = RemoteSigningManager.instance.activeSessions.first(where: { $0.sessionId == sessionId })?.clientPubKey,
                let connection = RemoteSigningManager.instance.activeConnections.first(where: { $0.clientPubKey == clientPubKey }),
                let nav: UINavigationController = navigationController ?? presentingViewController?.findInChildren()
            else { return }
            nav.pushViewController(SettingsConnectedAppController(appConnection: connection), animated: true)
            dismiss(animated: true)
        }), for: .touchUpInside)
        
        disConnectButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let sessions = RemoteSigningManager.instance.activeSessions.filter { self.selectedSessions.contains($0.sessionId) }
            
            guard !sessions.isEmpty else { return }
            
            RemoteSigningManager.instance.endSessions(sessions)
        }), for: .touchUpInside)
    }
}

class RemoteSignerSessionSelectionButton: MyButton {
    let appImage = UIImageView(image: .primalLogo).constrainToSize(40)
    let avatar = UserImageView(height: 28)
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
    
    init(user: ParsedUser, session: AppSession) {
        super.init(frame: .zero)
        
        let nameSuperStack = UIStackView(axis: .vertical, [nameLabel, nipLabel])
        nameSuperStack.spacing = 2
        nameSuperStack.alignment = .leading
        
        let mainStack = UIStackView([appImage, nameSuperStack, avatar])
        mainStack.alignment = .center
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 14).pinToSuperview(edges: .vertical, padding: 10)
        
        layer.cornerRadius = 12
        layer.borderColor = UIColor.accent.cgColor
        backgroundColor = .background3
        
        if let url = URL(string: session.image ?? "") {
            appImage.kf.setImage(with: url)
        }
        
        avatar.setUserImage(user)
        nameLabel.text = session.name
        nipLabel.text = session.url
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
