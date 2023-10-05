//
//  SettingsNsecViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit
import Kingfisher
import FLAnimatedImage

class SettingsNsecViewController: UIViewController, Themeable {
    let copyPubButton = CopyButton(title: "Copy public key")
    let secLabel = ThemeableLabel()
    let copySecButton = CopyButton(title: "Copy private key")
    let showSecButton = ThemeableButton().setTheme {
        $0.setTitleColor(.accent, for: .normal)
        $0.setTitleColor(.accent, for: .highlighted)
    }
    let pubIcon = FLAnimatedImageView(image: UIImage(named: "Profile"))
    
    var isShowingNsec = false {
        didSet {
            updateSec()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        updateTheme()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsNsecViewController {
    func updateSec() {
        showSecButton.setTitle(isShowingNsec ? "hide key" : "show key", for: .normal)
        
        guard isShowingNsec else {
            secLabel.font = .appFont(withSize: 36, weight: .medium)
            secLabel.adjustsFontSizeToFitWidth = true
            secLabel.numberOfLines = 1
            secLabel.text = "• • • • • • • • • • • • • • • • •"
            secLabel.theme = { $0.textColor = .foreground3 }
            return
        }
        
        secLabel.font = .appFont(withSize: 12, weight: .medium)
        secLabel.numberOfLines = 2
        secLabel.adjustsFontSizeToFitWidth = false
        secLabel.theme = { $0.textColor = .foreground3 }
        
        secLabel.text = ICloudKeychainManager.instance.getLoginInfo()?.nVariant.nsec
    }
    
    func setupView() {
        title = "Account"
        
        let pubTitle = SettingsTitleViewVibrant(title: "YOUR PUBLIC KEY")
        let pubLabelParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        let pubLabel = ThemeableLabel().setTheme { $0.textColor = .foreground2 }
        let pubStack = UIStackView(arrangedSubviews: [pubIcon, pubLabel])
        
        let border = BorderView()
        let border2 = BorderView()
        
        let pubLabelDesc = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let secLabelDesc = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let dangerDesc = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        
        
        pubLabelParent.addSubview(pubStack)
        pubStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview(axis: .vertical)
        pubLabelParent.constrainToSize(height: 64)
        
        let secTitle = SettingsTitleViewVibrant(title: "YOUR PRIVATE KEY")
        let secLabelParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        let secStack = UIStackView(arrangedSubviews: [UIImageView(image: UIImage(named: "keyKeychain")), secLabel])
        
        secLabelParent.addSubview(secStack)
        secStack
            .pinToSuperview(edges: .leading, padding: 27)
            .pinToSuperview(edges: .trailing, padding: 16)
            .centerToSuperview(axis: .vertical)
        secLabelParent.constrainToSize(height: 64)
        
        let titleStack = UIStackView(arrangedSubviews: [secTitle, UIView(), showSecButton])
        
        let dangerIcon = ThemeableImageView(image: UIImage(named: "danger")).setTheme { $0.tintColor = .foreground }
        let dangerTitle = SettingsTitleViewVibrant(title: "DANGER ZONE")
        let dangerStack = UIStackView([dangerIcon, SpacerView(width: 6), dangerTitle, UIView()])
        let deleteButton = DeleteAccountButton()
        
        let stack = UIStackView(arrangedSubviews: [
            pubTitle,       SpacerView(height: 16),
            pubLabelParent, SpacerView(height: 22),
            copyPubButton,  SpacerView(height: 16),
            pubLabelDesc,   SpacerView(height: 20),
            border,         SpacerView(height: 26),
            titleStack,     SpacerView(height: 8),
            secLabelParent, SpacerView(height: 22),
            copySecButton,  SpacerView(height: 16),
            secLabelDesc,   SpacerView(height: 20),
            border2,        SpacerView(height: 32),
            dangerStack,    SpacerView(height: 12),
            dangerDesc,     SpacerView(height: 16),
            deleteButton
        ])
        
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: [.horizontal, .top], safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12)
        stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -48).isActive = true
        
        stack.axis = .vertical
        
        pubLabelParent.layer.cornerRadius = 12
        secLabelParent.layer.cornerRadius = 12
        
        pubStack.spacing = 11
        pubStack.alignment = .center
        pubIcon.constrainToSize(44)
        pubIcon.layer.cornerRadius = 22
        pubIcon.layer.masksToBounds = true
        pubIcon.contentMode = .scaleAspectFill
        
        secStack.spacing = 24
        secStack.alignment = .center
        
        pubLabel.font = .appFont(withSize: 12, weight: .medium)
        pubLabel.numberOfLines = 2
        pubLabel.text = ICloudKeychainManager.instance.getLoginInfo()?.nVariant.npub
        
        [pubLabelDesc, secLabelDesc, dangerDesc].forEach {
            $0.font = .appFont(withSize: 14, weight: .regular)
            $0.numberOfLines = 0
        }
        
        pubLabelDesc.text = "Anyone on Nostr can find you via your public key. Feel free to share anywhere."
        secLabelDesc.text = "This key fully controls your Nostr account. Don’t share it with anyone. Only copy this key to store it securely or to login to another Nostr app."
        dangerDesc.text = "This will permanently delete your Nostr account. You won’t be able to login via Primal or other Nostr apps."
        
        copyPubButton.addTarget(self, action: #selector(copyPubPressed), for: .touchUpInside)
        copySecButton.addTarget(self, action: #selector(copySecPressed), for: .touchUpInside)
        showSecButton.addTarget(self, action: #selector(showNsecPressed), for: .touchUpInside)
        
        updateSec()
        updateTheme()
        
        pubIcon.setUserImage(.init(data: IdentityManager.instance.user ?? .init(pubkey: "")))
        
        deleteButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(
                title: "Are you sure you want to delete your account?",
                message: "HEY THIS IS SERIOUS!!\n\nIf you delete your account you will not be able to sign in using that account via Primal or any other Nostr client. Are you sure you want to do this?",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                Task { @MainActor in
                    await _ = IdentityManager.instance.deleteAccount()
                    _ = ICloudKeychainManager.instance.clearSavedKeys()
                    KingfisherManager.shared.cache.clearMemoryCache()
                    UserDefaults.standard.nwc = nil
                    RootViewController.instance.reset()
                }
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
    }
    
    // MARK: - @objc methods
    @objc func copyPubPressed() {
        guard let pub = ICloudKeychainManager.instance.getLoginInfo()?.nVariant.npub else {
            showErrorMessage("Unable to find your public key")
            return
        }
        copyPubButton.animateCopied()
        UIPasteboard.general.string = pub
    }
    
    @objc func copySecPressed() {
        guard let sec = ICloudKeychainManager.instance.getLoginInfo()?.nVariant.nsec else {
            showErrorMessage("Unable to find your secret key")
            return
        }
        copySecButton.animateCopied()
        UIPasteboard.general.string = sec
    }
    
    @objc func showNsecPressed() {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.isShowingNsec.toggle()
        }
    }
}

final class DeleteAccountButton: UIButton {
    init() {
        super.init(frame: .zero)
        
        setImage(UIImage(named: "trash"), for: .normal)
        setTitle("   Delete account", for: .normal)
        setTitleColor(.init(rgb: 0xFE3D2F), for: .normal)
        titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        
        layer.cornerRadius = 12
        layer.borderColor = UIColor(rgb: 0xFE3D2F).withAlphaComponent(0.8).cgColor
        layer.borderWidth = 1
        
        backgroundColor = UIColor(rgb: 0xFE3D2F).withAlphaComponent(0.2)
        
        constrainToSize(height: 48)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
