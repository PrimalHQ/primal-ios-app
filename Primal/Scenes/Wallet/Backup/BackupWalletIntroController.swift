//
//  BackupWalletIntroController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 1. 2026..
//

import UIKit

class BackupWalletIntroController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        title = "Backup Wallet"
        
        let firstLabel = UILabel("We are are going to display your wallet recovery phrase on the next screen.", color: .foreground, font: .appFont(withSize: 18, weight: .regular), multiline: true)
        
        let rectStack = UIStackView(axis: .vertical, spacing: 30, (0...3).map { _ in
            UIStackView(axis: .horizontal, spacing: 16, (0...2).map { _ in
                let view = SpacerView(width: 64, height: 10, color: .foreground)
                view.layer.cornerRadius = 3
                return view
            })
        })
        
        let secondLabel = UILabel()
        secondLabel.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 6
        
        let secondText = NSMutableAttributedString(string: "IMPORTANT:", attributes: [
            .font: UIFont.appFont(withSize: 18, weight: .bold),
            .foregroundColor: UIColor.foreground,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        secondText.append(.init(string: " Primal does not have access to the funds in your wallet. You have sole custody of your wallet via the recovery phrase. If you lose your recovery phrase, ", attributes: [
            .font: UIFont.appFont(withSize: 18, weight: .regular),
            .foregroundColor: UIColor.foreground,
            .paragraphStyle: paragraphStyle
        ]))
        secondText.append(.init(string: "Primal will not be able to restore your funds.", attributes: [
            .font: UIFont.appFont(withSize: 18, weight: .regular),
            .foregroundColor: UIColor.foreground,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]))
        secondLabel.attributedText = secondText
        
        let nextButton = UIButton(configuration: .accentPill(text: "I understand, backup wallet", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 56)
        let cancelButton = UIButton(configuration: .coloredButton("Cancel, I’ll do this later", color: .foreground4, font: .appFont(withSize: 18, weight: .semibold)))
        let buttonStack = UIStackView(axis: .vertical, spacing: 24, [nextButton, cancelButton])
        
        let mainStack = UIStackView(axis: .vertical, [firstLabel, rectStack, secondLabel, buttonStack])
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 24, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 8, safeArea: true)
            .pinToSuperview(edges: .horizontal)
        buttonStack.pinToSuperview(edges: .horizontal, padding: 35)
        firstLabel.constrainToSize(width: 315)
        secondLabel.constrainToSize(width: 315)
        
        nextButton.addAction(.init(handler: { [weak self] _ in
            self?.show(BackupWalletPhraseController(), sender: nil)
        }), for: .touchUpInside)
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
