//
//  PremiumBecomeLegendController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.11.24..
//

import UIKit

class PremiumBecomeLegendController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel("Donate $1000 or more to gain:", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
        titleLabel.textAlignment = .center
        
        let privateBetaTitle = BecomeLegendTitledParagraph(title: "Private Beta Builds", paragraph: "Get access to new features before they are public.")
        let legendaryTitle = BecomeLegendTitledParagraph(title: "Legendary Custom Profile", paragraph: "Option to pick the color of your verified badge and set the glow around your avatar.")
        let infoStack = UIStackView(axis: .vertical, [
            BecomeLegendTitledParagraph(title: "Forever Premium", paragraph: "Primal Premium subscription never expires for legends."),
            privateBetaTitle,
            legendaryTitle,
        ])
        infoStack.spacing = 50
        infoStack.isLayoutMarginsRelativeArrangement = true
        infoStack.directionalLayoutMargins = .init(top: 0, leading: 105, bottom: 0, trailing: 0)
        
        let gratitudeStack = UIStackView(axis: .vertical, [
            UILabel("♥️ Our Eternal Gratitude ♥️", color: .foreground, font: .appFont(withSize: 16, weight: .bold)),
            UILabel("We’ll never forget our biggest supporters.", color: .foreground3, font: .appFont(withSize: 15, weight: .regular)),
            UILabel("People like you will help Nostr succeed.", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
        ])
        gratitudeStack.alignment = .center
        
        let action = LargeRoundedButton(title: "Become a Legend")
        
        let mainStack = UIStackView(axis: .vertical, [titleLabel, infoStack, gratitudeStack, action])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 44, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        title = "Become a Primal Legend"
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        let foreverPremiumIcon = UIImageView(image: UIImage(named: "foreverPremiumIcon"))
        let privateBetaIcon = UIImageView(image: UIImage(named: "privateBetaIcon"))
        let glowIcon = UIImageView(image: UIImage(named: "primalGlowIcon"))
        
        [glowIcon, privateBetaIcon, foreverPremiumIcon].forEach { view.addSubview($0) }
        
        foreverPremiumIcon
            .pin(to: infoStack, edges: .top, padding: -20)
            .centerToView(privateBetaIcon, axis: .horizontal, offset: -6)
        privateBetaIcon.pin(to: privateBetaTitle, edges: .top, padding: -2).pinToSuperview(edges: .leading, padding: 46)
        glowIcon
            .centerToView(foreverPremiumIcon, axis: .horizontal, offset: 0)
            .centerToView(legendaryTitle, axis: .vertical, offset: -4)
        
        action.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.fadeTo(PremiumLegendAmountController())
        }), for: .touchDown)
    }
}

private class BecomeLegendTitledParagraph: UIStackView {
    init(title: String, paragraph: String) {
        super.init(frame: .zero)
        addArrangedSubview(UILabel(title, color: .foreground, font: .appFont(withSize: 16, weight: .semibold)))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let otherLabel = UILabel()
        otherLabel.numberOfLines = 0
        otherLabel.attributedText = .init(string: paragraph, attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.foreground3
        ])
        addArrangedSubview(otherLabel)
        axis = .vertical
        spacing = 2
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}