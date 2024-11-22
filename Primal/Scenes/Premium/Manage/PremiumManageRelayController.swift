//
//  PremiumManageRelayController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.11.24..
//

import UIKit

class PremiumManageRelayController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let relayURLString = "wss://premium.primal.net"
        
        title = "Premium Relay"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let relayDotIndicator = SpacerView(width: 10, height: 10, color: .foreground5)
        relayDotIndicator.layer.cornerRadius = 5
        let relayStack = UIStackView([relayDotIndicator, UILabel(relayURLString, color: .foreground, font: .appFont(withSize: 16, weight: .regular))])
        relayStack.spacing = 12
        relayStack.alignment = .center
        let relayView = SpacerView(height: 44, color: .background3, priority: .required)
        relayView.layer.cornerRadius = 12
        relayView.addSubview(relayStack)
        relayStack.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let longText = "The Primal Premium relay is a high-performance Nostr relay that only accepts content from Primal Premium users. Posting to this relay improves your visibility on the Nostr network because it guarantees high signal and lack of spam to any Nostr user that reads from it."
        let longLabel = UILabel(longText, color: .foreground3, font: .appFont(withSize: 15, weight: .regular), multiline: true)
        
        let actionButton = LargeRoundedButton(title: "Connect to Premium Relay")
        
        let stack = UIStackView(axis: .vertical, [
            ThemeableImageView().constrainToSize(64).setTheme { $0.image = Theme.current.logoIcon }, SpacerView(height: 16),
            UILabel("Premium Relay", color: .foreground, font: .appFont(withSize: 24, weight: .semibold)), SpacerView(height: 8),
            UILabel("Running strfry.git version1.0.2", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), SpacerView(height: 28),
            SpacerView(width: 65, height: 1, color: .foreground6), SpacerView(height: 28),
            longLabel, SpacerView(height: 24),
            relayView, UIView(),
            actionButton
        ])
        stack.alignment = .center
        actionButton.pinToSuperview(edges: .horizontal)
        relayView.pinToSuperview(edges: .horizontal, padding: 5)
        longLabel.pinToSuperview(edges: .horizontal, padding: 5)
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, padding: 64, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        if IdentityManager.instance.userRelays?.contains(where: { $0.key == relayURLString }) == true {
            actionButton.title = "Connected to Premium Relay"
            actionButton.isEnabled = false
            relayDotIndicator.backgroundColor = .init(rgb: 0x66E205)
        } else {
            actionButton.addAction(.init(handler: { _ in
                FollowManager.instance.addRelay(url: relayURLString)
                actionButton.title = "Connected to Premium Relay"
                actionButton.isEnabled = false
                relayDotIndicator.backgroundColor = .init(rgb: 0x66E205)
            }), for: .touchUpInside)
        }
    }
}
