//
//  OnboardingTwitterController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import UIKit

class OnboardingTwitterController: UIViewController {
    enum State {
        case ready
        case created
    }
    
    private var state = State.ready {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.updateView()
            }
        }
    }
    
    let profile: TwitterUserRequest.Response
    
    lazy var progressView = PrimalProgressView(progress: 3, total: 4)
    let twitterView = LargeTwitterProfileView()
    let successLabel = UILabel()
    let instructionLabel = UILabel()
    let continueButton = FancyButton(title: "Create Nostr account")
    let keychainInfo = KeyKeychainInfoView()
    
    init(profile: TwitterUserRequest.Response) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
//        let acb = AccountCreationBootstrapper()
//        acb.initProfile(nickName: profile.username, displayName: profile.displayname, about: profile.bio, pictureUrl: profile.avatar, bannerUrl: profile.banner)
//        acb.signup {
//            print("success!")
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingTwitterController {
    func updateView() {
        switch state {
        case .ready:
            title = "Twitter profile found"
            continueButton.titleLabel.text = "Create Nostr account"
            keychainInfo.alpha = 0
            keychainInfo.isHidden = true
            instructionLabel.alpha = 1
            instructionLabel.isHidden = false
            successLabel.alpha = 0
            twitterView.layer.borderColor = UIColor.white.cgColor
            progressView.progress = 3
        case .created:
            title = "Nostr account created"
            continueButton.titleLabel.text = "Find people to follow"
            keychainInfo.alpha = 1
            keychainInfo.isHidden = false
            instructionLabel.alpha = 0
            instructionLabel.isHidden = true
            successLabel.alpha = 1
            twitterView.layer.borderColor = UIColor(rgb: 0x66E205).cgColor
            progressView.progress = 4
        }
    }
    
    func setup() {
        navigationItem.title = "Twitter profile found"
        view.backgroundColor = .black
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        view.addSubview(progressView)
        progressView.pinToSuperview(edges: .top, safeArea: true).centerToSuperview(axis: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [twitterView, successLabel, instructionLabel, keychainInfo, UIView(), continueButton])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical, padding: 30, safeArea: true)
        
        twitterView.setContentHuggingPriority(.required, for: .vertical)
        twitterView.profile = profile
        
        successLabel.text = "Your Nostr account has been created!"
        successLabel.font = .appFont(withSize: 14, weight: .regular)
        successLabel.textColor = UIColor(rgb: 0x66E205)
        successLabel.textAlignment = .center
        
        instructionLabel.text = "We will use this info to create your Nostr account. If you wish to make any changes, you can always do so in your profile settings."
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .init(rgb: 0xAAAAAA)
        instructionLabel.textAlignment = .center
        instructionLabel.font = .appFont(withSize: 20, weight: .regular)
        
        stack.axis = .vertical
        stack.spacing = 6
        stack.setCustomSpacing(20, after: successLabel)
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        updateView()
    }
    
    @objc func continuePressed() {
        switch state {
        case .ready:
            state = .created
        case .created:
            let suggestions = OnboardingFollowSuggestionsController()
            show(suggestions, sender: nil)
        }
    }
}

class KeyKeychainInfoView: UIView {
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let keyIcon = UIImageView(image: UIImage(named: "keyKeychain"))
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        let hStack = UIStackView(arrangedSubviews: [keyIcon, titleLabel])
        let vStack = UIStackView(arrangedSubviews: [hStack, subtitleLabel])
        
        addSubview(vStack)
        vStack.pinToSuperview(padding: 20)
        vStack.axis = .vertical
        vStack.spacing = 16
        
        hStack.alignment = .center
        hStack.spacing = 12
        
        titleLabel.text = "Your Nostr key is safely stored on your Apple keychain."
        titleLabel.textColor = .white
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        
        subtitleLabel.text = "You can use the “Sign in with Apple” option in the future. You can also access your key in the Primal app settings."
        subtitleLabel.textColor = .init(rgb: 0xAAAAAA)
        subtitleLabel.font = .appFont(withSize: 16, weight: .regular)
        subtitleLabel.numberOfLines = 4
        subtitleLabel.adjustsFontSizeToFitWidth = true
        
        backgroundColor = .init(rgb: 0x181818)
        layer.cornerRadius = 12
    }
}
