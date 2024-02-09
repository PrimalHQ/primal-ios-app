//
//  SettingsEditZapController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.1.24..
//

import UIKit

final class SettingsEditZapController: UIViewController, Themeable {
    enum EditType {
        case editDefault
        case editOptionInArray(Int)
    }
    
    let editType: EditType
    
    let emojiInput = EmojiTextField()
    let messageInput = UITextField()
    let valueInput = UITextField()
    
    init(_ type: EditType) {
        editType = type
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard 
            var settings = IdentityManager.instance.userSettings,
            let value = Int(valueInput.text ?? "")
        else { return }

        switch editType {
        case .editDefault:
            settings.zapDefault = .init(amount: value, message: messageInput.text ?? "")
        case .editOptionInArray(let int):
            settings.zapConfig?[safe: int] = .init(emoji: emojiInput.text ?? "", amount: value, message: messageInput.text ?? "")
        }
        IdentityManager.instance.updateSettings(settings)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsEditZapController {
    func setup() {
        updateTheme()
        
        title = "Zap Settings"
        
        let messageParent = ThemeableView().constrainToSize(height: 48).setTheme { $0.backgroundColor = .background3 }
        messageParent.addSubview(messageInput)
        messageParent.layer.cornerRadius = 24
        messageInput.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        
        let amountParent = ThemeableView().constrainToSize(height: 48).setTheme { $0.backgroundColor = .background3 }
        amountParent.addSubview(valueInput)
        amountParent.layer.cornerRadius = 24
        valueInput.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        
        let emojiParentParent = UIView()
        let emojiParent = ThemeableView().constrainToSize(width: 56, height: 48).setTheme { $0.backgroundColor = .background3 }
        emojiParentParent.addSubview(emojiParent)
        emojiParent.pinToSuperview(edges: [.vertical, .leading])
        emojiParent.layer.cornerRadius = 12
        emojiParent.addSubview(emojiInput)
        emojiInput.centerToSuperview()
        
        let stack = UIStackView(axis: .vertical, [
            SettingsTitleViewVibrant(title: "MESSAGE"), SpacerView(height: 12),
            messageParent, SpacerView(height: 24),
            SettingsTitleViewVibrant(title: "VALUE"), SpacerView(height: 12),
            amountParent
        ])
        
        switch editType {
        case .editDefault:
            messageInput.text = IdentityManager.instance.userSettings?.zapDefault?.message ?? ""
            valueInput.text = "\(IdentityManager.instance.userSettings?.zapDefault?.amount ?? 0)"
        case .editOptionInArray(let index):
            for (index, view) in [SettingsTitleViewVibrant(title: "EMOJI"), SpacerView(height: 12), emojiParentParent, SpacerView(height: 24)].enumerated() {
                stack.insertArrangedSubview(view, at: index)
            }
            
            if let settings = IdentityManager.instance.userSettings?.zapConfig?[safe: index] {
                messageInput.text = settings.message
                valueInput.text = "\(settings.amount)"
                emojiInput.text = settings.emoji
            }
        }
        
        emojiInput.delegate = self
        valueInput.keyboardType = .numberPad
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: [.top, .horizontal], padding: 20, safeArea: true)
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.valueInput.resignFirstResponder()
            self?.messageInput.resignFirstResponder()
            self?.emojiInput.resignFirstResponder()
        }))
        messageParent.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.messageInput.becomeFirstResponder()
        }))
        amountParent.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.valueInput.becomeFirstResponder()
        }))
        emojiParent.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.emojiInput.becomeFirstResponder()
        }))
    }
}

extension SettingsEditZapController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isSingleEmoji || string.isEmpty {
            textField.text = string
        }
        return false
    }
}

class EmojiTextField: UITextField {
    override var textInputContextIdentifier: String? { super.textInputContextIdentifier ?? "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}
