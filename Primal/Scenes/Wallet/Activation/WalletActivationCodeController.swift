//
//  WalletActivationCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.2.24..
//

import Combine
import UIKit

class WalletActivationCodeController: UIViewController {
    var iconTextColor: UIColor { .foreground }
    var inputBackgroundColor: UIColor { .background3 }
    var inputTextColor: UIColor { .foreground }
    var confirmButton: UIControl { confButton }
    
    let mainStack = UIStackView(axis: .vertical, [])
    
    private let codeInput = StopSelectActionTextField()
    
    private let confButton = LargeRoundedButton(title: "Finish")
    
    private var cancellables = Set<AnyCancellable>()
    
    let email: String
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func showSummary(_ newAddress: String) {
        present(WalletTransferSummaryController(.walletActivated(newAddress: newAddress)), animated: true) {
            self.navigationController?.viewControllers.removeAll(where: { $0 as? WalletActivateViewController != nil })
            self.navigationController?.viewControllers.remove(object: self)
        }
    }
    
    var userProfile: NostrProfile? {
        IdentityManager.instance.parsedUser?.data.profileData
    }
}

private extension WalletActivationCodeController {
    func setup() {
        title = "Activate Wallet"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let icon = UIImageView(image: UIImage(named: "walletFilledLarge"))
        icon.tintColor = iconTextColor
        icon.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        icon.contentMode = .scaleAspectFit
        
        let iconParent = UIView()
        iconParent.addSubview(icon)
        icon.pinToSuperview(edges: .vertical).centerToSuperview()
        
        let title = UILabel()
        title.text = "Check Your Email"
        title.font = .appFont(withSize: 20, weight: .semibold)
        title.textColor = iconTextColor
        title.textAlignment = .center
        
        let activationText = NSMutableAttributedString(string: "Your activation code was sent to ", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: iconTextColor
        ])
        activationText.append(.init(string: email, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .bold),
            .foregroundColor: iconTextColor
        ]))
        activationText.append(.init(string: ". You may need to check your Junk or Spam folder.", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: iconTextColor
        ]))
        
        let subTitle = UILabel()
        subTitle.attributedText = activationText
        subTitle.textAlignment = .center
        subTitle.numberOfLines = 0
        
        [
            SpacerView(height: 32),
            iconParent,                 SpacerView(height: 69, priority: .defaultLow),
            title,                      SpacerView(height: 12),
            subTitle,                   SpacerView(height: 18),
            inputParent(codeInput),     SpacerView(height: 12, priority: .required),
            UIView(),
            confirmButton
        ].forEach { mainStack.addArrangedSubview($0) }
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal, padding: 36)
        mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -24).isActive = true
        
        [codeInput].forEach {
            $0.font = .appFont(withSize: 32, weight: .bold)
            $0.textColor = inputTextColor
            $0.returnKeyType = .done
            $0.delegate = self
        }
        codeInput.defaultTextAttributes.updateValue(30, forKey: .kern)
        codeInput.keyboardType = .numberPad
        
        codeInput.addAction(.init(handler: { [weak self] _ in
            self?.confirmButton.isEnabled = self?.codeInput.text?.count == 6
        }), for: .editingChanged)
        
        confirmButton.isEnabled = false
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
                
                showSummary(newAddress)
                
                WalletManager.instance.didJustCreateWallet = true
                WalletManager.instance.isLoadingWallet = false
                WalletManager.instance.userHasWallet = true
                
                guard let profile = userProfile else { return }
                profile.lud16 = newAddress
                IdentityManager.instance.updateProfile(profile) { success in
                    if !success {
                        RootViewController.instance.showErrorMessage("Unable to update profile lud16 address to \(newAddress)")
                    } else {
                        IdentityManager.instance.requestUserProfile(local: false)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func inputParent(_ input: UIView) -> UIView {
        let view = UIView()
        
        let backgroundViews = (1...6).map { _ in
            let view = UIView()
            view.backgroundColor = inputBackgroundColor
            view.layer.cornerRadius = 12
            return view
        }
        let stack = UIStackView(backgroundViews)
        stack.distribution = .fillEqually
        stack.spacing = 6
        
        view.addSubview(stack)
        stack.constrainToSize(width: 290, height: 56).pinToSuperview(edges: .vertical).centerToSuperview()
        
        view.addSubview(input)
        input.pin(to: stack, edges: .leading, padding: 10).pinToSuperview(edges: .trailing).centerToSuperview(axis: .vertical)
        
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let selection = textField.selectedTextRange, !selection.isEmpty {
            textField.selectedTextRange = textField.textRange(from: selection.end, to: selection.end)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string).count
        
        return newLength <= 6
    }
}

final class StopSelectActionTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)){
            return true
        }
        return false
    }
}
