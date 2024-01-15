//
//  LargeWalletButton.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import UIKit

class LargeWalletButton: MyButton, Themeable {
    enum Variant: String {
        case send, receive, scan
        
        var icon: UIImage? {
            switch self {
            case .send:
                return UIImage(named: "sendWallet")
            case .receive:
                return UIImage(named: "receiveWallet")
            case .scan:
                return UIImage(named: "scanWallet")
            }
        }
        
        var smallIcon: UIImage? {
            icon?.scalePreservingAspectRatio(size: 22).withRenderingMode(.alwaysTemplate)
        }
    }

    let iconView = UIImageView()
    let titleLabel = UILabel()
    
    var variant: Variant
    
    var useSmallIcon = false {
        didSet {
//            UIView.transition(with: self, duration: 13 / 30, options: .transitionCrossDissolve) {
//                self.iconView.image = self.useSmallIcon ? self.variant.smallIcon : self.variant.icon
//            }
        }
    }
    
    override var isPressed: Bool {
        didSet {
            iconView.alpha = isPressed ? 0.5 : 1
            titleLabel.alpha = isPressed ? 0.5 : 1
        }
    }
    
    init(_ variant: Variant) {
        self.variant = variant
        super.init(frame: .zero)
        
        iconView.image = variant.icon
        titleLabel.text = variant.rawValue.uppercased()
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        titleLabel.textColor = .foreground4
        iconView.tintColor = .foreground
    }
}

private extension LargeWalletButton {
    func setup() {
        let iconParent = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        iconParent.addSubview(iconView)
        iconView.centerToSuperview()
        iconParent.constrainToSize(80)
        iconParent.layer.cornerRadius = 40
        
        let vStack = UIStackView(axis: .vertical, [iconParent, titleLabel])
        vStack.alignment = .center
        vStack.spacing = 14
        
        addSubview(vStack)
        vStack.pinToSuperview()
        
        titleLabel.font = .appFont(withSize: 14, weight: .semibold)
        
        updateTheme()
    }
}
