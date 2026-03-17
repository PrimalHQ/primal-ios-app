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
        
        let satAmount = WalletManager.instance.balance.localized()
        
        let itemStack = UIStackView(axis: .vertical, spacing: 28, [
            BulletPointStack(view: bulletLabel(textArray: [("It will take less than a minute", false)])),
            BulletPointStack(view: bulletLabel(textArray: [("We’ll transfer your wallet balance", false)])),
            BulletPointStack(view: bulletLabel(textArray: [("We’ll copy your transaction history", false)])),
            BulletPointStack(view: bulletLabel(textArray: [("You’ll keep your lighting address", false)])),
            UILabel("Please keep Primal open\nuntil the upgrade process is done", color: .foreground, font: .appFont(withSize: 16, weight: .regular), multiline: true)
        ])
        
        let questionsLabel = NantesLabel()
        let upgradeButton = UIButton(configuration: .accentPill(text: "Upgrade Wallet Now", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 52)
        
        let mainStack = UIStackView(axis: .vertical, [
            UIImageView(image: .walletFilledLarge.withTintColor(.foreground3, renderingMode: .alwaysOriginal)),
            SpacerView(height: 76),
            itemStack,
            SpacerView(height: 65),
            questionsLabel,
            SpacerView(height: 40),
            upgradeButton
        ])
        mainStack.alignment = .center
        
        upgradeButton.pinToSuperview(edges: .horizontal)
        itemStack.pinToSuperview(edges: .horizontal, padding: 13)
        
        let contentView = UIView().constrainToSize(width: 375)
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 28).pinToSuperview(edges: .vertical)
        
        let aspect = RootViewController.instance.view.frame.width / 375
        contentView.anchorPoint = .init(x: 0.5, y: 1)
        contentView.transform = .init(scaleX: aspect, y: aspect)
        
        view.addSubview(contentView)
        contentView.centerToSuperview(axis: .horizontal)
        contentView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        let text = NSMutableAttributedString(string: "Questions? Check out our ", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular)
        ])
        
        text.append(.init(string: "FAQs", attributes: [
            .foregroundColor: UIColor.accent2,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .link: URL(string: "https://primal.net/faq") as Any
        ]))
        
        questionsLabel.attributedText = text
        questionsLabel.delegate = self
        
        upgradeButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.setViewControllers([UpgradeWalletProcessController()], animated: true)
        }), for: .touchUpInside)
    }
    
    func bulletLabel(textArray: [(String, isBold: Bool)]) -> UILabel {
        let text = NSMutableAttributedString()
        
        for (t, isBold) in textArray {
            text.append(.init(string: t, attributes: [
                .foregroundColor: UIColor.foreground,
                .font: UIFont.appFont(withSize: 16, weight: isBold ? .bold : .regular)
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
