//
//  UndoToastMessageView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.6.23..
//

import UIKit

extension UIView {
    func showUndoToast(_ text: String, durationSeconds: Int = 3, extraPadding: Bool = true, undoCallback: @escaping () -> ()) {
        let view = UndoToastMessageView(text: text)
        addSubview(view)
        
        view.undoButton.addAction(.init(handler: { _ in
            undoCallback()
            UIView.animate(withDuration: 0.3) {
                view.alpha = 0
                view.transform = .init(translationX: 0, y: 50)
            } completion: { _ in
                view.removeFromSuperview()
            }
        }), for: .touchUpInside)
        
        view.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .bottom, padding: extraPadding ? 102 : 12)
        
        view.alpha = 0
        view.transform = .init(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(durationSeconds)) {
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0
                    view.transform = .init(translationX: 0, y: 50)
                } completion: { _ in
                    view.removeFromSuperview()
                }
            }
        }
    }
}

class UndoToastMessageView: UIView {
    let label = UILabel()
    let undoButton = UIButton()
    
    init(text: String) {
        super.init(frame: .zero)
        
        label.text = text
        label.textColor = .foreground
        label.font = .appFont(withSize: 16, weight: .regular)
        label.textAlignment = .natural
        label.numberOfLines = 0
        
        undoButton.setTitle("undo", for: .normal)
        undoButton.setTitleColor(.foreground, for: .normal)
        undoButton.setTitleColor(.foreground.withAlphaComponent(0.6), for: .highlighted)
        undoButton.titleLabel?.font = .appFont(withSize: 16, weight: .bold)
        undoButton.setContentHuggingPriority(.required, for: .horizontal)
        undoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [label, undoButton])
        stack.spacing = 12
        
        addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 16).pinToSuperview(edges: .horizontal, padding: 24)
        
        backgroundColor = .background3
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.foreground.withAlphaComponent(0.1).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
