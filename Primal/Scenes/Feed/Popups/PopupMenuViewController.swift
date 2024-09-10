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
                    
                    if self.actions.count > 1 {
                        let buttonsCount = CGFloat(self.actions.count)
                        let buttonHeight = buttonsCount * 58
                        let buttonSpace = buttonsCount > 1.1 ? (buttonsCount - 1) * 28 : 0
                        
                        return buttonHeight + buttonSpace + 24 + 89 + messageLabel.sizeThatFits(.init(width: self.view.frame.width - 64, height: .infinity)).height
                    }
                    
                    return 98 + 24 + 89 + messageLabel.sizeThatFits(.init(width: self.view.frame.width - 64, height: .infinity)).height
                })
            ]
        }
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.centerToSuperview().pinToSuperview(edges: .vertical)
        
        var buttons: [UIControl] = []
        
        for action in actions {
            let button: UIControl = (actions.count > 1) ?
                (action.image != nil ? PopupMenuIconButton(icon: action.image, text: action.title) : simpleButton(action.title))
              : LargeRoundedButton(title: action.title)
            button.addAction(.init(handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    action.performWithSender(nil, target: nil)
                })
            }), for: .touchUpInside)
            buttons.append(button)
        }
        
        let buttonStack = UIStackView(arrangedSubviews: buttons)
        let stack = UIStackView(arrangedSubviews: [pullBarParent, SpacerView(height: 52), buttonStack])
        
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
        stack.pinToSuperview(edges: .top, padding: 16, safeArea: true).pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 28
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
    }
    
    func simpleButton(_ title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.foreground, for: .normal)
        button.titleLabel?.font = .appFont(withSize: 20, weight: .regular)
        return button
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
        
        let backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.pinToSuperview(edges: .vertical).constrainToSize(width: 240, height: 56).centerToSuperview(axis: .horizontal)
        backgroundView.layer.cornerRadius = 28
        backgroundView.backgroundColor = .background3
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.alignment = .center
        stack.spacing = 8
        addSubview(stack)
        stack.centerToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
