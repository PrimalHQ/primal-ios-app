//
//  ToastMessageView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

extension UIView {
    func showToast(_ text: String, durationSeconds: Int = 3) {
        let view = ToastMessageView(text: text)
        addSubview(view)
        
        view.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .bottom, padding: 12)
        
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

class ToastMessageView: UIView {
    init(text: String) {
        super.init(frame: .zero)
        
        let label = UILabel()
        label.text = text
        label.textColor = .foreground
        label.font = .appFont(withSize: 18, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        addSubview(label)
        label.pinToSuperview(padding: 16)
        
        backgroundColor = .background3
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.foreground.withAlphaComponent(0.1).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
