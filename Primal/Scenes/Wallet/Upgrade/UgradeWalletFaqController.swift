//
//  UgradeWalletFaqController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6. 2. 2026..
//

import UIKit

class UgradeWalletFaqController: UIViewController {
    let walletFAQs: [(question: String, answer: String)] = [
        (
            question: "Do I have to upgrade my wallet?",
            answer: "Yes. Support for the old custodial wallet will be discontinued on March 31, 2026. All users need to upgrade prior to this date."
        ),
        (
            question: "Does the new Primal wallet support both lightning and on-chain transactions?",
            answer: "Yes. Just like with the old custodial wallet, the new Primal wallet enables users to send and receive lightning and on-chain bitcoin transactions."
        ),
        (
            question: "Can I keep my existing Primal lightning address?",
            answer: "Yes. Your Primal lightning address will not change after the wallet upgrade."
        ),
        (
            question: "Can I transfer my funds to a different wallet before I upgrade?",
            answer: "Yes. The old custodial wallet remains fully functional until March 31, 2026. You can send your funds to any other bitcoin wallet prior to upgrading."
        ),
        (
            question: "Will I be able to revert to the old custodial wallet after the upgrade?",
            answer: "No. After the wallet upgrade is completed, you will not be able to revert to the old custodial wallet, however your full transaction history will be transferred to the new wallet."
        ),
        (
            question: "What if I don't upgrade before support for the old wallet is discontinued?",
            answer: "After March 31, 2026 the old custodial wallet will no longer be functional. If you don't upgrade and still have some funds in that wallet, you will be able to recover them by contacting us at support@primal.net."
        ),
        (
            question: "Which technology is the new Primal wallet built on?",
            answer: "The new Primal wallet is built on the Spark network technology. For more information, you can visit: https://spark.money."
        ),
        (
            question: "Are there any transaction fees that I need to pay to upgrade?",
            answer: "No. Primal will cover all transaction fees required to upgrade all our users to their new self-custodial wallets."
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        title = "Wallet Update FAQ"
        navigationItem.leftBarButtonItem = customBackButtonWithDismiss
        
        let scrollView = UIScrollView()
        
        let stackView = UIStackView(axis: .vertical, spacing: 8, walletFAQs.flatMap {
            let titleLabel = UILabel($0.question, color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
            titleLabel.numberOfLines = 0
            let subtitleLabel = UILabel($0.answer, color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
            subtitleLabel.numberOfLines = 0
            return [titleLabel, subtitleLabel, SpacerView(height: 8)]
        })
        
        scrollView.addSubview(stackView)
        stackView.pinToSuperview(edges: .vertical, padding: 20).pinToSuperview(edges: .horizontal, padding: 25)
        
        let closeButton = UIButton(configuration: .pill(text: "Close", foregroundColor: .foreground, backgroundColor: .background3, font: .appFont(withSize: 18, weight: .semibold)))
            .constrainToSize(height: 52)
        
        let mainStack = UIStackView(axis: .vertical, spacing: 24, [scrollView, closeButton])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 20, safeArea: true).pinToSuperview(edges: .horizontal)
        mainStack.alignment = .center
        
        scrollView.pinToSuperview(edges: .horizontal)
        closeButton.pinToSuperview(edges: .horizontal, padding: 28)
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        
        closeButton.addAction(.init(handler: { [weak self] _ in
            guard let nav = self?.navigationController, nav.viewControllers.count > 1 else {
                self?.dismiss(animated: true)
                return
            }
            nav.popViewController(animated: true)
        }), for: .touchUpInside)
    }
    
}
