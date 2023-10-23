//
//  RepostSelectionViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.6.23..
//

import UIKit

final class PopupMenuViewController: UIViewController {
    private var actions: [UIAction] = []
    private let message: String?
    
    init(message: String? = nil, actions: [UIAction] = []) {
        self.actions = actions
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(_ action: UIAction) {
        actions.append(action)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension PopupMenuViewController {
    func setup() {
        view.backgroundColor = .background4
        let messageLabel = UILabel()
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [
                .custom(resolver: { [weak self] _ in
                    guard let self else { return 285 }
                    let buttonsCount = CGFloat(self.actions.count)
                    let buttonHeight = buttonsCount * 24
                    let buttonSpace = buttonsCount > 1.1 ? (buttonsCount - 1) * 32 : 0
                    
                    return 80 + buttonHeight + buttonSpace + 84 + 89 + messageLabel.sizeThatFits(.init(width: self.view.frame.width - 64, height: .infinity)).height
                })
            ]
        }
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.centerToSuperview().pinToSuperview(edges: .vertical)
        
        var buttons: [UIControl] = []
        
        for action in actions {
            let button = PopupMenuIconButton(icon: action.image, text: action.title)
            button.addAction(.init(handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    action.performWithSender(nil, target: nil)
                })
            }), for: .touchUpInside)
            
            buttons.append(button)
        }
        
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(.foreground, for: .normal)
        cancel.titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        cancel.layer.borderColor = UIColor.foreground6.cgColor
        cancel.layer.borderWidth = 1
        cancel.layer.cornerRadius = 12
        cancel.constrainToSize(height: 52)
        cancel.addAction(.init(handler: { [weak self] _ in self?.dismiss(animated: true) }), for: .touchUpInside)

        buttons.append(cancel)
        
        let buttonStack = UIStackView(arrangedSubviews: buttons)
        let stack = UIStackView(arrangedSubviews: [pullBarParent, SpacerView(height: 42), buttonStack, SpacerView(height: 42)])
        
        if let message {
            messageLabel.text = message
            messageLabel.font = .appFont(withSize: 18, weight: .medium)
            messageLabel.textColor = .foreground
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            stack.insertArrangedSubview(messageLabel, at: 1)
            stack.insertArrangedSubview(SpacerView(height: 8), at: 1)
        }
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 16, safeArea: true).pinToSuperview(edges: .horizontal, padding: 32)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 32
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
    }
}

final class PopupMenuIconButton: MyButton {
    let iconView = UIImageView()
    let label = UILabel()
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    init(icon: UIImage?, text: String) {
        super.init(frame: .zero)
        iconView.image = icon
        label.text = text
        
        label.font = .appFont(withSize: 20, weight: .regular)
        label.textColor = .foreground
        
        iconView.constrainToSize(24)
        iconView.contentMode = .center
        iconView.tintColor = .foreground
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.alignment = .center
        stack.spacing = 8
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
