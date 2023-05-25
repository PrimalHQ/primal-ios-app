//
//  SettingsNsecViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

class SettingsNsecViewController: UIViewController, Themeable {
    let copyPubButton = CopyButton(title: "Copy public key")
    let secLabel = ThemeableLabel()
    let copySecButton = CopyButton(title: "Copy private key")
    let showSecButton = ShowNsecButton()
    
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
    }
}

private extension SettingsNsecViewController {
    func updateSec() {
        showSecButton.isVisible = isShowingNsec
        copySecButton.isHidden = !isShowingNsec
        
        guard isShowingNsec else {
            secLabel.font = .appFont(withSize: 30, weight: .medium)
            secLabel.adjustsFontSizeToFitWidth = true
            secLabel.numberOfLines = 1
            secLabel.text = "••••••••••••••••••••••••••••••••••••••••••"
            secLabel.theme = { $0.textColor = .foreground3 }
            return
        }
        
        secLabel.font = .appFont(withSize: 18, weight: .medium)
        secLabel.numberOfLines = 2
        secLabel.adjustsFontSizeToFitWidth = false
        secLabel.theme = { $0.textColor = .foreground }
        
        secLabel.text = get_saved_keypair()?.privkey_bech32 ?? ""
    }
    
    func setupView() {
        title = "Keys"
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let pubTitle = SettingsTitleView(title: "PUBLIC KEY")
        let pubLabelParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        let pubLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        let pubLabelDesc = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        let border = BorderView()
        
        pubLabelParent.addSubview(pubLabel)
        pubLabel.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        let secTitle = SettingsTitleView(title: "PRIVATE KEY")
        let secLabelParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        let warning = ThemeableImageView(image: UIImage(named: "nsecWarning")).setTheme { $0.tintColor = .foreground3 }
        
        secLabelParent.addSubview(secLabel)
        secLabel.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        let stack = UIStackView(arrangedSubviews: [
            pubTitle, pubLabelParent, copyPubButton, pubLabelDesc, border,
            secTitle, secLabelParent, copySecButton, showSecButton, warning, UIView()
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 12, safeArea: true)
        let bottomC = stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(12, after: copyPubButton)
        stack.setCustomSpacing(30, after: pubLabelDesc)
        stack.setCustomSpacing(24, after: border)
        stack.setCustomSpacing(12, after: copySecButton)
        
        pubLabelParent.layer.cornerRadius = 8
        secLabelParent.layer.cornerRadius = 8
        
        pubLabel.font = .appFont(withSize: 18, weight: .medium)
        pubLabel.numberOfLines = 2
        pubLabel.text = get_saved_keypair()?.pubkey_bech32
        
        pubLabelDesc.font = .appFont(withSize: 14, weight: .regular)
        pubLabelDesc.adjustsFontSizeToFitWidth = true
        pubLabelDesc.text = "This is your public key. Feel free to share anywhere."
        
        warning.contentMode = .scaleAspectFill
        warning.heightAnchor.constraint(equalTo: warning.widthAnchor, multiplier: 80 / 327).isActive = true
        
        copyPubButton.addTarget(self, action: #selector(copyPubPressed), for: .touchUpInside)
        copySecButton.addTarget(self, action: #selector(copySecPressed), for: .touchUpInside)
        showSecButton.addTarget(self, action: #selector(showNsecPressed), for: .touchUpInside)
        
        updateSec()
        updateTheme()
    }
    
    // MARK: - @objc methods
    @objc func copyPubPressed() {
        guard let pub = get_saved_keypair()?.pubkey_bech32 else {
            showErrorMessage("Unable to find your public key")
            return
        }
        copyPubButton.animateCopied()
        UIPasteboard.general.string = pub
    }
    
    @objc func copySecPressed() {
        guard let sec = get_saved_keypair()?.privkey_bech32 else {
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
