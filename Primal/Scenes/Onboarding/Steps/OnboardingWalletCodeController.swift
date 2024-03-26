//
//  OnboardingWalletCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 22.3.24..
//

import UIKit

class OnboardingWalletCodeController: WalletActivationCodeController, OnboardingViewController {
    override var iconTextColor: UIColor { .white }
    override var inputBackgroundColor: UIColor { .white.withAlphaComponent(0.8) }
    override var inputTextColor: UIColor { .init(rgb: 0x111111) }
    override var confirmButton: UIControl { confButton }
    
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    private let confButton: UIControl = OnboardingMainButton("Finish")
    
    let secondScreen = UIStackView(axis: .vertical, [])
    let loadingSpinner = LoadingSpinnerView().constrainToSize(height: 70)
    
    let skipButton = SolidColorUIButton(title: "I’ll do this later", color: .white)
    
    let session: OnboardingSession
    init(email: String, session: OnboardingSession) {
        self.session = session
        super.init(email: email)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        addBackground(4, clipToLeft: false)
        addNavigationBar("Activate Wallet")
        titleLabel.textAlignment = .center
        
        mainStack.insertArrangedSubview(titleLabel, at: 0)
        mainStack.insertArrangedSubview(SpacerView(height: 20), at: 0)
        
        super.viewDidLoad()
        
        mainStack.addArrangedSubview(SpacerView(height: 12))
        mainStack.addArrangedSubview(skipButton)
        
        skipButton.addAction(.init(handler: { _ in
            RootViewController.instance.reset()
        }), for: .touchUpInside)
    }
    
    override func showSummary(_ newAddress: String) {
        onboardingParent?.resetCrossfade(OnboardingWalletFinalController())
    }
}

final class OnboardingWalletFinalController: UIViewController, OnboardingViewController {
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackground(4, clipToLeft: false)
        addNavigationBar("Success")
        
        let icon = UIImageView(image: UIImage(named: "onboardingFinishCheckmark"))
        let label = UILabel()
        
        let stack = UIStackView(axis: .vertical, [icon, label])
        view.addSubview(stack)
        stack.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .top, padding: 200)
        stack.spacing = 60
        stack.alignment = .center
        
        label.text = "Your wallet has been activated."
        label.textColor = .white
        label.font = .appFont(withSize: 20, weight: .regular)
        
        let confButton = OnboardingMainButton("Done")
        confButton.addAction(.init(handler: { _ in
            RootViewController.instance.reset()
        }), for: .touchUpInside)
        
        view.addSubview(confButton)
        confButton.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
    }
}
