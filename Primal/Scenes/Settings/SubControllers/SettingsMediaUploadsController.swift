//
//  SettingsMediaUploadsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.25..
//

import Combine
import UIKit

extension String {
    static let blossomServerKey = "blossomServerKey"
    static let blossomMirrorKey = "blossomMirrorKey"
}

struct MediaUploadSettings {
    static var blossomServer: String? {
        get {
            return UserDefaults.standard.string(forKey: .blossomServerKey) ?? "blossom.primal.net"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .blossomServerKey)
        
            if let newValue {
//                RelaysPostbox.instance.disconnect()
            } else {
//                if let keys = IdentityManager.instance.userRelays?.keys, !keys.isEmpty {
//                    RelaysPostbox.instance.connect(Array(keys))
//                } else {
//                    RelaysPostbox.instance.connect(bootstrap_relays)
//                }
            }
        }
    }
    
    static var blossomMirrorServer: String? {
        get { UserDefaults.standard.string(forKey: .blossomMirrorKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: .blossomMirrorKey)
        
            if let newValue {
//                Connection.regular.socketURL = URL(string: newValue) ?? PrimalEndpointsManager.regularURL
            } else {
//                Connection.regular.socketURL = PrimalEndpointsManager.regularURL
            }
        }
    }
    
    static var blossomServerURL: URL? {
        guard let blossomServer else { return nil }
        return URL(string: blossomServer)
    }
    
    static var blossomMirrorURL: URL? {
        guard let blossomMirrorServer else { return nil }
        return URL(string: blossomMirrorServer)
    }
}

final class SettingsMediaUploadsController: UIViewController, SettingsController, Themeable {
    private let blossomServerInput = WebConnectInputView()
    private let mirrorInput = WebConnectInputView()
    private let mirrorStack = UIStackView(axis: .vertical, [])
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewCancellables: Set<AnyCancellable> = []
    
    @Published var enableMirror: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsMediaUploadsController {
    func setup() {
        title = "Media Uploads"
        updateTheme()
        
        enableMirror = MediaUploadSettings.blossomMirrorServer?.isEmpty == false
        
        blossomServerInput.input.placeholder = "enter blossom server url"
        mirrorInput.input.placeholder = "enter blossom server url"

        let regularConnection = SettingsNetworkStatusView(title: MediaUploadSettings.blossomServer ?? "")
        regularConnection.status = true
        
        let regularConnectionParent = ThemeableView().constrainToSize(height: 44).setTheme { $0.backgroundColor = .background3 }
        regularConnectionParent.addSubview(regularConnection)
        regularConnection.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        regularConnectionParent.layer.cornerRadius = 12
        
        let mirrorConnection = SettingsNetworkStatusView(title: MediaUploadSettings.blossomServer ?? "")
        mirrorConnection.status = true
        
        let mirrorConnectionParent = ThemeableView().constrainToSize(height: 44).setTheme { $0.backgroundColor = .background3 }
        mirrorConnectionParent.addSubview(mirrorConnection)
        mirrorConnection.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        mirrorConnectionParent.layer.cornerRadius = 12
        
        let restoreBlossomButton = RightAlignedAccentButton(title: "restore default blossom server")
        
        let enableMirrorSwitch = SettingsSwitchView("Enable blossom mirror")
        enableMirrorSwitch.switchView.isOn = enableMirror
        enableMirrorSwitch.switchView.addAction(.init(handler: { [weak self, weak enableMirrorSwitch] _ in
            self?.enableMirror = enableMirrorSwitch?.switchView.isOn ?? false
        }), for: .valueChanged)
        
        let stack = UIStackView(axis: .vertical, [
            titleLabel("BLOSSOM SERVER"), SpacerView(height: 16),
            regularConnectionParent, SpacerView(height: 20),
            SettingsTitleView(title: "SWITCH BLOSSOM SERVER"), SpacerView(height: 8),
            blossomServerInput, SpacerView(height: 16),
            restoreBlossomButton, SpacerView(height: 8),
            SettingsBorder(), SpacerView(height: 24),
            titleLabel("MIRROR"), SpacerView(height: 8),
            enableMirrorSwitch, SpacerView(height: 10),
            descLabel("When enabled, your uploads to the primary blossom server will be automatically copied to the mirror."), SpacerView(height: 8),
            mirrorStack, SpacerView(height: 16)
        ])
        
        [mirrorConnectionParent, SpacerView(height: 20), SettingsTitleView(title: "SWITCH BLOSSOM MIRROR SERVER"), SpacerView(height: 8), mirrorInput]
            .forEach { mirrorStack.addArrangedSubview($0) }
        
        mirrorStack.isHidden = !enableMirror
        
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .onDrag
        
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        scroll.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        let scrollBot = scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54)
        scrollBot.priority = .defaultHigh
        scrollBot.isActive = true
        scroll.addSubview(stack)
        stack.pinToSuperview(padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        [mirrorInput, blossomServerInput].forEach { $0.input.isUserInteractionEnabled = false }
        mirrorInput.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.navigationController?.fadeTo(SettingsEditMediaUploadsController())
        }))
        blossomServerInput.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.navigationController?.fadeTo(SettingsEditMediaUploadsController())
        }))
        
        restoreBlossomButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to restore the default blossom server?", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                MediaUploadSettings.blossomServer = nil
                regularConnection.title = MediaUploadSettings.blossomServer ?? ""
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
        
        $enableMirror.removeDuplicates().dropFirst().sink { [weak self] enable in
            UIView.transition(with: stack, duration: 0.3, options: .transitionCrossDissolve) {
                self?.mirrorStack.isHidden = !enable
                self?.mirrorStack.alpha = enable ? 1 : 0
            }
        }
        .store(in: &cancellables)
    }
    
    func titleLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground }
        label.text = text
        label.font = .appFont(withSize: 18, weight: .semibold)
        return label
    }
}
