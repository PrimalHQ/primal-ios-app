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
    }

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override var isPressed: Bool {
        didSet {
            iconView.alpha = isPressed ? 0.5 : 1
            titleLabel.alpha = isPressed ? 0.5 : 1
        }
    }
    
    init(_ variant: Variant) {
        super.init(frame: .zero)
        
        iconView.image = variant.icon
        titleLabel.text = variant.rawValue.uppercased()
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        iconView.tintColor = .foreground
        
        backgroundColor = .background3
    }
}

private extension LargeWalletButton {
    func setup() {
        let vStack = UIStackView(axis: .vertical, [iconView, titleLabel])
        vStack.alignment = .center
        vStack.spacing = 14
        
        addSubview(vStack)
        vStack.centerToSuperview(axis: .horizontal)
        vStack.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 7).isActive = true
        
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        layer.cornerRadius = 12
        
        updateTheme()
        
        let heightConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
    }
}
