//
//  WalletKeyboardTabController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.12.23..
//

import UIKit
import Combine

final class WalletKeyboardTabController: UIViewController, WalletSendTabController {
    private let field = SelfSizingTextView()
    
    @Published var fieldText = ""
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
    
        let fieldBackground = UIView()
        let postButton = ChatSendButton()
        postButton.transform = .init(rotationAngle: .pi / 2)
        let inputStack = UIStackView([fieldBackground, postButton])
        inputStack.spacing = 8
        inputStack.alignment = .top
        
        let pasteButtonParent = UIView()
        
        let stack = UIStackView(axis: .vertical, [inputStack, UIView(), pasteButtonParent])
        stack.spacing = 12
        view.addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .top], padding: 20, safeArea: true)
        stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -40).isActive = true
        
        fieldBackground.addSubview(field)
        fieldBackground.backgroundColor = .background3
        fieldBackground.layer.cornerRadius = 20
        fieldBackground.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        field.pinToSuperview(edges: .horizontal, padding: 8).pinToSuperview(edges: .top, padding: 2).pinToSuperview(edges: .bottom, padding: -2)
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = .appFont(withSize: 16, weight: .regular)
        field.textColor = .foreground
        field.backgroundColor = .clear
        field.delegate = self
        
        let pasteButton = WalletSendSmallActionButton(title: "Paste from clipboard", icon: UIImage(named: "pasteWallet"))
        pasteButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let paste = UIPasteboard.general.string, !paste.isEmpty else { return }
            field.text = paste
            fieldText = paste
        }), for: .touchUpInside)
        
        pasteButtonParent.addSubview(pasteButton)
        pasteButton.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal).constrainToSize(width: 217)
        
        postButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            sendParent?.search(field.text ?? "")
        }), for: .touchUpInside)
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.field.resignFirstResponder()
        }))
        
        $fieldText.map({ $0.isEmpty }).sink { empty in
            postButton.backgroundColor = empty ? .background3 : .accent
            postButton.tintColor = empty ? .foreground5 : .white
            postButton.isEnabled = !empty
        }
        .store(in: &cancellables)
    }
}

extension WalletKeyboardTabController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.invalidateIntrinsicContentSize()
        fieldText = textView.text
    }
}

final class WalletSendSmallActionButton: UIButton {
    init(title: String, icon: UIImage?) {
        super.init(frame: .zero)
        
        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
        setTitle(title, for: .normal)
        setTitleColor(.foreground3, for: .normal)
        setImage(icon, for: .normal)
        tintColor = .foreground3
        backgroundColor = .background3
        layer.cornerRadius = 20
        imageEdgeInsets = .init(top: 0, left: -16, bottom: 0, right: 0)
        titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        
        constrainToSize(height: 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class WalletSendSmallActionBlackButton: UIButton {
    init(title: String, icon: UIImage?) {
        super.init(frame: .zero)
        
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .appFont(withSize: 16, weight: .regular)
            outgoing.foregroundColor = .init(rgb: 0xAAAAAA)
            return outgoing
        }
        config.image = icon
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .init(rgb: 0xAAAAAA)
        config.cornerStyle = .capsule
        config.titleLineBreakMode = .byTruncatingTail

        configuration = config
//        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
//        setTitle(title, for: .normal)
//        setTitleColor(.init(rgb: 0xAAAAAA), for: .normal)
//        setImage(icon, for: .normal)
//        tintColor = .init(rgb: 0xAAAAAA)
//        backgroundColor = .black
//        layer.cornerRadius = 20
//        imageEdgeInsets = .init(top: 0, left: -16, bottom: 0, right: 0)
//        titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        
        constrainToSize(height: 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
