//
//  SettingsWalletViewController.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.6.23..
//

import Foundation
import UIKit

extension String {
    static let nwcDefaultsKey = "nwcDefaultsKey"
}

extension UserDefaults {
    var nwc: String? {
        get { string(forKey: .nwcDefaultsKey) }
        set { set(newValue, forKey: .nwcDefaultsKey) }
    }
}
    
final class SettingsWalletViewController : UIViewController, Themeable {
    private var walletObserver: NSObjectProtocol?
    
    private lazy var iconParent = UIView()
    private lazy var walletIcon = UIImageView(image: UIImage(named: "walletLarge"))
    private lazy var checkbox = CheckboxView()
    private lazy var descriptionLabel = UILabel()
    
    private let connectButton = ConnectAlbyButton()
    private lazy var infoView = WalletInfoView()
    private lazy var disconnectButton = GradientSettingsButton(title: "Disconnect Wallet")
    
    let defaults = UserDefaults.standard
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let walletObserver {
            NotificationCenter.default.removeObserver(walletObserver)
        }
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        iconParent.backgroundColor = .background3
        iconParent.layer.borderColor = UIColor(rgb: 0x209C00).withAlphaComponent(0.65).cgColor
        
        walletIcon.tintColor = .foreground5
        descriptionLabel.textColor = .foreground
    }
}

private extension SettingsWalletViewController {
    func saveNewNWC(_ wcu: WalletConnectURL) {
        defaults.nwc = wcu.to_url().absoluteString
    }
    
    func setup() {
        walletObserver = NotificationCenter.default.addObserver(forName: .nostrWalletConnect, object: nil, queue: .main) { notification in
            if let wcu = notification.object as? WalletConnectURL {
                self.saveNewNWC(wcu)
                self.updateView()
            }
        }
        
        setupStack()
        updateView()
        updateTheme()
    }
    
    func updateView() {
        guard let nwc = defaults.nwc, let wcu = WalletConnectURL(str: nwc) else {
            title = "Connect a Wallet"
            descriptionLabel.text = "To send and receive zaps,  connect a bitcoin lightning wallet."
            
            iconParent.layer.borderWidth = 0
            
            connectButton.isHidden = false
            checkbox.isHidden = true
            infoView.isHidden = true
            disconnectButton.isHidden = true
            return
        }
        
        title = "Wallet Connected"
        descriptionLabel.text = "You are currently using the following bitcoin lightning wallet:"
        infoView.firstLabel.text = wcu.relay.url.absoluteString
        infoView.secondLabel.text = wcu.lud16
        
        iconParent.layer.borderWidth = 7
        
        connectButton.isHidden = true
        checkbox.isHidden = false
        infoView.isHidden = false
        disconnectButton.isHidden = false
    }
    
    func setupStack() {
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        let actionStack = UIStackView(arrangedSubviews: [descriptionLabel, connectButton, infoView, disconnectButton])
        actionStack.axis = .vertical
        actionStack.spacing = 20
        
        let stack = UIStackView(arrangedSubviews: [iconParent, actionStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 40
        
        view.addSubview(stack)
        
        descriptionLabel.font = .appFont(withSize: 20, weight: .regular)
        
        iconParent.constrainToSize(200)
        iconParent.layer.cornerRadius = 100
        iconParent.addSubview(walletIcon)
        walletIcon.pinToSuperview(edges: .leading, padding: 42).pinToSuperview(edges: .top, padding: 32)
        
        stack.pinToSuperview(edges: .horizontal, padding: 24).centerToSuperview(axis: .vertical)
        actionStack.pinToSuperview(edges: .horizontal)
        
        view.addSubview(checkbox)
        checkbox.pin(to: iconParent, edges: [.trailing, .bottom], padding: -6)
        
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(disconnectButtonTapped), for: .touchUpInside)
    }
    
    @objc func disconnectButtonTapped() {
        defaults.nwc = nil
        updateView()
    }
    
    @objc func connectButtonTapped() {
        guard let url = URL(string:"https://nwc.getalby.com/apps/new?c=Primal-iOS") else { return }
        UIApplication.shared.open(url)
    }
}

final class CheckboxView: UIView, Themeable {
    let icon = UIImageView(image: UIImage(named: "checkboxLarge"))
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .init(rgb: 0x209C00)
        layer.borderWidth = 6
        layer.cornerRadius = 30
        
        addSubview(icon)
        icon.centerToSuperview()
        updateTheme()
        constrainToSize(60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        layer.borderColor = UIColor.background.cgColor
    }
}

final class WalletInfoView: UIView, Themeable {
    let firstLabel = UILabel()
    let secondLabel = UILabel()
    let spacer = SpacerView(height: 1)
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let stack = UIStackView(arrangedSubviews: [firstLabel, spacer, secondLabel])
        stack.spacing = 10
        stack.axis = .vertical
        
        [firstLabel, secondLabel].forEach {
            $0.textAlignment = .center
            $0.font = .appFont(withSize: 18, weight: .regular)
        }
        
        addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 10).pinToSuperview(edges: .horizontal)
        
        layer.cornerRadius = 12
        updateTheme()
    }
    
    func updateTheme() {
        backgroundColor = .background3
        [firstLabel, secondLabel].forEach {
            $0.textColor = .foreground
        }
        spacer.backgroundColor = .foreground6
    }
}
