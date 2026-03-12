//
//  PrimalPremiumLogoView.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.3.25..
//

import UIKit

class PrimalPremiumLogoView: UIView, Themeable {
    let primalImage = UIImageView(image: .primalPremium).constrainToSize(height: 36)

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)

        let logoImage = UIImageView(image: .primalLogo).constrainToSize(36)

        let mainStack = UIStackView([logoImage, primalImage])
        mainStack.spacing = 8
        
        primalImage.contentMode = .scaleAspectFit
        primalImage.constrainToAspect(129 / 49)

        addSubview(mainStack)
        mainStack.pinToSuperview()

        updateTheme()
    }

    func updateTheme() {
        primalImage.tintColor = .mix(.foreground, .foreground3)
    }
}
