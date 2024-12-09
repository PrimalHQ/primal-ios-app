//
//  VerifiedView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 17.8.23..
//

import UIKit

final class VerifiedView: UIView, Themeable {
    public enum CheckState {
        case color(() -> UIColor)
        case transparent
    }
    
    var regularCheckState: CheckState = .transparent
    var extraCheckState: CheckState = .color({ .white })
    
    var user: PrimalUser? {
        didSet {
            updateImages()
        }
    }
    
    private let checkboxImage = UIImageView()
    private let checkImage = UIImageView(image: UIImage(named: "verifiedCheck"))
    
    init() {
        super.init(frame: .zero)
        
        addSubview(checkboxImage)
        addSubview(checkImage)
        checkboxImage.pinToSuperview()
        checkImage.pinToSuperview()
        
        updateImages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateImages() {
        let isExtraVerified: Bool
        if let user {
            if !CheckNip05Manager.instance.isVerified(user) {
                isHidden = true
                return
            }
            isHidden = false
            
            if let custom = PremiumCustomizationManager.instance.getCustomization(pubkey: user.pubkey), custom.custom_badge {
                switch extraCheckState {
                case .color(let color):
                    checkboxImage.image = custom.theme?.checkmarkBackgroundImage ?? UIImage(named: "verifiedBackground")
                    checkImage.isHidden = false
                    checkImage.tintColor = color()
                case .transparent:
                    checkboxImage.image = custom.theme?.transparentCheckmarkImage ?? UIImage(named: "purpleVerified")
                    checkImage.isHidden = true
                }
                checkboxImage.tintColor = .accent
                return
            }
            
            isExtraVerified = user.nip05.hasSuffix("@primal.net")
        } else {
            isExtraVerified = true
        }
        
        let checkState = isExtraVerified ? extraCheckState : regularCheckState
        
        switch checkState {
        case .color(let color):
            checkboxImage.image = UIImage(named: "verifiedBackground")
            checkImage.isHidden = false
            checkImage.tintColor = color()
        case .transparent:
            checkboxImage.image = UIImage(named: "purpleVerified")
            checkImage.isHidden = true
        }
        
        checkboxImage.tintColor = isExtraVerified ? .accent : .foreground3
    }
    
    func updateTheme() {
        updateImages()
    }
}
