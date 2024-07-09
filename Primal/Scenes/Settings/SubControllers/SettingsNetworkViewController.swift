//
//  SettingsNetworkViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.10.23..
//

import Combine
import UIKit

extension String {
    static let enhancedPrivacyKey = "enhancedPrivacyKey"
    static let cacheServerOverrideKey = "cacheServerOverrideKey"
}

struct NetworkSettings {
    static var enhancedPrivacy: Bool {
        get {
            if !UserDefaults.standard.bool(forKey: .enhancedPrivacyKey) {
                UserDefaults.standard.set(false, forKey: .enhancedPrivacyKey)
                return false
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .enhancedPrivacyKey)
        
            if newValue {
                RelaysPostbox.instance.disconnect()
            } else {
                if let keys = IdentityManager.instance.userRelays?.keys, !keys.isEmpty {
                    RelaysPostbox.instance.connect(Array(keys))
                } else {
                    RelaysPostbox.instance.connect(bootstrap_relays)
                }
            }
        }
    }
    
    static var cacheServerOverride: String? {
        get { UserDefaults.standard.string(forKey: .cacheServerOverrideKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: .cacheServerOverrideKey)
        
            if let newValue {
                Connection.regular.socketURL = URL(string: newValue) ?? PrimalEndpointsManager.regularURL
            } else {
                Connection.regular.socketURL = PrimalEndpointsManager.regularURL
            }
        }
    }
    
    static var cacheServerOverrideURL: URL? {
        guard let cacheServerOverride else { return nil }
        return URL(string: cacheServerOverride)
    }
}

final class SettingsNetworkViewController: UIViewController, SettingsController, Themeable {
    private let cacheServerInput = WebConnectInputView()
    private let relayInput = WebConnectInputView()
    private let relayStackParent = UIView()
    private let relayStack = UIStackView(axis: .vertical, [])
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewCancellables: Set<AnyCancellable> = []
    
    @Published var enhancedPrivacy: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
        
        relayStackParent.backgroundColor = .background3
    }
}

extension SettingsNetworkViewController: UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if (textField.text ?? "").isEmpty {
//            textField.text = "wss://"
//        }
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField.text == "wss://" {
//            textField.text = ""
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.containsEmoji,
            let url = URL(string: text),
            text.hasPrefix("wss://")
        else { return false }
        
        if textField == relayInput.input.input {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to add this relay?\n\(text)", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default) { _ in
                FollowManager.instance.addRelay(url: text)
                
                textField.text = ""
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to switch to this caching service?\n\(text)", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default) { _ in
                NetworkSettings.cacheServerOverride = text                
                textField.text = ""
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
        
        textField.resignFirstResponder()
        return false
    }
}

private extension SettingsNetworkViewController {
    func setup() {
        title = "Network"        
        updateTheme()
        
        enhancedPrivacy = NetworkSettings.enhancedPrivacy
        
        Publishers.CombineLatest($enhancedPrivacy, IdentityManager.instance.$userRelays)
            .receive(on: DispatchQueue.main).sink { [weak self] enhancedPrivacy, relays in
                guard let self else { return }
                
                self.relayStack.subviews.forEach { $0.removeFromSuperview() }
                viewCancellables = []
                
                for (index, relay) in (relays ?? [:]).sorted(by: { $0.key < $1.key }).enumerated() {
                    let parent = UIView()
                    
                    self.relayStack.addArrangedSubview(parent)
                    
                    let view = SettingsNetworkStatusListView(
                        title: relay.key,
                        onDelete: { [weak self] in
                            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete this relay?\n\(relay.key)", preferredStyle: .alert)
                            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                                FollowManager.instance.removeRelay(url: relay.key)
                            })
                            alert.addAction(.init(title: "Cancel", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                    )
                    parent.addSubview(view)
                    view.pinToSuperview()
                    view.border.isHidden = index == (relays?.count ?? 0) - 1
                    
                    RelaysPostbox.instance.pool.$connections.compactMap({ $0.first(where: { c in c.identity == relay.key }) })
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] connection in
                            guard let self else { return }
                            parent.subviews.forEach { $0.removeFromSuperview() }
                            let view = self.relayConnectionView(connection, last: self.relayStack.arrangedSubviews.last == parent)
                            parent.addSubview(view)
                            view.pinToSuperview()
                        }
                        .store(in: &viewCancellables)
                }
            }
            .store(in: &cancellables)

        let regularConnection = SettingsNetworkStatusView(title: Connection.regular.socketURL.absoluteString)
        Connection.regular.$isConnected.receive(on: DispatchQueue.main).sink { isConnected in
            regularConnection.status = isConnected
        }
        .store(in: &cancellables)
        Connection.regular.$socketURL.receive(on: DispatchQueue.main).sink { url in
            regularConnection.title = url.absoluteString
        }
        .store(in: &cancellables)
        
        let regularConnectionParent = ThemeableView().constrainToSize(height: 44).setTheme { $0.backgroundColor = .background3 }
        regularConnectionParent.addSubview(regularConnection)
        regularConnection.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        regularConnectionParent.layer.cornerRadius = 12
        
        let restoreCacheButton = RightAlignedAccentButton(title: "restore default caching service")
        let restoreRelaysButton = RightAlignedAccentButton(title: "restore default relays")
        
        relayStackParent.addSubview(relayStack)
        relayStack.pinToSuperview()
        relayStackParent.layer.cornerRadius = 12
        
        let enhancedPrivacySwitch = SettingsSwitchView("Enhanced Privacy")
        enhancedPrivacySwitch.switchView.isOn = NetworkSettings.enhancedPrivacy
        enhancedPrivacySwitch.switchView.addAction(.init(handler: { [weak self] _ in
            let value = enhancedPrivacySwitch.switchView.isOn
            NetworkSettings.enhancedPrivacy = value
            self?.enhancedPrivacy = value
        }), for: .valueChanged)
        
        let stack = UIStackView(axis: .vertical, [
            enhancedPrivacySwitch, SpacerView(height: 10),
            descLabel("When enabled, your IP address will be visible to the caching service, but not to relays. Your content will be published to your specified relays using the caching service as a proxy."), SpacerView(height: 24),
            SettingsBorder(), SpacerView(height: 24),
            titleLabel("CACHING SERVICE"), SpacerView(height: 16),
            regularConnectionParent, SpacerView(height: 20),
            SettingsTitleView(title: "SWITCH CACHING SERVICE"), SpacerView(height: 8),
            cacheServerInput, SpacerView(height: 16),
            restoreCacheButton, SpacerView(height: 24),
            SettingsBorder(), SpacerView(height: 24),
            titleLabel("RELAYS"), SpacerView(height: 16),
            relayStackParent, SpacerView(height: 20),
            SettingsTitleView(title: "ADD A RELAY"), SpacerView(height: 8),
            relayInput, SpacerView(height: 16),
            restoreRelaysButton, SpacerView(height: 20)
        ])
        
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        scroll.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        let scrollBot = scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54)
        scrollBot.priority = .defaultHigh
        scrollBot.isActive = true
        scroll.addSubview(stack)
        stack.pinToSuperview(padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        [relayInput, cacheServerInput].forEach { view in
            view.input.delegate = self
            view.action.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                _ = textFieldShouldReturn(view.input.input)
            }), for: .touchUpInside)
        }
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.relayInput.input.resignFirstResponder()
            self?.cacheServerInput.input.resignFirstResponder()
        }))
        
        restoreRelaysButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to restore default relays?", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                FollowManager.instance.resetDefaultRelays()
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
        
        restoreCacheButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to restore default caching service?", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                NetworkSettings.cacheServerOverride = nil
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
    }
    
    func titleLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground }
        label.text = text
        label.font = .appFont(withSize: 18, weight: .semibold)
        return label
    }
    
    func relayConnectionView(_ connection: RelayConnection, last: Bool) -> UIView {
        let view = SettingsNetworkStatusListView(title: connection.identity, onDelete: { [weak self] in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete this relay?\n\(connection.identity)", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                FollowManager.instance.removeRelay(url: connection.identity)
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        })
        view.border.isHidden = last
        
        connection.state.receive(on: DispatchQueue.main).sink(receiveCompletion: { _ in
            view.statusView.status = false
        }, receiveValue: { state in
            view.statusView.status = state == .connected
        })
        .store(in: &cancellables)
        return view
    }
}

final class SettingsBorder: UIView, Themeable {
    init() {
        super.init(frame: .zero)
        updateTheme()
        constrainToSize(height: 1)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        backgroundColor = .foreground6
    }
}

final class RightAlignedAccentButton: UIButton, Themeable {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        contentHorizontalAlignment = .trailing
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        setTitleColor(.accent, for: .normal)
    }
}

final class SettingsNetworkStatusListView: UIView {
    let border = ThemeableView().setTheme { $0.backgroundColor = .foreground6 }
    
    let statusView: SettingsNetworkStatusView
    init(title: String, onDelete: @escaping () -> Void) {
        statusView = .init(title: title)
        super.init(frame: .zero)
        
        addSubview(statusView)
        statusView.pinToSuperview(edges: .leading, padding: 12).pinToSuperview(edges: .vertical).pinToSuperview(edges: .trailing, padding: 36)
        
        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(named: "deleteCell"), for: .normal)
        addSubview(deleteButton)
        deleteButton.pinToSuperview(edges: .trailing, padding: 12).centerToSuperview(axis: .vertical)
        
        deleteButton.addAction(.init(handler: { _ in
            onDelete()
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsNetworkStatusView: UIView, Themeable {
    private let statusView = UIView().constrainToSize(10)
    private let nameLabel = UILabel()
    
    var status: Bool? {
        didSet {
            if let status {
                statusView.backgroundColor = status ? UIColor(rgb: 0x66E205) : UIColor(rgb: 0xE20505)
            } else {
                statusView.backgroundColor = .foreground5
            }
        }
    }
    
    var title: String {
        get { nameLabel.text ?? "" }
        set { nameLabel.text = newValue }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        let stack = UIStackView([statusView, nameLabel])
        stack.alignment = .center
        stack.spacing = 14
        
        addSubview(stack)
        stack.pinToSuperview()
        
        statusView.backgroundColor = .foreground5
        statusView.layer.cornerRadius = 5
        
        nameLabel.text = title
        nameLabel.font = .appFont(withSize: 16, weight: .regular)
        
        updateTheme()
        constrainToSize(height: 44)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground
    }
}
