//
//  OnboardingSigninController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import Combine
import UIKit
import SwiftUI

final class OnboardingSigninController: UIViewController, OnboardingViewController {
    enum State {
        case ready
        case invalidKey
        case validKey(String)
    }
    
    lazy var infoView = OnboardingProfileInfoView()
    lazy var instruction = UILabel()
    lazy var input = SignInInputField()
    lazy var titleLabel = UILabel()
    lazy var backButton: UIButton = .init()
    
    lazy var confirmButton = OnboardingMainButton("Paste Your Key")
    
    var cancellables = Set<AnyCancellable>()
    
    private var foregroundObserver: NSObjectProtocol?
    
    private var centerInputConstraint: NSLayoutConstraint?
    
    private var state = State.ready {
        didSet {
            self.updateView()
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
            infoView.isHidden = true
            infoView.alpha = 0
            instruction.isHidden = false
            instruction.text = "Enter your Nostr key to sign in:"
            confirmButton.setTitle("Paste Your Key", for: .normal)
            
            input.isCorrect = nil
        case .invalidKey:
            infoView.isHidden = true
            infoView.alpha = 0
            instruction.isHidden = false
            instruction.text = "Please enter a valid Nostr key,\nstarting with “nsec” or “npub”:"
            confirmButton.setTitle("Paste New Key", for: .normal)
            
            input.isCorrect = false
        case .validKey:
            instruction.isHidden = true
            confirmButton.setTitle("Sign In", for: .normal)
            
            input.isCorrect = true
        }
    }
    
    func setup() {
        addBackground(1)
        
        let textStack = UIStackView(arrangedSubviews: [
            infoView,    SpacerView(height: 12, priority: .required), SpacerView(height: 16, priority: .defaultLow),
            instruction, SpacerView(height: 12, priority: .defaultHigh),
            input,       SpacerView(height: 12, priority: .required)
        ])
        
        let mainStack = UIStackView(arrangedSubviews: [UIView(), textStack, confirmButton])
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 36)
            .bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20).isActive = true
        
        centerInputConstraint = NSLayoutConstraint(
            item: input,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 2
        )
        centerInputConstraint?.isActive = true
        
        addNavigationBar("Sign In")
        let topC = mainStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50)
        topC.priority = .init(500)
        topC.isActive = true
        
        infoView.isHidden = true
        
        instruction.font = .appFont(withSize: 16, weight: .semibold)
        instruction.textColor = .white
        instruction.textAlignment = .center
        instruction.numberOfLines = 0
        instruction.text = "Enter your Nostr key to sign in:"
        
        mainStack.axis = .vertical
        textStack.axis = .vertical
        
        mainStack.distribution = .equalSpacing
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.input.resignFirstResponder()
        }))
        
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        
        input.didChange = { [weak self] _ in
            self?.validateAndProcessKey(pasteIfMissing: false)
        }
        
        input.didBeginEditing = { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.centerInputConstraint?.isActive = false
                self?.view.layoutIfNeeded()
            }
        }
        
        input.didEndEditing = { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.centerInputConstraint?.isActive = true
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    func pasteIfPossible() {
        guard
            UIPasteboard.general.hasStrings,
            let pasted = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return }
        
        input.text = pasted
    }
    
    func validateAndProcessKey(pasteIfMissing: Bool = true, paste: Bool = false) {
        if paste {
            pasteIfPossible()
        }
        
        let text = input.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            if pasteIfMissing && !paste {
                validateAndProcessKey(pasteIfMissing: true, paste: true)
                return
            }
            state = .ready
            return
        }
        
        guard NKeypair.isValidNsecOrNpub(text) else {
            if pasteIfMissing && !paste {
                validateAndProcessKey(pasteIfMissing: true, paste: true)
                return
            }
            state = .invalidKey
            return
        }
        
        let shouldLoadAgain: Bool = {
            switch state {
            case let .validKey(oldNsec):
                return oldNsec != text
            default:
                return true
            }
        }()
        
        state = .validKey(text)
        
        guard shouldLoadAgain else { return }
        
        input.resignFirstResponder()
        
        infoView.isHidden = true
        infoView.alpha = 0
        infoView.transform = .init(scaleX: 0.8, y: 0.8)
        
        let pubkeyHex = text.hasPrefix("npub") ? HexKeypair.npubToHexPubkey(text) : {
            guard let hexPrivkey = HexKeypair.nsecToHexPrivkey(text) else { return nil }
            return HexKeypair.privkeyToPubkey(hexPrivkey)
        }()
        
        guard let pubkeyHex else { return }
        
        UserRequest(pubkey: pubkeyHex).publisher()
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] jsonArray in
                let result = PostRequestResult()
                jsonArray.compactMap { $0.objectValue } .forEach { result.handlePostEvent($0) }
                
                guard let self, let user = result.users.first?.value else { return }
                
                let parsed = result.createParsedUser(user)
                
                self.infoView.image.setUserImage(parsed)
                self.infoView.name.text = user.firstIdentifier
                self.infoView.address.text = user.lud16
                
                UIView.transition(with: self.view, duration: 0.3) {
                    self.infoView.isHidden = false
                    self.infoView.alpha = 1
                    self.infoView.transform = .identity
                }
            }
            .store(in: &cancellables)

    }
    
    func signIn(_ nsec: String) {
        guard LoginManager.instance.login(nsec) else {
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
        case .validKey(let nsec):
            signIn(nsec)
        }
    }
}
