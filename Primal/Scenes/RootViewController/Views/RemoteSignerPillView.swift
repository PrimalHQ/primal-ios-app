//
//  RemoteSignerPillView.swift
//  Primal
//
//  Created by Pavle Stevanović on 5. 12. 2025..
//

import UIKit

class RemoteSignerPillView: UIView, Themeable {
    let messageView = UIView().constrainToSize(height: 44)
    let messageLabel = UILabel("Remote Session Active", color: .background, font: .appFont(withSize: 16, weight: .semibold))

    let iconView = UIView().constrainToSize(36)
    let icon = UIImageView(image: .remoteSessionIcon)
    let alternateIcon = UIImageView(image: .remoteSessionIcon)
    
    var isOff: Bool = true {
        didSet {
            if isOff {
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
                guard !self.isOff else { return }
                
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
        let messageStack = UIStackView([alternateIcon, messageLabel])
        messageStack.alignment = .center
        messageStack.spacing = 8
        
        messageView.addSubview(messageStack)
        messageStack
            .pinToSuperview(edges: .leading, padding: 24)
            .pinToSuperview(edges: .trailing, padding: 28)
            .centerToSuperview(axis: .vertical)
        
        iconView.layer.cornerRadius = 18
        iconView.addSubview(icon)
        icon.centerToSuperview()
        
        [messageView, iconView].forEach { addSubview($0) }
        messageView.centerToSuperview()
        iconView.pinToSuperview(edges: [.trailing, .top])
        
        layer.zPosition = 900
        isHidden = true
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        messageView.backgroundColor = .foreground
        messageLabel.textColor = .background
        iconView.backgroundColor = .background
        
        icon.tintColor = .foreground
        alternateIcon.tintColor = .background3
    }
}
