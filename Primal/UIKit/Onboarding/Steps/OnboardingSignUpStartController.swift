//
//  OnboardingSignUpStartController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.4.23..
//

import UIKit


class OnboardingSignUpStartController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension OnboardingSignUpStartController {
    func setup() {
        title = "Create Account"
        view.backgroundColor = .black
        
        lazy var progressView = PrimalProgressView(progress: 1, total: 4)
        
        let importTwitterButton = BigOnboardingButton(
            title: "Import from Twitter",
            subtitle: "If you have a Twitter account, we will import your profile info & follows."
        )
        let createAccountButton = BigOnboardingButton(title: "Create a new account", subtitle: "If you don’t use Twitter we will help you create a new Nostr account.")
        let buttonStack = UIStackView(arrangedSubviews: [importTwitterButton, createAccountButton])
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.title = "Create account"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        view.backgroundColor = .black
        
        view.addSubview(progressView)
        progressView.pinToSuperview(edges: .top, safeArea: true).centerToSuperview(axis: .horizontal)
        
        view.addSubview(buttonStack)
        buttonStack.pinToSuperview(edges: .horizontal, padding: 36).centerToSuperview()
        buttonStack.spacing = 20
        buttonStack.axis = .vertical
        
        importTwitterButton.addTarget(self, action: #selector(importTwitterPressed), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountPressed), for: .touchUpInside)
    }
    
    @objc func importTwitterPressed() {
        let importTwitter = OnboardingImportTwitterController()
        show(importTwitter, sender: nil)
    }
    
    @objc func createAccountPressed() {
        let suggestions = OnboardingFollowSuggestionsController()
        show(suggestions, sender: nil)
    }
}
