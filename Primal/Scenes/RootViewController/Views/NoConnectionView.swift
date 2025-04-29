//
//  NoConnectionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.3.25..
//

import UIKit

class NoConnectionView: UIView, Themeable {
    let messageView = UIView().constrainToSize(height: 44)
    let messageLabel = UILabel("Unable to connect", color: .background, font: .appFont(withSize: 16, weight: .semibold))

    let iconView = UIView().constrainToSize(36)
    
    var hasConnection: Bool = true {
        didSet {
            if hasConnection {
                isHidden = true
                return
            }
            isHidden = false
            
            guard oldValue else {
                messageView.isHidden = true
                iconView.isHidden = false
                return
            }
            
            iconView.isHidden = true
            messageView.isHidden = false
            
            messageView.alpha = 0
            messageView.transform = .init(translationX: 0, y: -50)
            
            UIView.animate(withDuration: 0.3) {
                self.messageView.alpha = 1
                self.messageView.transform = .identity
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                guard !self.hasConnection else { return }
                
                self.iconView.isHidden = false
                self.iconView.alpha = 0
                
                UIView.animate(withDuration: 0.3) {
                    self.messageView.transform = .init(translationX: 200, y: 0)
                    self.messageView.alpha = 0
                    self.iconView.alpha = 1
                }
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        messageView.layer.cornerRadius = 22
        let messageStack = UIStackView([UIImageView(image: .noNetworkIconInverse), messageLabel])
        messageStack.alignment = .center
        messageStack.spacing = 8
        
        messageView.addSubview(messageStack)
        messageStack
            .pinToSuperview(edges: .leading, padding: 24)
            .pinToSuperview(edges: .trailing, padding: 28)
            .centerToSuperview(axis: .vertical)
        
        iconView.layer.cornerRadius = 18
        let icon = UIImageView(image: .noNetworkIcon)
        iconView.addSubview(icon)
        icon.centerToSuperview()
        
        [messageView, iconView].forEach { addSubview($0) }
        messageView.centerToSuperview()
        iconView.pinToSuperview(edges: [.trailing, .top])
        
        layer.zPosition = 900
        isUserInteractionEnabled = false
        isHidden = true
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        messageView.backgroundColor = .foreground
        messageLabel.textColor = .background
        iconView.backgroundColor = .background
    }
}
