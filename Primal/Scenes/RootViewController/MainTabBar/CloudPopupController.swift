//
//  CloudPopupController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 12. 2025..
//

import Combine
import UIKit

class CloudPopupController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(nibName: nil, bundle: nil)
        
        sheetPresentationController?.detents = [.custom(resolver: { [weak self] _ in
            guard let size = self?.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) else { return 480 }
            return size.height
        })]
        sheetPresentationController?.prefersGrabberVisible = true
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .background4
        
        let userImage = UserImageView(height: 48)
        let switchView = SettingsSwitchView("Save key in iCloud Keychain")
        let dismissButton = UIButton(configuration: .accentPill(text: "Let’s Go", font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 40)
        let descLabel = UILabel(
            "This lets you sign in easily on a new iPhone or other Apple devices and not lose access to your account. Your key stays encrypted and under your control.",
            color: .foreground3,
            font: .appFont(withSize: 15, weight: .regular),
            multiline: true
        )
        
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.6.32").split(separator: ".").dropLast().joined(separator: ".")
        
        let mainStack = UIStackView(axis: .vertical, [
            userImage, SpacerView(height: 20),
            UILabel("Welcome to Primal \(appVersion)!", color: .foreground, font: .appFont(withSize: 22, weight: .bold), multiline: true),
            UILabel("You can now securely back up your\nPrimal key to iCloud Keychain.", color: .foreground3, font: .appFont(withSize: 15, weight: .regular), multiline: true),
            SpacerView(height: 22),
            descLabel, SpacerView(height: 30, priority: .defaultLow),
            switchView, SpacerView(height: 32, priority: .defaultLow),
            dismissButton
        ])
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        switchView.pinToSuperview(edges: .horizontal)
        dismissButton.pinToSuperview(edges: .horizontal)
        descLabel.pinToSuperview(edges: .horizontal, padding: 12)
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 32).pinToSuperview(edges: .bottom, padding: 30)
        
        IdentityManager.instance.$parsedUser.compactMap({ $0 }).first().sink { user in
            userImage.setUserImage(user)
            switchView.switchView.isOn = ICloudKeychainManager.instance.hasSavedNsecOline(user.data.npub)
            
            switchView.switchView.addAction(.init(handler: { [weak switchView] _ in
                guard let isOn = switchView?.switchView.isOn else { return }
                
                ICloudKeychainManager.instance.toggleOnlineSyncForNpub(user.data.npub, on: isOn)
            }), for: .valueChanged)
            
        }
        .store(in: &cancellables)
        
        dismissButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
