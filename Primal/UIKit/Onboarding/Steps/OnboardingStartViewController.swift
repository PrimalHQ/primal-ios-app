//
//  OnboardingStartViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

class OnboardingStartViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @objc func signupPressed() {
        
    }
    
    @objc func signinPressed() {
        let signIn = OnboardingSigninController()
        show(signIn, sender: nil)
    }
}

private extension OnboardingStartViewController {
    func setup() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logoTitle"))
        view.backgroundColor = .black
        
        let screenshotParent = UIView()
        let screenshot = UIImageView(image: UIImage(named: "screenshotOnboarding"))
        let fade = UIImageView(image: UIImage(named: "bottomFade"))
        
        screenshotParent.addSubview(screenshot)
        screenshotParent.addSubview(fade)
        
        screenshot.pinToSuperview(edges: .bottom).centerToSuperview(axis: .horizontal)
        let topC = screenshot.topAnchor.constraint(equalTo: screenshotParent.topAnchor)
        topC.priority = .defaultLow
        topC.isActive = true
            
        fade.pinToSuperview(edges: [.horizontal, .bottom])
        
        let signup = BigOnboardingButton(title: "Create account",
            subtitle: "Your new Nostr account will be up and running in a minute"
        )
        let signin = BigOnboardingButton(title: "Sign in",
            subtitle: "Already have a Nostr account? Sign in via Apple or your Nostr key."
        )
        
        let buttonStack = UIStackView(arrangedSubviews: [signup, signin, UIView()])
        let stack = UIStackView(arrangedSubviews: [screenshotParent, buttonStack])
        
        stack.axis = .vertical
        stack.spacing = 40
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 20
        buttonStack.distribution = .equalCentering
        buttonStack.layoutMargins = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        buttonStack.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, safeArea: true)
        
        signup.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        signin.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
    }
}