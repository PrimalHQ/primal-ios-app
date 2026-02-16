//
//  UpgradeWalletFailedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11. 2. 2026..
//

import Nantes
import UIKit

class UpgradeWalletFailedController: UIViewController {
    let spinner = UIImageView(image: .walletUpgradeFailed).constrainToSize(160)
    
    let logs: String
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(logs: String) {
        self.logs = logs
        super.init(nibName: nil, bundle: nil)
    }
    
    let titleLabel = UILabel("We encountered an issue while\nupgrading your wallet.", color: .foreground, font: .appFont(withSize: 18, weight: .semibold), multiline: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet Upgrade"
        navigationItem.hidesBackButton = true
        view.backgroundColor = .background
        
        spinner.tintColor = .foreground4
        
        let tryAgainButton = UIButton(configuration: .accentPill(text: "Try Again", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 52)
        
        let descLabel = NantesLabel().constrainToSize(width: 315)
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        descLabel.delegate = self
        
        let mainStack = UIStackView(axis: .vertical, [spinner, UIStackView(axis: .vertical, spacing: 29, [titleLabel, descLabel]), tryAgainButton])
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 28)
            .pinToSuperview(edges: .bottom, padding: 10, safeArea: true)
            .constrainToSize(height: 560)
        
        tryAgainButton.pinToSuperview(edges: .horizontal)
        
        tryAgainButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.setViewControllers([UpgradeWalletProcessController()], animated: true)
        }), for: .touchUpInside)
        
        let firstString = "But no worries, you can safely try again.\n\nIf this issue persists please feel free to contact support at "
        let descText = NSMutableAttributedString(string: firstString, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ])
        descText.append(.init(string: "support@primal.net", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .bold),
            .foregroundColor: UIColor.foreground3
        ]))
        descText.append(.init(string: ".\nMake sure you ", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        descText.append(.init(string: "copy the error log", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.accent2,
            .link: URL(string: "https://primal.net/log") as Any
        ]))
        descText.append(.init(string: ", and include that in your email.", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        
        descLabel.attributedText = descText
    }
}

extension UpgradeWalletFailedController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIPasteboard.general.string = logs
        view.showToast("Copied!")
    }
}
