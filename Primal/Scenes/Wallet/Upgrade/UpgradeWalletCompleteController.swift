//
//  UpgradeWalletCompleteController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11. 2. 2026..
//

import Lottie
import UIKit

class UpgradeWalletCompleteController: UIViewController {
//    let spinner = LottieAnimationView(animation: AnimationType.transferSuccess.animation).constrainToSize(160)
    
    let titleLabel = UILabel("Success", color: .white, font: .appFont(withSize: 20, weight: .bold), multiline: true)
    let messageLabel = UILabel("Wallet upgraded!", color: .white, font: .appFont(withSize: 18, weight: .semibold), multiline: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Success"
        navigationItem.hidesBackButton = true
        view.backgroundColor = .receiveMoney
        
        view.addSubview(titleLabel)
        titleLabel.pinToSuperview(edges: .top, padding: 5, safeArea: true).centerToSuperview(axis: .horizontal)
        
        let doneButton = UIButton(configuration: .pill(
            text: "Done",
            foregroundColor: .white,
            backgroundColor: UIColor.init(rgb: 0x0E8A40),
            font: .appFont(withSize: 18, weight: .semibold)
        ))
            .constrainToSize(width: 161, height: 52)
        
        let mainStack = UIStackView(axis: .vertical, [UIImageView(image: .successWallet).constrainToSize(160), SpacerView(height: 60), messageLabel, UIView(), doneButton])
        mainStack.alignment = .center
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 28)
            .pinToSuperview(edges: .bottom, padding: 10, safeArea: true)
            .constrainToSize(height: 560)
        
        doneButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
