//
//  SettingsNewNWCQRController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.1.25..
//

import UIKit

class SettingsNewNwcQRController: UIViewController {
    init(data: PrimalWalletNewNWCResponse) {
        super.init(nibName: nil, bundle: nil)
        
        title = "New Wallet Connection"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init("Done", attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .regular)
        ]))
        config.baseForegroundColor = .foreground
        let doneButton = UIButton(configuration: config)
        
        let copyButton = LargeRoundedButton(title: "Copy NWC String")
        
        let uriLabel = UILabel(data.uri, color: .foreground4, font: .appFont(withSize: 12, weight: .bold), multiline: true)
        uriLabel.lineBreakMode = .byCharWrapping
        
        let checkImage = UIImageView(image: UIImage(named: "accountSwitchCheck"))
        checkImage.tintColor = .white
        checkImage.backgroundColor = .init(rgb: 0x2FD058)
        checkImage.constrainToSize(20)
        checkImage.contentMode = .center
        checkImage.layer.cornerRadius = 10
        
        let qr = UIImageView(image: UIImage.createQRCode(data.uri, dimension: 225))
        let qrParent = UIView()
        qrParent.backgroundColor = .white
        qrParent.layer.cornerRadius = 12
        qrParent.addSubview(qr)
        qr.pinToSuperview(padding: 5)

        let stack = UIStackView(axis: .vertical, [
            qrParent, SpacerView(height: 16),
            UIStackView([
                checkImage, SpacerView(width: 9),
                UILabel("Connection created", color: .init(rgb: 0x2FD058), font: .appFont(withSize: 16, weight: .semibold))
            ]), SpacerView(height: 14),
            uriLabel,
            UIView(),
            UILabel(
                "This is your Nostr Wallet Connect string. You can paste it into the app you wish to connect your wallet to.",
                color: .foreground,
                font: .appFont(withSize: 16, weight: .regular),
                multiline: true
            ), SpacerView(height: 28),
            copyButton, SpacerView(height: 28),
            doneButton
        ])
        
        copyButton.pinToSuperview(edges: .horizontal)
        stack.alignment = .center
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, padding: 40, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 24, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 24)
        
        copyButton.addAction(.init(handler: { _ in
            UIPasteboard.general.string = data.uri
            RootViewController.instance.view.showToast("Copied!", extraPadding: 0)
        }), for: .touchUpInside)
        
        doneButton.addAction(.init(handler: { [weak self] _ in
            guard let settingsVC = self?.navigationController?.viewControllers.first(where: { $0 as? SettingsWalletViewController != nil }) else {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            self?.navigationController?.popToViewController(settingsVC, animated: true)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
