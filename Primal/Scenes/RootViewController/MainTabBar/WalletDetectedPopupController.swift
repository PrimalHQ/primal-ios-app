//
//  WalletDetectedPopupController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 3. 2026..
//

import Combine
import UIKit

class WalletDetectedPopupController: UIViewController {

    private let isDiscontinued: Bool
    private var cancellables: Set<AnyCancellable> = []
    
    static let regularHeight: CGFloat = 450
    static let discontinuedHeight: CGFloat = 350

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(isDiscontinued: Bool) {
        self.isDiscontinued = isDiscontinued
        super.init(nibName: nil, bundle: nil)
        
        let height = isDiscontinued ? Self.discontinuedHeight : Self.regularHeight

        sheetPresentationController?.detents = [.custom(resolver: { _ in
            let mainScale = RootViewController.instance.view.frame.size.width / 375

            return height * mainScale - 30
        })]

        sheetPresentationController?.prefersGrabberVisible = true
    }

    override func viewDidLoad() {
        view.backgroundColor = .background4
        
        let height = isDiscontinued ? Self.discontinuedHeight : Self.regularHeight

        let mainView = UIView().constrainToSize(width: 375, height: height)
        view.addSubview(mainView)
        mainView.centerToSuperview()

        let mainScale = RootViewController.instance.view.frame.size.width / 375
        mainView.transform = .init(scaleX: mainScale, y: mainScale)

        let userImage = UserImageView(height: 48)

        IdentityManager.instance.$parsedUser.compactMap({ $0 }).sink { user in
            userImage.setUserImage(user)
        }
        .store(in: &cancellables)

        let titleText = isDiscontinued ? "Wallet Discontinued" : "Wallet Detected"
        let descriptionText = isDiscontinued
            ? "Your custodial Primal wallet has been discontinued. To continue using the Primal wallet, please restore your self-custodial wallet via the recovery phrase, or create a new wallet."
            : "We detected that you already have a self-custodial Primal wallet associated with this Nostr account. To use it on this device, please restore it via the recovery phrase. Alternatively, you can create a new wallet which will be associated with your account."

        let descLabel = UILabel()
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1

        descLabel.attributedText = NSAttributedString(string: descriptionText, attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .paragraphStyle: paragraph
        ])

        let restoreButton = UIButton(configuration: .accentPill(text: "Restore Existing Wallet", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 52)
        let createButton = UIButton(configuration: .accent18("Create New Wallet")).constrainToSize(height: 52)

        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 2),
            userImage, SpacerView(height: 21),
            UILabel(titleText, color: .foreground, font: .appFont(withSize: 20, weight: .bold), multiline: true),
            SpacerView(height: 28),
            descLabel,
            SpacerView(height: 39),
            restoreButton,
            SpacerView(height: 12),
            createButton
        ])
        mainStack.alignment = .center
        restoreButton.pinToSuperview(edges: .horizontal)
        descLabel.pinToSuperview(edges: .horizontal, padding: 2)

        mainView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 28).centerToSuperview(axis: .vertical)

        restoreButton.addAction(.init(handler: { [weak self] _ in
            guard let nav: UINavigationController = self?.presentingViewController?.findInChildren() else {
                self?.present(MainNavigationController(rootViewController: RestoreWalletController()), animated: true)
                return
            }
            self?.dismiss(animated: true) {
                nav.pushViewController(RestoreWalletController(), animated: true)
            }
        }), for: .touchUpInside)

        createButton.addAction(.init(handler: { [weak self] _ in
            WalletManager.instance.newWalletSpark(IdentityManager.instance.userHexPubkey)
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
