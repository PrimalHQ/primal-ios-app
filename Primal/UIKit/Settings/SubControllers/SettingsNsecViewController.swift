//
//  SettingsNsecViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit
import Kingfisher

class SettingsNsecViewController: UIViewController, Themeable {
    let copyPubButton = CopyButton(title: "Copy public key")
    let secLabel = ThemeableLabel()
    let copySecButton = CopyButton(title: "Copy private key")
    let showSecButton = ThemeableButton().setTheme {
        $0.setTitleColor(.accent, for: .normal)
        $0.setTitleColor(.accent, for: .highlighted)
    }
    let pubIcon = UIImageView(image: UIImage(named: "Profile"))
    
    var isShowingNsec = false {
        didSet {
            updateSec()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        guard let iconURL = URL(string: IdentityManager.the.user?.picture ?? "") else { return }
        pubIcon.kf.setImage(with: iconURL, options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 44, height: 44))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        showSecButton.setTitle(isShowingNsec ? "hide key" : "show key", for: .normal)
        
        guard isShowingNsec else {
            secLabel.font = .appFont(withSize: 36, weight: .medium)
            secLabel.adjustsFontSizeToFitWidth = true
            secLabel.numberOfLines = 1
            secLabel.text = "• • • • • • • • • • • • • • • • •"
            secLabel.theme = { $0.textColor = .foreground3 }
            return
        }
        
        secLabel.font = .appFont(withSize: 14, weight: .medium)
        secLabel.numberOfLines = 2
        secLabel.adjustsFontSizeToFitWidth = false
        secLabel.theme = { $0.textColor = .foreground }
        
        secLabel.text = get_saved_keypair()?.privkey_bech32
    }
    
    func setupView() {
        title = "Keys"
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let pubTitle = SettingsTitleViewVibrant(title: "YOUR PUBLIC KEY")
        let pubLabelParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        let pubLabel = ThemeableLabel().setTheme { $0.textColor = .foreground }
        let pubLabelDesc = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        let pubStack = UIStackView(arrangedSubviews: [pubIcon, pubLabel])
        let border = BorderView()
        
        pubLabelParent.addSubview(pubStack)
        pubStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview(axis: .vertical)
        pubLabelParent.constrainToSize(height: 64)
        
        let secTitle = SettingsTitleViewVibrant(title: "YOUR PRIVATE KEY")
        let secLabelParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        let secStack = UIStackView(arrangedSubviews: [UIImageView(image: UIImage(named: "keyKeychain")), secLabel])
        let warning = ThemeableImageView(image: UIImage(named: "nsecWarning")).setTheme { $0.tintColor = .foreground4 }
        
        secLabelParent.addSubview(secStack)
        secStack
            .pinToSuperview(edges: .leading, padding: 27)
            .pinToSuperview(edges: .trailing, padding: 16)
            .centerToSuperview(axis: .vertical)
        secLabelParent.constrainToSize(height: 64)
        
        let titleStack = UIStackView(arrangedSubviews: [secTitle, UIView(), showSecButton])
        
        let stack = UIStackView(arrangedSubviews: [
            pubTitle,       SpacerView(size: 16, priority: .defaultLow),
            pubLabelParent, SpacerView(size: 22, priority: .defaultLow),
            copyPubButton,  SpacerView(size: 16, priority: .defaultLow),
            pubLabelDesc,   SpacerView(size: 20, priority: .defaultLow),
            border,         SpacerView(size: 26, priority: .defaultLow),
            titleStack,     SpacerView(size: 8, priority: .defaultLow),
            secLabelParent, SpacerView(size: 22, priority: .defaultLow),
            copySecButton,  SpacerView(size: 16, priority: .defaultLow),
            warning,        UIView()
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 12, safeArea: true)
        let bottomC = stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomC.priority = .defaultHigh
        bottomC.isActive = true
        
        stack.axis = .vertical
        
        pubLabelParent.layer.cornerRadius = 12
        secLabelParent.layer.cornerRadius = 12
        
        pubStack.spacing = 11
        pubStack.alignment = .center
        pubIcon.constrainToSize(44)
        pubIcon.layer.cornerRadius = 22
        pubIcon.layer.masksToBounds = true
        
        secStack.spacing = 24
        secStack.alignment = .center
        
        pubLabel.font = .appFont(withSize: 14, weight: .medium)
        pubLabel.numberOfLines = 2
        pubLabel.text = get_saved_keypair()?.pubkey_bech32
        
        pubLabelDesc.font = .appFont(withSize: 14, weight: .regular)
        pubLabelDesc.numberOfLines = 0
        pubLabelDesc.text = "Anyone on Nostr can find you via your public key. Feel free to share anywhere."
        
        
        
        warning.contentMode = .scaleAspectFit
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
