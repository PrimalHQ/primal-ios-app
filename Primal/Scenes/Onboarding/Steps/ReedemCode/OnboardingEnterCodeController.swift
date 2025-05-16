//
//  OnboardingEnterCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.5.25..
//

import Combine
import UIKit

class OnboardingEnterCodeController: UIViewController, OnboardingViewController, PromotionCodeChecker {
    var iconTextColor: UIColor { .white }
    var inputBackgroundColor: UIColor { .white.withAlphaComponent(0.8) }
    var inputTextColor: UIColor { .init(rgb: 0x111111) }
    var confirmButton: UIControl { confButton }
    
    let mainStack = UIStackView(axis: .vertical, [])
    
    private let codeInput = StopSelectActionTextField()
    
    private let confButton = OnboardingMainButton("Apply Code")
    
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    let errorMessage = UILabel()
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var checking = false
    @Published var currentText = ""
    
    convenience init(startingCode: String) {
        self.init(nibName: nil, bundle: nil)
        
        codeInput.text = startingCode
        currentText = startingCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackground(1)
        addNavigationBar("Enter Your Code")
        titleLabel.textAlignment = .center
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.codeInput.becomeFirstResponder()
        }
    }
    
    var userProfile: NostrProfile? {
        IdentityManager.instance.parsedUser?.data.profileData
    }
}

private extension OnboardingEnterCodeController {
    func setup() {
        let title = UILabel()
        title.text = "If you have an Invite Code, or a\nPrimal Gift Card, you can redeem it here."
        title.font = .appFont(withSize: 16, weight: .regular)
        title.textColor = iconTextColor
        title.textAlignment = .center
        title.numberOfLines = 0
        
        [
            title,                      SpacerView(height: 12),
            inputParent(codeInput),
            UIView(),
            confirmButton
        ].forEach { mainStack.addArrangedSubview($0) }
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, padding: 200, safeArea: true).pinToSuperview(edges: .horizontal, padding: 36)
        mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -24).isActive = true
        
        view.addSubview(errorMessage)
        errorMessage.centerToSuperview(axis: .horizontal).pin(to: codeInput, edges: .top, padding: 50)
        
        [codeInput].forEach {
            $0.font = .monospacedSystemFont(ofSize: 26, weight: .bold)
            $0.textColor = inputTextColor
            $0.returnKeyType = .done
            $0.delegate = self
        }
        codeInput.defaultTextAttributes.updateValue(25.7, forKey: .kern)
        codeInput.keyboardType = .alphabet
        codeInput.autocapitalizationType = .allCharacters
        codeInput.autocorrectionType = .no
        
        errorMessage.constrainToSize(height: 22)
        errorMessage.isHidden = true
        errorMessage.layer.cornerRadius = 11
        errorMessage.layer.masksToBounds = true
        errorMessage.backgroundColor = .init(rgb: 0xE20505)
        errorMessage.textColor = .white
        errorMessage.font = .appFont(withSize: 14, weight: .regular)
        
        codeInput.addAction(.init(handler: { [weak self] _ in
            self?.currentText = self?.codeInput.text ?? ""
        }), for: .editingChanged)
        
        confirmButton.isEnabled = false
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmButtonPressed()
        }), for: .touchUpInside)
        
        Publishers.CombineLatest($checking, $currentText)
            .sink { [weak self] isChecking, currentText in
                self?.confirmButton.isEnabled = !isChecking && currentText.count == 8
                self?.errorMessage.isHidden = true
            }
            .store(in: &cancellables)
    }
    
    func confirmButtonPressed() {
        guard let code = codeInput.text, code.count == 8 else { codeInput.becomeFirstResponder(); return }
        
        checking = true
        
        checkPromotionCode(code) { [weak self] result in
            self?.checking = false
            
            switch result {
            case .success(let info):
                self?.onboardingParent?.pushViewController(OnboardingPreviewCodeController(info: info, code: code), animated: true)
            case .failure(let message):
                self?.errorMessage.text = "  \(message)  "
                self?.errorMessage.isHidden = false
            }
        }
    }
    
    func inputParent(_ input: UIView) -> UIView {
        let view = UIView()
        
        let backgroundViews = (1...8).map { _ in
            let view = UIView()
            view.backgroundColor = inputBackgroundColor
            view.layer.cornerRadius = 12
            return view
        }
        let stack = UIStackView(backgroundViews)
        stack.distribution = .fillEqually
        stack.spacing = 6
        
        view.addSubview(stack)
        stack.constrainToSize(width: 330, height: 46).pinToSuperview(edges: .vertical).centerToSuperview()
        
        view.addSubview(input)
        input.pin(to: stack, edges: .leading, padding: 10).pinToSuperview(edges: .trailing, padding: -10).centerToSuperview(axis: .vertical)
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: {
            input.becomeFirstResponder()
        }))
        return view
    }
}

extension OnboardingEnterCodeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        confirmButtonPressed()
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let selection = textField.selectedTextRange, !selection.isEmpty {
            textField.selectedTextRange = textField.textRange(from: selection.end, to: selection.end)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string).count
        
        return newLength <= 8
    }
}
