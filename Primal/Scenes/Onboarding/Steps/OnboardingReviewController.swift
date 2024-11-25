//
//  OnboardingReviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.11.24..
//

import Combine
import UIKit
import SafariServices

final class OnboardingReviewController: UIViewController, OnboardingViewController {
    let continueButton = OnboardingMainButton("Activate Wallet")
    let skipButton = SolidColorUIButton(title: "I’ll do this later", color: .white)
    
    let titleLabel: UILabel = .init()
    let backButton = UIButton()
    
    var cancellables: Set<AnyCancellable> = []
    
    var session: OnboardingSession
    init(session: OnboardingSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingReviewController {
    func setup() {
        addBackground(5)
        addNavigationBar("Create Account")
        backButton.isHidden = true
        
        let botStack = UIStackView(axis: .vertical, [continueButton, skipButton])
        botStack.spacing = 18
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.alignment = .center
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = .init(string: "Nostr is much more\nfun with ZAPS!", attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.appFont(withSize: 24, weight: .bold),
            .paragraphStyle: paragraph
        ])
        
        let descLabel = UILabel()
        descLabel.attributedText = descAttributedString(instructionText)
        descLabel.numberOfLines = 0
        
        let zapIcon = UIImageView(image: UIImage(named: "onboardingLargeZap"))
        zapIcon.setContentHuggingPriority(.required, for: .vertical)
        
        let mainStack = UIStackView(axis: .vertical, [
            zapIcon, SpacerView(height: 48),
            titleLabel, SpacerView(height: 24),
            descLabel
        ])
        mainStack.alignment = .center

        let stack = UIStackView(axis: .vertical, [UIView(), mainStack, botStack])
        stack.distribution = .equalSpacing
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
            .pin(to: self.titleLabel, edges: .top, padding: 30)
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        skipButton.addAction(.init(handler: { _ in
            RootViewController.instance.reset()
        }), for: .touchUpInside)
    }
    
    @objc func continuePressed() {
        onboardingParent?.reset(OnboardingWalletController(session: session), animated: true)   
    }
    
    var instructionText: String { """
    Zaps are small payments that Nostr users send to each other. You can zap a note instead of hitting the like button.

    Activate your Primal Wallet to participate in the Nostr zapping economy and earn money for the awesome content you publish!
"""
    }
}
