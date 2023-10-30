//
//  WalletActivateViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import Combine
import UIKit

final class WalletActivateViewController: UIViewController {
    
    private let descLabel = UILabel()
    private let nameInput = UITextField()
    private let emailInput = UITextField()
    private let codeInput = UITextField()
    
    private let confirmButton = LargeRoundedButton(title: "Next")
    
    private var isWaitingForCode = false {
        didSet {
            UIView.transition(with: view, duration: 0.3) {
                self.nameInput.superview?.isHidden = self.isWaitingForCode
                self.emailInput.superview?.isHidden = self.isWaitingForCode
                self.codeInput.superview?.isHidden = !self.isWaitingForCode
                self.nameInput.superview?.alpha = self.isWaitingForCode ? 0 : 1
                self.emailInput.superview?.alpha = self.isWaitingForCode ? 0 : 1
                self.codeInput.superview?.alpha = self.isWaitingForCode ? 1 : 0
                self.descLabel.text = self.isWaitingForCode ? "We emailed your activation code.\nPlease enter it below:" : "Activating your wallet is easy!\nAll we need is your name\nand email address:"
                self.confirmButton.title = self.isWaitingForCode ? "Finish" : "Next"
                self.confirmButton.isEnabled = !self.isWaitingForCode
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
}

private extension WalletActivateViewController {
    func setup() {
        title = "Activate Wallet"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let icon = UIImageView(image: UIImage(named: "walletFilledLarge"))
        icon.tintColor = .foreground
        icon.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        icon.contentMode = .scaleAspectFit
        
        let iconParent = UIView()
        iconParent.addSubview(icon)
        icon.pinToSuperview(edges: .vertical).centerToSuperview()
        
        let contentStack = UIStackView(axis: .vertical, [descLabel, inputParent(nameInput), inputParent(emailInput), inputParent(codeInput)])
        contentStack.spacing = 25
        contentStack.setCustomSpacing(36, after: descLabel)
        
        codeInput.superview?.isHidden = true
        codeInput.superview?.alpha = 0
        
        let iconStack = UIStackView(axis: .vertical, [iconParent, SpacerView(height: 32)])
        let mainStack = UIStackView(axis: .vertical, [SpacerView(height: 32), iconStack, contentStack, SpacerView(height: 32), confirmButton])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal, padding: 36)
        mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -24).isActive = true
        
        descLabel.text = "Activating your wallet is easy!\nAll we need is your name\nand email address:"
        descLabel.font = .appFont(withSize: 18, weight: .semibold)
        descLabel.textColor = .foreground
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical )
        
        [nameInput, emailInput, codeInput].forEach {
            $0.font = .appFont(withSize: 18, weight: .regular)
            $0.textColor = .foreground
            $0.returnKeyType = .done
            $0.delegate = self
        }
        
        nameInput.placeholder = "your name"
        emailInput.placeholder = "your email address"
        codeInput.placeholder = "activation code"
        
        nameInput.keyboardType = .namePhonePad
        emailInput.keyboardType = .emailAddress
        codeInput.keyboardType = .numberPad
        
        nameInput.autocapitalizationType = .words
        emailInput.autocapitalizationType = .none
        
        codeInput.addAction(.init(handler: { [weak self] _ in
            self?.confirmButton.isEnabled = self?.codeInput.text?.count == 6
        }), for: .editingChanged)
        
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmButtonPressed()
        }), for: .touchUpInside)
    }
    
    func confirmButtonPressed() {
        guard isWaitingForCode else {
            guard let name = nameInput.text, !name.isEmpty else { nameInput.becomeFirstResponder(); return }
            guard let email = emailInput.text, !email.isEmpty else { emailInput.becomeFirstResponder(); return }

            guard email.isEmail else {
                emailInput.becomeFirstResponder()
                emailInput.selectAll(nil)
                return
            }
            
            nameInput.resignFirstResponder()
            emailInput.resignFirstResponder()
            
            isWaitingForCode = true
            
            PrimalWalletRequest(type: .activationCode(name: name, email: email)).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    if let error = res.message {
                        self?.isWaitingForCode = false
                        self?.present(WalletTransferSummaryController(.failure(navTitle: "Error", title: "Activation failed", message: error)), animated: true)
                    }
                }
                .store(in: &cancellables)
            return
        }
        
        guard let code = codeInput.text, code.count == 6 else { codeInput.becomeFirstResponder(); return }
        
        codeInput.resignFirstResponder()
        codeInput.isUserInteractionEnabled = false
        confirmButton.isEnabled = false
        
        PrimalWalletRequest(type: .activate(code: code)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                guard let self else { return }
                
                self.codeInput.isUserInteractionEnabled = true
                
                guard let newAddress = res.newAddress else {
                    self.codeInput.text = ""
                    self.codeInput.becomeFirstResponder()
                    return
                }
                
                self.confirmButton.isEnabled = true
                
                WalletManager.instance.isLoadingWallet = false
                WalletManager.instance.userHasWallet = true
                
                self.present(WalletTransferSummaryController(.walletActivated(newAddress: newAddress)), animated: true) {
                    self.navigationController?.viewControllers.remove(object: self)
                }
                
                guard let profile = IdentityManager.instance.user?.profileData else { return }
                profile.lud16 = newAddress
                IdentityManager.instance.updateProfile(profile) { success in
                    if !success {
                        RootViewController.instance.showErrorMessage("Unable to update profile lud16 address to \(newAddress)")
                    } else {
                        IdentityManager.instance.requestUserProfile()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func inputParent(_ input: UITextField) -> UIView {
        let view = UIView()
        view.addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        
        view.backgroundColor = .background3
        view.constrainToSize(height: 48)
        view.layer.cornerRadius = 24
        
        view.addGestureRecognizer(BindableGestureRecognizer(action: {
            input.becomeFirstResponder()
        }))
        
        return view
    }
}

extension WalletActivateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
