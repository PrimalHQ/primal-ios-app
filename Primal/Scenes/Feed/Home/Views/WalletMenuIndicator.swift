//
//  WalletMenuIndicator.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import UIKit

final class WalletMenuIndicator: UIStackView {
    let walletView = LargeWalletView()
    
    init() {
        super.init(frame: .zero)
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        label.text = "primal wallet"
        label.font = .appFont(withSize: 14, weight: .regular)
        
        addArrangedSubview(label)
        addArrangedSubview(walletView)
        
        spacing = 6
        axis = .vertical
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class LargeWalletView: MyButton, Themeable {
    var amount = 0 {
        didSet {
            amountLabel.text = amount.localized()
        }
    }
    
    private let amountLabel = ThemeableLabel().setTheme { $0.textColor = .foreground2 }
    
//    override var isPressed: Bool {
//        didSet {
//            alpha = isPressed ? 0.5 : 1
//        }
//    }
    
    init() {
        super.init(frame: .zero)
        
        amountLabel.font = .appFont(withSize: 36, weight: .bold)
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.text = "------"
        
        let iconView = ThemeableImageView(image: UIImage(named: "feedZap")).constrainToSize(26)
        iconView.setTheme { $0.image = UIImage(named: "feedZap")?.withGradient(from: UIColor.gradient.reversed()) }
        
        let satsLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        satsLabel.text = "sats"
        satsLabel.font = .appFont(withSize: 16, weight: .medium)
        
        let satsParent = UIView()
        satsParent.addSubview(satsLabel)
        satsLabel.pinToSuperview(edges: [.horizontal, .bottom])
        
        let hStack = UIStackView([iconView, SpacerView(width: 8), amountLabel, SpacerView(width: 6), satsParent, UIView()])
        satsParent.pin(to: amountLabel, edges: .vertical, padding: 5)
        
        hStack.alignment = .center
        
        addSubview(hStack)
        hStack.pinToSuperview(edges: .vertical, padding: 12).pinToSuperview(edges: .horizontal, padding: 16)
        
        layer.cornerRadius = 8
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
    }
}
