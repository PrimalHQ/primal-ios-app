//
//  SettingsNsecViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

class SettingsNsecViewController: UIViewController, Themeable {
    let copyPubButton = UIButton()
    let secLabel = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
    let copySecButton = UIButton()
    let showSecButton = UIButton()
    
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
        let secLabelDesc = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        let warning = ThemeableImageView(image: UIImage(named: "nsecWarning")).setTheme { $0.tintColor = .foreground3 }
        
        secLabelParent.addSubview(secLabel)
        secLabel.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        let stack = UIStackView(arrangedSubviews: [
            pubTitle, pubLabelParent, copyPubButton, pubLabelDesc, border,
            secTitle, secLabelParent, copySecButton, showSecButton, warning, UIView()
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12, safeArea: true)
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
        pubLabel.text = "nsec1w33tr4t0gg3gvrhjh5mxqzvt7xzdrrk64tr0j7mnqdfrrarfj3yqlf8hxp"
        
        pubLabelDesc.font = .appFont(withSize: 14, weight: .regular)
        pubLabelDesc.adjustsFontSizeToFitWidth = true
        pubLabelDesc.text = "This is your public key. Feel free to share anywhere."
        
        secLabel.font = .appFont(withSize: 18, weight: .medium)
        secLabel.numberOfLines = 1
        secLabel.adjustsFontSizeToFitWidth = true
        secLabel.text = "••••••••••••••••••••••••••••••••••••••••••"
        
        warning.contentMode = .scaleAspectFill
        warning.heightAnchor.constraint(equalTo: warning.widthAnchor, multiplier: 80 / 327).isActive = true
    }
}
