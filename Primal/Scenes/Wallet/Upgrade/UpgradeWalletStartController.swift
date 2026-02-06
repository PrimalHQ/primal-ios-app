//
//  UpgradeWalletStartController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6. 2. 2026..
//

import UIKit
import Nantes

class UpgradeWalletStartController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet Upgrade"
        navigationItem.leftBarButtonItem = customBackButtonWithDismiss
        view.backgroundColor = .background
        
        let itemStack = UIStackView(axis: .vertical, spacing: 16, [
            BulletPointStack(view: bulletLabel(textArray: [("The upgrade process should take less than a minute", false)])),
            BulletPointStack(view: bulletLabel(textArray: [
                ("We will transfer your wallet balance of ", false),
                ("103,222 sats", true),
                (" to the new wallet", false),
            ])),
            BulletPointStack(view: bulletLabel(textArray: [("We will copy your entire transaction history to the new wallet", false)])),
            BulletPointStack(view: bulletLabel(textArray: [("You will keep your existing lighting address ", false)])),
        ])
        
        let questionsLabel = NantesLabel()
        let upgradeButton = UIButton(configuration: .accentPill(text: "Upgrade Wallet Now", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 52)
        
        let mainStack = UIStackView(axis: .vertical, [
            UIImageView(image: .walletFilledLarge.withTintColor(.foreground3, renderingMode: .alwaysOriginal)),
            itemStack,
            UILabel("Please keep Primal open\nuntil the upgrade process is done.", color: .foreground, font: .appFont(withSize: 16, weight: .regular), multiline: true),
            questionsLabel,
            upgradeButton
        ])
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        
        upgradeButton.pinToSuperview(edges: .horizontal)
        itemStack.pinToSuperview(edges: .horizontal, padding: 22)
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 28).pinToSuperview(edges: .top, padding: 70, safeArea: true).pinToSuperview(edges: .bottom, padding: 10, safeArea: true)
        
        
        let text = NSMutableAttributedString(string:"Questions? Check out our ", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
        ])
        
        text.append(.init(string: "FAQs", attributes: [
            .foregroundColor: UIColor.accent2,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .link: URL(string: "https://primal.net/faq") as Any
        ]))
        
        questionsLabel.attributedText = text
        questionsLabel.delegate = self
    }
    
    func bulletLabel(textArray: [(String, isBold: Bool)]) -> UILabel {
        let text = NSMutableAttributedString()
        
        for (t, isBold) in textArray {
            text.append(.init(string: t, attributes: [
                .foregroundColor: UIColor.foreground,
                .font: UIFont.appFont(withSize: 16, weight: isBold ? .bold : .regular),
            ]))
        }
        
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = text
        return label
    }
}

class BulletPointStack: UIStackView {
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(view: UIView) {
        super.init(frame: .zero)
        
        let dotParent = UIView()
        let dot = SpacerView(width: 5, height: 5, color: .accent, priority: .required)
        dot.layer.cornerRadius = 2.5
        dotParent.addSubview(dot)
        dot.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 8)
        
        addArrangedSubview(dotParent)
        addArrangedSubview(view)
        
        spacing = 10
        alignment = .top
    }
}

extension UpgradeWalletStartController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        show(UgradeWalletFaqController(), sender: nil)
    }
}

