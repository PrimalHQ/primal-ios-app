//
//  ProfileShowQRController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.11.23..
//

import Combine
import Kingfisher
import UIKit

extension UIButton.Configuration {
    static func whiteProfileQR(_ text: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init(text, attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 14, weight: .regular)
        ]))
        configuration.baseForegroundColor = .white
        return configuration
    }
    
    static func whiteProfileQRSelected(_ text: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init(text, attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 14, weight: .semibold)
        ]))
        configuration.baseForegroundColor = .white
        return configuration
    }
}

final class QRCodeActionButton: UIButton {
    init(_ title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font  = .appFont(withSize: 18, weight: .semibold)
        backgroundColor = .init(rgb: 0x4B002D)
        layer.cornerRadius = 29
        constrainToSize(height: 58)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ProfileShowQRController: UIViewController, OnboardingViewController {
    struct MenuOption {
        let name: String
        let text: String
        let qrCode: String
    }
    
    var titleLabel: UILabel = .init()
    var backButton: UIButton = .init()
    
    let userInfo = OnboardingProfileInfoView()
    let qrCodeView = UIImageView()
    let copyView = QRCopyView()
    let action = QRCodeActionButton("Scan QR Code")
    let tabParent = UIView()
    
    lazy var scanController = ProfileScanQRController()
    
    private var cancellables: Set<AnyCancellable> = []
    
    let user: ParsedUser?
    init(user: ParsedUser?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        if let user {
            update(user)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension ProfileShowQRController {
    func setup() {
        addBackground(1.5, clipToLeft: false)
        backButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
               
        let qrParent = UIView()
        qrParent.layer.cornerRadius = 16
        qrParent.layer.borderWidth = 4
        qrParent.layer.borderColor = UIColor.white.cgColor
        qrParent.addSubview(qrCodeView)
        qrCodeView.pinToSuperview(padding: 4)
        NSLayoutConstraint.activate([
            qrCodeView.heightAnchor.constraint(equalTo: qrCodeView.widthAnchor),
            qrCodeView.heightAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])
        
        let stack = UIStackView(axis: .vertical, [
            SpacerView(height: 70, priority: .init(1)),
            userInfo,   SpacerView(height: 26),
            tabParent,
            qrParent,   SpacerView(height: 20),
            copyView,  SpacerView(height: 12),
            UIView(),
            action
        ])
        stack.alignment = .center
        
        action.pinToSuperview(edges: .horizontal)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .top, padding: 18).pinToSuperview(edges: .bottom, padding: 45, safeArea: true)
        
        addNavigationBar("")
        backButton.isHidden = false
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let scan = (self.onboardingParent as? ProfileQRController)?.scanController ?? self.scanController
            self.onboardingParent?.pushViewController(scan, animated: true)
        }), for: .touchUpInside)
    }
    
    func update(_ user: ParsedUser) {
        userInfo.image.setUserImage(user, feed: false, size: .init(width: 108, height: 108))
        userInfo.name.text = user.data.firstIdentifier
        userInfo.address.text = user.data.lud16
        
        updateTabs(user)
    }
    
    func updateTabs(_ user: ParsedUser) {
        tabParent.subviews.forEach { $0.removeFromSuperview() }
        
        var options: [MenuOption] = [.init(name: "PUBLIC KEY", text: user.data.npub, qrCode: "nostr:\(user.data.npub)")]
        if !user.data.lud16.isEmpty {
            options.append(.init(name: "LIGHTNING ADDRESS", text: user.data.lud16, qrCode: "lightning:\(user.data.lud16)"))
        }
        
        if options.count != 2 {
            copyView.text = user.data.npub
            qrCodeView.image = UIImage.createWhiteTransparentQRCode("nostr:\(user.data.npub)", dimension: 280)
            tabParent.isHidden = true
            return
        }
        
        tabParent.isHidden = false
        
        let buttons = options.map { (UIButton(configuration: .whiteProfileQR($0.name)), UIButton(configuration: .whiteProfileQRSelected($0.name))) }
        
        let indicatorView = SpacerView(height: 4, color: .white)
        indicatorView.layer.cornerRadius = 2
        tabParent.addSubview(indicatorView)
        
        for ((button, selectedButton), option) in zip(buttons, options) {
            let isFirst = button == buttons.first?.0
            
            tabParent.addSubview(button)
            button.pinToSuperview(edges: .top)
            if isFirst {
                button.pin(to: qrCodeView, edges: .leading).pinToSuperview(edges: .bottom, padding: 30).pinToSuperview(edges: .leading)
                
                indicatorView.pin(to: button, edges: .horizontal).pin(to: button, edges: .bottom, padding: -5)
            } else {
                button.pin(to: qrCodeView, edges: .trailing).pinToSuperview(edges: .trailing)
            }
            
            tabParent.addSubview(selectedButton)
            selectedButton.centerToView(button)
            
            button.isHidden = isFirst
            selectedButton.isHidden = !isFirst
            
            button.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                
                zip(buttons, options).forEach { (buttonTuple, option) in
                    buttonTuple.0.isHidden = buttonTuple.0 == button
                    buttonTuple.1.isHidden = buttonTuple.0 != button
                }
                
                // Remove to remove old constraints
                indicatorView.removeFromSuperview()
                tabParent.addSubview(indicatorView)
                indicatorView.pin(to: button, edges: .horizontal).pin(to: button, edges: .bottom, padding: -10)
                
                UIView.animate(withDuration: 0.3) {
                    self.tabParent.layoutIfNeeded()
                }
                
                UIView.transition(with: copyView, duration: 0.3, options: .transitionCrossDissolve) {
                    self.copyView.text = option.text
                }
                
                UIView.transition(with: qrCodeView.superview ?? qrCodeView, duration: 0.3, options: isFirst ? .transitionFlipFromLeft : .transitionFlipFromRight) {
                    self.qrCodeView.image = UIImage.createWhiteTransparentQRCode(option.qrCode, dimension: 280)
                }
            }), for: .touchUpInside)
            
            if isFirst {
                copyView.text = option.text
                qrCodeView.image = UIImage.createWhiteTransparentQRCode(option.qrCode, dimension: 280)
            }
        }
    }
}
