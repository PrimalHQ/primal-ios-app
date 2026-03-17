//
//  ScanAnythingKeyboardController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 12. 2025..
//

import Combine
import UIKit

class PasteButton: UIButton {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        setImage(.pasteQR, for: .normal)
        setTitle("Paste", for: .normal)
        setTitleColor(.foreground3, for: .normal)
        titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        
        constrainToSize(width: 100, height: 36)
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 8)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor.foreground3.cgColor
        
        tintColor = .foreground3
    }
}

class ScanAnythingKeyboardController: UIViewController, WalletSearchController {
    var textSearch: String?
    
    let backButton = UIButton()
    let titleLabel = UILabel()
    
    let input = UITextField()
    let pasteButton = PasteButton()
    
    let descLabel = UILabel("Invite code, payment invoice, login string,\nuser link, content link, primal gift card code", color: .foreground, font: .appFont(withSize: 14, weight: .regular), multiline: true)
    let placeholderLabel = UILabel("Enter code...", color: .foreground4, font: .appFont(withSize: 18, weight: .semibold))
    
    var cancellables: Set<AnyCancellable> = []
    
    var navigationControllerForSearchResults: UINavigationController? {
        dismiss(animated: true)
        return RootViewController.instance.findInChildren()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let contentParent = UIView()
        let keyboardSizer = KeyboardSizingView()
        let acceptButton = UIButton(configuration: .pill(text: "Apply", foregroundColor: .foreground5, backgroundColor: .background3, font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 44)
        acceptButton.isEnabled = false
        let mainStack = UIStackView(axis: .vertical, [contentParent, keyboardSizer])
        view.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        let inputParent = UIView().constrainToSize(height: 48)
        inputParent.backgroundColor = .background3
        inputParent.layer.cornerRadius = 24
        inputParent.layer.borderColor = UIColor.receiveMoney.cgColor
        
        input.textColor = .foreground
        input.font = .appFont(withSize: 18, weight: .semibold)
        input.delegate = self
        
        let pasteParent = UIView()
        let contentStack = UIStackView(axis: .vertical, [
            descLabel,
            inputParent,
            pasteParent
        ])
        contentStack.spacing = 20
        contentParent.addSubview(contentStack)
        contentStack.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        contentParent.addSubview(acceptButton)
        acceptButton.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .bottom, padding: 20)
        
        pasteParent.addSubview(pasteButton)
        pasteButton.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let check = UIImageView(image: .toastCheckmark)
        check.tintColor = .receiveMoney
        
        let inputStack = UIStackView([input, check])
        inputParent.addSubview(inputStack)
        inputStack.centerToSuperview(axis: .vertical).pinToSuperview(edges: .leading, padding: 20).pinToSuperview(edges: .trailing, padding: 16)
        inputStack.spacing = 10
        check.setContentCompressionResistancePriority(.required, for: .horizontal)
        check.isHidden = true
        
        placeholderLabel.isUserInteractionEnabled = false
        inputParent.addSubview(placeholderLabel)
        placeholderLabel.centerToSuperview()
        
        addNavigationBar("Remote Login")
        
        keyboardSizer.updateHeightCancellable().store(in: &cancellables)
        
        input.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            let trimmed = input.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let isEmpty = trimmed.isEmpty

            placeholderLabel.isHidden = true
            acceptButton.isEnabled = !isEmpty
            acceptButton.configuration = .pill(
                text: "Apply",
                foregroundColor: isEmpty ? .foreground5 : .white,
                backgroundColor: isEmpty ? .background3 : .accent,
                font: .appFont(withSize: 16, weight: .semibold)
            )

            guard let url = URL(string: trimmed), DeeplinkCoordinator.shared.canHandleURL(url) else {
                check.isHidden = true
                inputParent.layer.borderWidth = 0
                return
            }
            
            check.isHidden = false
            inputParent.layer.borderWidth = 1
        }), for: .editingChanged)
        
        pasteButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let pastedString = UIPasteboard.general.string else { return }
            input.text = pastedString
            input.sendActions(for: .editingChanged)
        }), for: .touchUpInside)
        
        acceptButton.addAction(.init(handler: { [weak self] _ in
            self?.doSearch()
        }), for: .touchUpInside)
        
    }
    
    func addNavigationBar(_ title: String) {
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = .foreground
        backButton.constrainToSize(44)
        backButton.backgroundColor = .white.withAlphaComponent(0.01)
        view.addSubview(backButton)
        backButton.pinToSuperview(edges: .leading, padding: 24).pinToSuperview(edges: .top, padding: 10, safeArea: true)
        
        view.addSubview(titleLabel)
        titleLabel.centerToSuperview(axis: .horizontal).centerToView(backButton, axis: .vertical)
        titleLabel.text = title
        titleLabel.font = .appFont(withSize: 24, weight: .regular)
        titleLabel.textColor = .foreground
    }
    
    func doSearch() {
        guard let text = input.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        
        // Try to parse as URL using deeplink handlers first
        if let url = URL(string: text), DeeplinkCoordinator.shared.canHandleURL(url) {
            dismiss(animated: true) {
                DeeplinkCoordinator.shared.handleURL(url)
            }
            return
        }
        
        // Fallback to search
        search(text)
    }
}

extension ScanAnythingKeyboardController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doSearch()
        return true
    }
}
