//
//  MigrateWalletPopupController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 12. 2025..
//

import Combine
import UIKit
import Nantes

class MigrateWalletPopupController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(nibName: nil, bundle: nil)
        
        sheetPresentationController?.detents = [.custom(resolver: { _ in
            let mainScale = RootViewController.instance.view.frame.size.width / 375
            
            return 486 * mainScale - 30
        })]
        
        sheetPresentationController?.prefersGrabberVisible = true
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .background4
        
        let mainView = UIView().constrainToSize(width: 375, height: 486)
        view.addSubview(mainView)
        mainView.centerToSuperview()
        
        let mainScale = RootViewController.instance.view.frame.size.width / 375
        mainView.transform = .init(scaleX: mainScale, y: mainScale)
        
        let userImage = UserImageView(height: 48)
        let dismissButton = UIButton(configuration: .accentPill(text: "Start Wallet Upgrade", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 52)
        let descLabel = NantesLabel()
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 2),
            userImage, SpacerView(height: 21),
            UILabel("Upgrade Your Wallet!", color: .foreground, font: .appFont(withSize: 20, weight: .bold), multiline: true),
            SpacerView(height: 28),
            descLabel,
            SpacerView(height: 39),
            dismissButton
        ])
        mainStack.alignment = .center
        dismissButton.pinToSuperview(edges: .horizontal)
        descLabel.pinToSuperview(edges: .horizontal, padding: 2)
        
        mainView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 28).centerToSuperview(axis: .vertical)
        
        IdentityManager.instance.$parsedUser.compactMap({ $0 }).sink { user in
            userImage.setUserImage(user)
        }
        .store(in: &cancellables)
        
        dismissButton.addAction(.init(handler: { [weak self] _ in
            guard let presenting = self?.presentingViewController else {
                self?.present(UpgradeWalletController(), animated: true)
                return
            }
            self?.dismiss(animated: true) {
                presenting.present(UpgradeWalletController(), animated: true)
            }
        }), for: .touchUpInside)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1
        
        let text = NSMutableAttributedString(string:
"""
Good news: Primal now features a new
self-custodial wallet, which is a required upgrade for all users. 

With one tap, we’ll move your funds and full transaction history to your new self-custodial wallet - so you fully control your bitcoin. 
Questions?  Check out our  
"""
        , attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .paragraphStyle: paragraph,
        ])
        
        text.append(.init(string: "FAQs", attributes: [
            .foregroundColor: UIColor.accent2,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .paragraphStyle: paragraph,
            .link: URL(string: "https://primal.net/faq") as Any
        ]))
        
        descLabel.attributedText = text
        descLabel.delegate = self
    }
}

extension MigrateWalletPopupController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        present(MainNavigationController(rootViewController: UgradeWalletFaqController()), animated: true)
    }
}
