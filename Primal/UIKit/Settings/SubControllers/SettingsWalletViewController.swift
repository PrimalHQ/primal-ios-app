//
//  SettingsWalletViewController.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.6.23..
//

import Foundation
import UIKit

let nwcDefaultsKey: String = "nwc"

final class SettingsWalletViewController : UIViewController {
    private var foregroundObserver: NSObjectProtocol?
    private lazy var descriptionLabel: UILabel = UILabel()
    private lazy var actionButton: FancyButton = FancyButton(title: "")

    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }
    
    private func saveNewNWC(_ wcu: WalletConnectURL) {
        UserDefaults.standard.set(wcu.to_url().absoluteString, forKey: nwcDefaultsKey)
    }
    
    private func setup() {
        foregroundObserver = NotificationCenter.default.addObserver(forName: .nostrWalletConnect, object: nil, queue: .main) { notification in
            if let wcu = notification.object as? WalletConnectURL {
                self.saveNewNWC(wcu)
                self.setupTitle()
                let detailText = self.detailText()
                self.actionButton.title = detailText.actionButtonTitle
                self.descriptionLabel.text = detailText.descriptionText
            }
        }
        
        view.backgroundColor = Theme.current.background
        setupBackButton()
        setupTitle()
        setupDetail()
    }
    
    private func setupBackButton() {
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    private func setupTitle() {
        if let _ = UserDefaults.standard.string(forKey: nwcDefaultsKey) {
            title = "Wallet connected"
        } else {
            title = "Connect a wallet"
        }
    }
    private func setupDetail() {
        let detailText = detailText()
        descriptionLabel.textColor = Theme.current.foreground
        descriptionLabel.text = detailText.descriptionText
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.preferredMaxLayoutWidth = view.frame.width
        descriptionLabel.textAlignment = .center
        
        actionButton.title = detailText.actionButtonTitle
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, actionButton])
        stack.axis = .vertical
        stack.setCustomSpacing(40, after: descriptionLabel)
        
        view.addSubview(stack)
        
        stack.centerToSuperview()
    }
    private func detailText() -> (descriptionText: String, actionButtonTitle: String) {
        if
            let wcuUrl = UserDefaults.standard.string(forKey: nwcDefaultsKey),
            let wcu = WalletConnectURL(str: wcuUrl) {
            return ("You are currently using the following bitcoin lightning wallet:\n\n\(wcu.relay.url.absoluteString)\n\(wcu.lud16 ?? "")", "Disconnect Wallet")
        } else {
            return ("To send and receive zaps, connect a bitcoin lightning wallet.", "Connect Alby Wallet")
        }
    }
    @objc private func actionButtonTapped() {
        if let _ = UserDefaults.standard.string(forKey: nwcDefaultsKey) {
            UserDefaults.standard.removeObject(forKey: nwcDefaultsKey)
            navigationController?.popViewController(animated: true)
        } else {
            UIApplication.shared.open(URL(string:"https://nwc.getalby.com/apps/new?c=Primal-iOS")!)
        }
    }
}
