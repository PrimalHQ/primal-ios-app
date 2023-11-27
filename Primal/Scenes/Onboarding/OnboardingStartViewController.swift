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
    let termsBothLines = UIStackView(axis: .vertical, [])
    
    let signupButton = OnboardingMainButton("Create Account")
    let signinButton = OnboardingMainButton("Sign In")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @objc func signupPressed() {
        onboardingParent?.pushViewController(OnboardingUsernameController(), animated: true)
    }
    
    @objc func signinPressed() {
        onboardingParent?.pushViewController(OnboardingSigninController(), animated: true)
    }
}

private extension OnboardingStartViewController {
    func setup() {
        let background = UIImageView(image: UIImage(named: "onboardingBackground"))
        view.addSubview(background)
        background.pinToSuperview(edges: [.vertical, .leading])
        background.contentMode = .scaleAspectFit
        background.widthAnchor.constraint(equalTo: background.heightAnchor, multiplier: 1875 / 812).isActive = true
        
        view.addSubview(screenshot)
        screenshot.pinToSuperview(edges: .leading, padding: 1).pinToSuperview(edges: .trailing, padding: -16)
            
        let firstLine = UILabel()
        let secondLine = UILabel()
        let terms = UILabel()
        
        let secondRow = UIStackView([secondLine, terms])
        
        termsBothLines.addArrangedSubview(firstLine)
        termsBothLines.addArrangedSubview(secondRow)
        termsBothLines.alignment = .center
        
        [firstLine, secondLine].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
            $0.textColor = .white
        }
        
        firstLine.text = "By proceeding you confirm that you"
        secondLine.text = "accept our "
        terms.attributedText = NSAttributedString(string: "terms of service", attributes: [
            .underlineStyle:  NSUnderlineStyle.single.rawValue,
            .font:            UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.white
        ])
        terms.isUserInteractionEnabled = true
        terms.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsTapped)))
        
        [firstLine, secondRow, terms].forEach { $0.setContentCompressionResistancePriority(.required, for: .vertical) }
        
        let welcomeLabel = UILabel()
        welcomeLabel.text = "welcome to nostr"
        welcomeLabel.font = .appFont(withSize: 28, weight: .bold)
        welcomeLabel.textColor = .white
        let welcomeRow = UIStackView([welcomeLabel, UIImageView(image: UIImage(named: "onboardingNostrich"))])
        welcomeRow.alignment = .center
        welcomeRow.spacing = 7
        let welcomeRowParent = UIView()
        welcomeRowParent.addSubview(welcomeRow)
        welcomeRow.centerToSuperview().pinToSuperview(edges: .vertical)
        
        let contentStack = UIStackView(arrangedSubviews: [
            welcomeRowParent,     SpacerView(height: 16),
            signinButton,   SpacerView(height: 12),
            signupButton,   SpacerView(height: 24),
            termsBothLines
        ])
        contentStack.axis = .vertical
        
        view.addSubview(contentStack)
        contentStack
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 25, safeArea: true)
        
        screenshot.contentMode = .scaleAspectFit
        
        let mainScreenshotTopC = screenshot.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
        let screenshotTopC = screenshot.topAnchor.constraint(equalTo: view.topAnchor, constant: 95)
        screenshotTopC.priority = .defaultLow
        let screenshotBottomC = screenshot.bottomAnchor.constraint(lessThanOrEqualTo: contentStack.topAnchor, constant: 40)
        NSLayoutConstraint.activate([mainScreenshotTopC, screenshotTopC, screenshotBottomC])
        
        signupButton.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
    }
    
    @objc func termsTapped() {
        present(SFSafariViewController(url: URL(string: "https://primal.net/terms")!), animated: true)
    }
}
