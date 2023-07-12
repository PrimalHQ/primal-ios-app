//
//  OnboardingSigninController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI

final class OnboardingSigninController: UIViewController {
    
    enum State {
        case ready
        case invalidKey
        case validKey
    }
    
    lazy var progressView = PrimalProgressView(progress: 1, total: 2)
    lazy var textView = UITextView()
    lazy var textViewParent = UIView()
    lazy var infoLabel = UILabel()
    lazy var placeholderLabel = UILabel()
    
    lazy var confirmButton = FancyButton(title: "Paste your key")
    
    private var foregroundObserver: NSObjectProtocol?
    
    private var state = State.ready {
        didSet {
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) { [weak self] in
            self?.validateAndProcessKey()
        }

        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] notification in
            self?.validateAndProcessKey()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

private extension OnboardingSigninController {
    func updateView() {
        switch state {
        case .ready:
            confirmButton.titleLabel.text = "Paste your key"
            progressView.progress = 1
            
            textViewParent.layer.borderWidth = 0
            textView.isEditable = true
            infoLabel.isHidden = true
        case .invalidKey:
            confirmButton.titleLabel.text = "Paste new key"
            progressView.progress = 1
            
            textViewParent.layer.borderColor = UIColor(rgb: 0xE20505).withAlphaComponent(0.5).cgColor
            textViewParent.layer.borderWidth = 1
            infoLabel.isHidden = false
            infoLabel.text = "Please enter a valid Nostr key"
            infoLabel.textColor = .init(rgb: 0xE20505)
            
            textView.isEditable = true
        case .validKey:
            confirmButton.titleLabel.text = "Sign In"
            progressView.progress = 2
            
            textViewParent.layer.borderColor = UIColor(rgb: 0x66E205).withAlphaComponent(0.5).cgColor
            textViewParent.layer.borderWidth = 1
            infoLabel.isHidden = false
            infoLabel.text = "Valid key confirmed"
            infoLabel.textColor = .init(rgb: 0x66E205)
        }
    }
    
    func setup() {
        let progressParent = UIView()
        let instruction = UILabel()
        let textStack = UIStackView(arrangedSubviews: [instruction, textViewParent, infoLabel])
        let mainStack = UIStackView(arrangedSubviews: [progressParent, textStack, confirmButton])
        
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
        
        textViewParent.addSubview(placeholderLabel)
        textViewParent.addSubview(textView)
        textView.pinToSuperview(padding: 10).constrainToSize(height: 88)
        textView.backgroundColor = .clear
        textView.delegate = self
        textViewParent.backgroundColor = .init(rgb: 0x181818)
        textViewParent.layer.cornerRadius = 12
        textViewParent.layer.borderColor = UIColor(rgb: 0x222222).cgColor
        textViewParent.layer.borderWidth = 1
        
        placeholderLabel.centerToView(textView)
        placeholderLabel.text = "nsec / npub"
        placeholderLabel.textColor = .init(rgb: 0x666666)
        placeholderLabel.font = .appFont(withSize: 18, weight: .medium)
        
        textView.font = .appFont(withSize: 18, weight: .medium)
        textView.textColor = .init(rgb: 0xCCCCCC)
        
        infoLabel.font = .appFont(withSize: 14, weight: .regular)
        infoLabel.textAlignment = .center
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 36)
            .bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20).isActive = true
        
        
        mainStack.axis = .vertical
        textStack.axis = .vertical
        
        mainStack.distribution = .equalSpacing
        
        textStack.spacing = 10
        textStack.setCustomSpacing(24, after: instruction)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
    }
    
    func pasteIfPossible() {
        guard
            UIPasteboard.general.hasStrings,
            let pasted = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return }
        
        textView.text = pasted
        placeholderLabel.isHidden = !pasted.isEmpty
    }
    
    func validateAndProcessKey(paste: Bool = false) {
        if paste {
            pasteIfPossible()
        }
        
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            if !paste {
                validateAndProcessKey(paste: true)
                return
            }
            state = .ready
            return
        }
        
        guard let parsed = parse_key(text), !parsed.is_pub // allow only nsec for now
        else {
            if !paste {
                validateAndProcessKey(paste: true)
                return
            }
            state = .invalidKey
            return
        }
        
        if let error = get_error(parsed_key: parsed) {
            if !paste {
                validateAndProcessKey(paste: true)
                return
            }
            state = .invalidKey
            showErrorMessage(error)
            return
        }
        
        state = .validKey
    }
    
    func signIn() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            state = .ready
            return
        }
        
        guard let parsed = parse_key(text), !parsed.is_pub // allow only nsec for now
        else {
            state = .invalidKey
            return
        }
        
        guard process_login(parsed) else {
            state = .invalidKey
            return
        }
        
        guard
            let keypair = get_saved_keypair(),
            (try? bech32_decode(keypair.npub)) != nil
        else {
            showErrorMessage("Unable to decode key.")
            state = .invalidKey
            return
        }
        
        RootViewController.instance.reset()
    }
    
    // MARK: - UI actions
    
    @objc func confirmButtonPressed() {
        switch state {
        case .ready, .invalidKey:
            validateAndProcessKey()
        case .validKey:
            signIn()
        }
    }
}

extension OnboardingSigninController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
