//
//  OnboardingStartViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SafariServices
import Kingfisher

final class OnboardingMainButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    init(_ title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        titleLabel?.font = .appFont(withSize: 18, weight: .semibold)
        backgroundColor = .black.withAlphaComponent(0.81)
        layer.cornerRadius = 28
        constrainToSize(height: 56)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class OnboardingStartViewController: UIViewController, OnboardingViewController {
    let titleLabel = UILabel()
    let backButton: UIButton = .init()
    
    let screenshot = UIImageView(image: UIImage(named: "screenshotOnboarding"))
    let termsBothLines = TermsAndConditionsView(whiteOverride: true)
    
    let signupButton = OnboardingMainButton("Create Account")
    let signinButton = OnboardingMainButton("Sign In")
    let redeemCodeButton = OnboardingMainButton("Redeem Code")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @objc func signupPressed() {
        onboardingParent?.pushViewController(OnboardingDisplayNameController(), animated: true)
    }
    
    @objc func signinPressed() {
        onboardingParent?.pushViewController(OnboardingSigninController(), animated: true)
    }
}

private extension OnboardingStartViewController {
    func setup() {
        let view = UIView()
        
        let background = UIImageView(image: UIImage(named: "onboardingBackground"))
        self.view.addSubview(background)
        self.view.addSubview(view)
        background.pinToSuperview(edges: [.vertical, .leading])
        background.contentMode = .scaleAspectFit
        background.widthAnchor.constraint(equalTo: background.heightAnchor, multiplier: 1875 / 812).isActive = true
        
        view.addSubview(screenshot)
        screenshot.pinToSuperview(edges: .horizontal, padding: 36)
        
        let logo = UIImageView(image: .onboardingLogo)
        let logoParent = UIView()
        logoParent.addSubview(logo)
        logo.centerToSuperview().pinToSuperview(edges: .vertical)
        
        let contentStack = UIStackView(arrangedSubviews: [
            logoParent,         SpacerView(height: 25, priority: .defaultHigh),
            signinButton,       SpacerView(height: 10, priority: .defaultHigh),
            signupButton,       SpacerView(height: 10, priority: .defaultHigh),
//            redeemCodeButton,   SpacerView(height: 18, priority: .defaultHigh),
            termsBothLines
        ])
        contentStack.axis = .vertical
        
        view.addSubview(contentStack)
        contentStack
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        
        screenshot.contentMode = .scaleAspectFit
        
        let mainScreenshotTopC = screenshot.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor)
        let screenshotTopC = screenshot.topAnchor.constraint(equalTo: view.topAnchor, constant: 85)
        screenshotTopC.priority = .defaultLow
        let screenshotBottomC = screenshot.bottomAnchor.constraint(lessThanOrEqualTo: contentStack.topAnchor, constant: 0)
        NSLayoutConstraint.activate([mainScreenshotTopC, screenshotTopC, screenshotBottomC])
        
        signupButton.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
        redeemCodeButton.addAction(.init(handler: { [weak self] _ in
            self?.onboardingParent?.pushViewController(OnboardingScanCodeController(), animated: true)
        }), for: .touchUpInside)
        
        view.constrainToSize(width: 375, height: 800)
        view.centerToSuperview(axis: .horizontal)
        let centerYC = view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        centerYC.priority = .defaultHigh
        centerYC.isActive = true
        view.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let scale = UIScreen.main.bounds.width / 375
        
        view.transform = .init(scaleX: scale, y: scale)
    }
}
