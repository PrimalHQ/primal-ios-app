//
//  OnboardingStartViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

final class OnboardingStartViewController: UIViewController {
    let screenshotParent = UIView()
    
    let signupButton = BigOnboardingButton(
        title: "Create account",
        subtitle: "Your new Nostr account will be up and running in a minute"
    )
    let signinButton = BigOnboardingButton(
        title: "Sign in",
        subtitle: "Already have a Nostr account? Sign in via Apple or your Nostr key."
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = UIDevice.modelName
        
        if model.contains("Max") || model.contains("Plus") {
            setupLargeScreen()
        } else {
            setup()
        }
    }
    
    @objc func signupPressed() {
        let signUp = OnboardingSignUpStartController()
        show(signUp, sender: nil)
    }
    
    @objc func signinPressed() {
        let view = ICloudKeychain.instance.hasSavedNpubs()
            ? OnboardingExistingICloudKeychainLoginsViewController()
            : OnboardingSigninController()

        show(view, sender: nil)
    }
}

private extension OnboardingStartViewController {
    func setup() {
        let stack = commonSetup()
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, safeArea: true)
    }
    
    func setupLargeScreen() {
        let stack = commonSetup()
        
        let scaledParentView = UIView()
        scaledParentView.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, safeArea: true)
        
        view.addSubview(scaledParentView)
        scaledParentView.centerToSuperview()
        NSLayoutConstraint.activate([
            scaledParentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/10),
            scaledParentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 9/10)
        ])
        
        scaledParentView.transform = .init(scaleX: 10/9, y: 10/9)
    }
    
    func commonSetup() -> UIView {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logoTitle"))
        view.backgroundColor = .black
        
        let screenshot = UIImageView(image: UIImage(named: "screenshotOnboarding"))
        let fade = UIImageView(image: UIImage(named: "bottomFade"))
        
        screenshotParent.addSubview(screenshot)
        screenshotParent.addSubview(fade)
        
        screenshot.pinToSuperview(edges: .bottom).centerToSuperview(axis: .horizontal)
        let topC = screenshot.topAnchor.constraint(equalTo: screenshotParent.topAnchor)
        topC.priority = .defaultLow
        topC.isActive = true
            
        fade.pinToSuperview(edges: [.horizontal, .bottom])
        
        let buttonStack = UIStackView(arrangedSubviews: [signupButton, signinButton, UIView()])
        let stack = UIStackView(arrangedSubviews: [screenshotParent, buttonStack])
        
        stack.axis = .vertical
        stack.spacing = 40
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 20
        buttonStack.layoutMargins = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        buttonStack.isLayoutMarginsRelativeArrangement = true
        
        signupButton.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
        
        return stack
    }
}
