//
//  OnboardingSigninController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

class OnboardingSigninController: UIViewController {
    
    lazy var progressView = PrimalProgressView(progress: 1, total: 2)
    lazy var textView = UITextView()
    lazy var textViewParent = UIView()
    lazy var infoLabel = UILabel()
    
    lazy var confirmButton = FancyButton(title: "Paste your key")
    lazy var cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension OnboardingSigninController {
    func setup() {
        let progressParent = UIView()
        let instruction = UILabel()
        let textStack = UIStackView(arrangedSubviews: [instruction, textViewParent, infoLabel])
        let buttonStack = UIStackView(arrangedSubviews: [confirmButton, cancelButton])
        let mainStack = UIStackView(arrangedSubviews: [progressParent, textStack, buttonStack])
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.title = "Sign in"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        view.backgroundColor = .black
        
        progressParent.addSubview(progressView)
        progressView.pinToSuperview(edges: .vertical).centerToSuperview()
        
        instruction.font = .appFont(withSize: 20, weight: .regular)
        instruction.textColor = .init(rgb: 0xAAAAAA)
        instruction.textAlignment = .center
        instruction.adjustsFontSizeToFitWidth = true
        instruction.text = "Paste your Nostr key to sign in:"
        
        textViewParent.addSubview(textView)
        textView.pinToSuperview(padding: 10).constrainToSize(height: 88)
        textView.backgroundColor = .clear
        textViewParent.backgroundColor = .init(rgb: 0x181818)
        textViewParent.layer.cornerRadius = 12
        textViewParent.layer.borderColor = UIColor(rgb: 0x222222).cgColor
        textViewParent.layer.borderWidth = 1
        
        textView.font = .appFont(withSize: 18, weight: .medium)
        textView.textColor = .init(rgb: 0xCCCCCC)
        
        infoLabel.text = "Valid key confirmed"
        infoLabel.font = .appFont(withSize: 14, weight: .regular)
        infoLabel.textColor = .init(rgb: 0x66E205)
        infoLabel.textAlignment = .center
        
        cancelButton.isHidden = true
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 36)
            .bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20).isActive = true
        
        mainStack.axis = .vertical
        textStack.axis = .vertical
        buttonStack.axis = .vertical
        
        mainStack.distribution = .equalSpacing
        buttonStack.spacing = 20
        
        textStack.spacing = 10
        textStack.setCustomSpacing(24, after: instruction)
    }
}
