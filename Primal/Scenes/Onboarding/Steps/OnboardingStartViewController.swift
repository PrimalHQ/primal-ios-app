//
//  OnboardingStartViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SafariServices

final class OnboardingStartViewController: UIViewController {
    let screenshotParent = UIView()
    let termsBothLines = UIStackView(axis: .vertical, [])
    
    let signupButton = BigOnboardingButton(
        title: "Create account",
        subtitle: "Your new Nostr account will be up and running in a minute"
    )
    let signinButton = BigOnboardingButton(
        title: "Sign in",
        subtitle: "Already have a Nostr account? Sign in via your Nostr key."
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
        show(OnboardingCreateAccountController(), sender: nil)
    }
    
    @objc func signinPressed() {
        show(OnboardingSigninController(), sender: nil)
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
        
        let firstLine = UILabel()
        let secondLine = UILabel()
        let terms = UILabel()
        
        let secondRow = UIStackView([secondLine, terms])
        
        termsBothLines.addArrangedSubview(firstLine)
        termsBothLines.addArrangedSubview(secondRow)
        termsBothLines.alignment = .center
        
        [firstLine, secondLine, terms].forEach {
            $0.font = .appFont(withSize: 14, weight: .regular)
            $0.textColor = UIColor(rgb: 0x444444)
        }
        
        firstLine.text = "By proceeding you confirm that you"
        secondLine.text = "accept our "
        terms.text = "terms of service"
        terms.textColor = SunriseWave.instance.accent2
        terms.isUserInteractionEnabled = true
        terms.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsTapped)))
        
        let buttonStack = UIStackView(arrangedSubviews: [signupButton, signinButton, termsBothLines, UIView()])
        let stack = UIStackView(arrangedSubviews: [screenshotParent, buttonStack])
        
        stack.axis = .vertical
        stack.spacing = 35
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 20
        buttonStack.layoutMargins = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        buttonStack.isLayoutMarginsRelativeArrangement = true
        
        signupButton.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
        
        return stack
    }
    
    @objc func termsTapped() {
        present(SFSafariViewController(url: URL(string: "https://primal.net/terms")!), animated: true)
    }
}
