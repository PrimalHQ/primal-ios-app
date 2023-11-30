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
    
    private let emojis = ["👍", "🌿", "🤙", "💜", "🔥", "🚀"]
    private var zapOptions: [Int] = [] {
        didSet {
            zip(zapOptions, buttons).forEach { option, button in
                button.title = option.shortened()
            }
            updateView()
        }
    }
    
    private var selectedOptionIndex = 0 {
        didSet {
            updateView()
        }
    }
    
    private lazy var buttons = emojis.enumerated().map {
        let view = ZapAmountSelectionButton(emoji: $0.element, title: "-")
        view.tag = $0.offset
        view.addAction(.init(handler: { [weak self] _ in
            self?.selectedOptionIndex = view.tag
        }), for: .touchUpInside)
        return view
    }
    
    let zapButton = LargeRoundedButton(title: "Zap")
    
    private let zapLabel = UILabel()
    private let usdLabel = UILabel()
    
    private let inputField = UITextField()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userToZap: PrimalUser, _ callback: @escaping (Int, String) -> Void) {
        self.userToZap = userToZap
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] settings in
                guard let options = settings?.content.zapOptions else { return }
                self?.zapOptions = options.map { Int($0) }
            })
            .store(in: &cancellables)
        
        zapButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true) { 
                callback(self.zapOptions[safe: self.selectedOptionIndex] ?? 0, self.inputField.text ?? "")
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
        
        guard let selectedZapAmount = zapOptions[safe: selectedOptionIndex] else { return }
        
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "USD"
        usdLabel.text = formatter.string(from: Double(selectedZapAmount) * 0.0003058 as NSNumber)
    }
    
    func setup() {
        view.backgroundColor = .background4
        if let pc = presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                pc.detents = [.custom(resolver: { _ in 580 })]
            } else {
                pc.detents = [.large()]
            }
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
        let buttonStack = UIStackView(arrangedSubviews: [zapLabel, usdLabel, actionStack, inputParent, zapButton])
        let stack = UIStackView(arrangedSubviews: [pullBarParent, SpacerView(height: 42), buttonStack, SpacerView(height: 42)])
        
        buttonStack.setCustomSpacing(2, after: zapLabel)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .horizontal, padding: 32)
        stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 32
        
        inputParent.backgroundColor = .background
        inputParent.layer.cornerRadius = 8
        inputParent.addSubview(inputField)
        inputParent.constrainToSize(height: 44)
        inputField.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        inputField.attributedPlaceholder = NSAttributedString(string: "Add a comment...", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground5
        ])
        inputField.font = .appFont(withSize: 16, weight: .regular)
        inputField.textColor = .foreground
        inputField.delegate = self
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
    }
}

extension PopupZapSelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
