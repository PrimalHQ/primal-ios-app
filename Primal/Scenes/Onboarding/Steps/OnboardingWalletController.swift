//
//  OnboardingWalletController.swift
//  Primal
//
//  Created by Pavle Stevanović on 22.3.24..
//

import UIKit

class OnboardingWalletController: WalletActivateViewController, OnboardingViewController {
    override var iconTextColor: UIColor { .white }
    override var inputBackgroundColor: UIColor { .white.withAlphaComponent(0.8) }
    override var inputPlaceholderColor: UIColor { .black.withAlphaComponent(0.5) }
    override var inputTextColor: UIColor { .init(rgb: 0x111111) }
    
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    private let confButton: UIControl = OnboardingMainButton("Next")
    override var confirmButton: UIControl { confButton }
    
    let secondScreen = UIStackView(axis: .vertical, [])
    let loadingSpinner = LoadingSpinnerView().constrainToSize(height: 70)
    
    let skipButton = SolidColorUIButton(title: "I’ll do this later", color: .white)
    
    var session: OnboardingSession
    let profile: AccountCreationData
    init(profile: AccountCreationData, session: OnboardingSession) {
        self.session = session
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        addBackground(4, clipToLeft: false)
        addNavigationBar("Activate Wallet")
        titleLabel.textAlignment = .center
        
        mainStack.insertArrangedSubview(titleLabel, at: 0)
        mainStack.insertArrangedSubview(SpacerView(height: 20), at: 0)
        
        super.viewDidLoad()
        
        mainStack.addArrangedSubview(skipButton)
     
        terms.removeFromSuperview()
        
        skipButton.addAction(.init(handler: { _ in
            RootViewController.instance.reset()
        }), for: .touchUpInside)
    }
    
    override func showCodeController(_ email: String) {
        onboardingParent?.reset(OnboardingWalletCodeController(email: email, profile: profile, session: session), animated: false)
    }
}
