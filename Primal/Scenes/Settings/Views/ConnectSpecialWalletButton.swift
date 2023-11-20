//
// Created by Nikola Lukovic on 21.8.23..
//

import UIKit

final class ConnectSpecialWalletButton: MyButton {
    static func Alby() -> ConnectSpecialWalletButton {
        return ConnectSpecialWalletButton(text: "Connect Alby Wallet", textColor: .black, iconName: "albyIcon", gradientColors: [.init(rgb: 0xFFDF6F), .init(rgb: 0xCF7828)])
    }
    static func Mutiny() -> ConnectSpecialWalletButton {
        return ConnectSpecialWalletButton(text: "Connect Mutiny Wallet", textColor: .white, iconName: "mutinyIcon", gradientColors: [.init(rgb: 0x4F1425), .init(rgb: 0x2E0A11)])
    }
    
    private let icon: UIImageView
    private let label: UILabel

    private init(text: String, textColor: UIColor, iconName: String, gradientColors: [UIColor]) {
        icon = UIImageView(image: UIImage(named: iconName))
        label = UILabel()
        
        super.init(frame: .zero)

        label.text = text
        label.font = .appFont(withSize: 18, weight: .medium)
        label.textColor = textColor

        let gradient = GradientView(colors: gradientColors)
        gradient.gradientLayer.startPoint = .init(x: 0, y: 0)
        gradient.gradientLayer.endPoint = .init(x: 1, y: 1)

        addSubview(gradient)
        gradient.pinToSuperview()

        let stack = UIStackView(arrangedSubviews: [icon, label])

        addSubview(stack)
        stack.centerToSuperview()
        stack.alignment = .center
        stack.spacing = 6

        constrainToSize(height: 48)
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }

    override var isPressed: Bool {
        didSet {
            label.alpha = isPressed ? 0.5 : 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
