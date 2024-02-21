//
//  WalletActivationCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.2.24..
//

import Combine
import UIKit

final class WalletActivationCodeController: UIViewController {
    private let codeInput = UITextField()
    
    private let confirmButton = LargeRoundedButton(title: "Finish")
    
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

private extension WalletActivationCodeController {
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
        
        let iconStack = UIStackView(axis: .vertical, [iconParent, SpacerView(height: 32)])
        let spacerStack = UIStackView(axis: .vertical, [SpacerView(height: 16, priority: .required), SpacerView(height: 16)])
        let mainStack = UIStackView(axis: .vertical, [SpacerView(height: 32), iconStack, inputParent(codeInput), spacerStack, confirmButton])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal, padding: 36)
        mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -24).isActive = true
        
        [codeInput].forEach {
            $0.font = .appFont(withSize: 18, weight: .bold)
            $0.textColor = .foreground
            $0.returnKeyType = .done
            $0.delegate = self
        }
        
        [
            (codeInput, "activation code"),
        ].forEach { field, text in
            field.attributedPlaceholder = NSAttributedString(string: text, attributes: [
                .font: UIFont.appFont(withSize: 18, weight: .regular),
                .foregroundColor: UIColor.foreground4
            ])
        }
        
        codeInput.keyboardType = .numberPad
        
        codeInput.addAction(.init(handler: { [weak self] _ in
            self?.confirmButton.isEnabled = self?.codeInput.text?.count == 6
        }), for: .editingChanged)
        
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmButtonPressed()
        }), for: .touchUpInside)
    }
    
    func confirmButtonPressed() {
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
                
                WalletManager.instance.didJustCreateWallet = true
                WalletManager.instance.isLoadingWallet = false
                WalletManager.instance.userHasWallet = true
                
                self.present(WalletTransferSummaryController(.walletActivated(newAddress: newAddress)), animated: true) {
                    self.navigationController?.viewControllers.remove(object: self)
                    self.navigationController?.viewControllers.removeAll(where: { $0 as? WalletActivateViewController != nil })
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
    
    func inputParent(_ input: UIView) -> UIView {
        let view = UIView()
        view.addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        
        view.backgroundColor = .background3
        view.constrainToSize(height: 48)
        view.layer.cornerRadius = 24
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: {
            input.becomeFirstResponder()
        }))
        
        return view
    }
}

extension WalletActivationCodeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
