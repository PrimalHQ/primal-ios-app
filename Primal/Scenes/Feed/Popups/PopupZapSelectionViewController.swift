//
//  PopupZapSelectionViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.7.23..
//

import Combine
import UIKit

final class PopupZapSelectionViewController: UIViewController {
    let userToZap: PrimalUser
    
    private var zapOptions: [PrimalZapListSettings] = [] {
        didSet {
            zip(zapOptions, buttons).forEach { option, button in
                button.title = option.amount.shortened()
                button.emoji = option.emoji
            }
            
            messageField.text = zapOptions[safe: selectedOptionIndex]?.message ?? messageField.text
            amountField.text = String(zapOptions[safe: selectedOptionIndex]?.amount ?? 0)
            
            updateView()
        }
    }
    
    private var selectedOptionIndex: Int? = 0 {
        didSet {
            updateView()
            
            guard let selectedOptionIndex else { return }
            
            messageField.resignFirstResponder()
            amountField.resignFirstResponder()
            messageField.text = zapOptions[safe: selectedOptionIndex]?.message ?? messageField.text
            amountField.text = nil
        }
    }
    
    private lazy var buttons = (0...5).map {
        let view = ZapAmountSelectionButton(emoji: "", title: "-")
        view.tag = $0
        view.addAction(.init(handler: { [weak self] _ in
            self?.selectedOptionIndex = view.tag
        }), for: .touchUpInside)
        return view
    }
    
    let zapButton = LargeRoundedButton(title: "Zap")
    
    private let zapLabel = UILabel()
    private let usdLabel = UILabel()
    
    private let amountParent = UIView()
    private let amountField = UITextField()
    private let messageField = UITextField()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userToZap: PrimalUser, _ callback: @escaping (Int, String) -> Void) {
        self.userToZap = userToZap
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] settings in
                guard let options = settings?.zapConfig else { return }
                self?.zapOptions = options
            })
            .store(in: &cancellables)
        
        zapButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true) { 
                let amount = self.zapOptions[safe: self.selectedOptionIndex]?.amount ?? Int(self.amountField.text ?? "") ?? 0
                callback(amount, self.messageField.text ?? "")
            }
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PopupZapSelectionViewController {
    func updateView() {
        for (index, button) in buttons.enumerated() {
            button.zapSelected = index == selectedOptionIndex
        }

        guard let selectedOptionIndex else {
            amountParent.backgroundColor = .background2
            amountParent.layer.borderWidth = 1
            return
        }
        amountParent.layer.borderWidth = 0
        amountParent.backgroundColor = .background3
        
        guard let selectedZapAmount = zapOptions[safe: selectedOptionIndex]?.amount else { return }
        
        let mutable = NSMutableAttributedString(string: "ZAP \(userToZap.firstIdentifier.uppercased()) ", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground3
        ])
        mutable.append(.init(string: selectedZapAmount.shortened().uppercased(), attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground
        ]))
        mutable.append(.init(string: "  SATS", attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .bold),
            .foregroundColor: UIColor.foreground
        ]))
        zapLabel.attributedText = mutable
        
        usdLabel.text = selectedZapAmount.satsToUsdAmountString(.removeZeros) + " USD"
    }
    
    func setup() {
        view.backgroundColor = .background4
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.custom(resolver: { _ in 656 })]
        }
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.centerToSuperview().pinToSuperview(edges: .vertical)
        
        lazy var topButtonStack = UIStackView(arrangedSubviews: Array(buttons.prefix(3)))
        lazy var bottomButtonStack = UIStackView(arrangedSubviews: Array(buttons.suffix(3)))
        lazy var actionStack = UIStackView(arrangedSubviews: [topButtonStack, bottomButtonStack])
        
        [topButtonStack, bottomButtonStack].forEach {
            $0.distribution = .fillEqually
            $0.spacing = 20
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 1 / 3, constant: -40 / 3).isActive = true
        }
        
        actionStack.spacing = 20
        actionStack.axis = .vertical
        
        zapLabel.textAlignment = .center
        zapLabel.adjustsFontSizeToFitWidth = true
        usdLabel.textAlignment = .center
        usdLabel.font = .appFont(withSize: 16, weight: .regular)
        usdLabel.textColor = .foreground3
        
        let inputParent = UIView()
        let buttonStack = UIStackView(axis: .vertical, [
            zapLabel, SpacerView(height: 2, priority: .required),
            usdLabel, SpacerView(height: 8, priority: .required), SpacerView(height: 18, priority: .defaultLow),
            actionStack, SpacerView(height: 8, priority: .required), SpacerView(height: 12, priority: .defaultLow),
            amountParent, SpacerView(height: 8, priority: .required), SpacerView(height: 20, priority: .defaultLow),
            inputParent, SpacerView(height: 8, priority: .required), SpacerView(height: 28, priority: .defaultLow),
            zapButton
        ])
        let stack = UIStackView(arrangedSubviews: [pullBarParent, SpacerView(height: 42), buttonStack, SpacerView(height: 42, priority: .defaultLow)])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .horizontal, padding: 32)
        let botC = stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        botC.isActive = true
        botC.priority = .defaultHigh
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        amountParent.backgroundColor = .background3
        amountParent.layer.cornerRadius = 22
        amountParent.layer.borderColor = UIColor.accent.cgColor
        amountParent.addSubview(amountField)
        amountParent.constrainToSize(height: 44)
        amountField.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        amountField.attributedPlaceholder = NSAttributedString(string: "Custom amount...", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground5
        ])
        amountField.font = .appFont(withSize: 16, weight: .regular)
        amountField.textColor = .foreground
        amountField.delegate = self
        amountField.keyboardType = .numberPad
        
        inputParent.backgroundColor = .background3
        inputParent.layer.cornerRadius = 22
        inputParent.addSubview(messageField)
        inputParent.constrainToSize(height: 44)
        messageField.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        messageField.attributedPlaceholder = NSAttributedString(string: "Add a comment...", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground5
        ])
        messageField.font = .appFont(withSize: 16, weight: .regular)
        messageField.textColor = .foreground
        messageField.delegate = self
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.messageField.resignFirstResponder()
            self?.amountField.resignFirstResponder()
        }))
    }
}

extension PopupZapSelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountField {
            selectedOptionIndex = nil
        }
    }
}
