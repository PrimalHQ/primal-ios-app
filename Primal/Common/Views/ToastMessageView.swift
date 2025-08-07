//
//  ToastMessageView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 9.6.23..
//

import UIKit

extension UIView {
    func showToast(_ text: String, icon: UIImage? = UIImage(named: "toastCheckmark"), durationSeconds: Int = 3, extraPadding: CGFloat = 90) {
        let view = ToastMessageView(text: text, image: icon)
        addSubview(view)
        
        view.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: 18 + extraPadding)
        
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
    
    func showDimmedToastCentered(_ text: String, image: UIImage? = .toastCheckmark, durationSeconds: Int = 1) {
        let view = ToastMessageView(text: text, image: image, theme: Theme.sunriseWave.theme)
        
        let background = UIView()
        background.addSubview(view)
        view.centerToSuperview()
        
        addSubview(background)
        background.pinToSuperview()
        
        background.isUserInteractionEnabled = false
        background.backgroundColor = .black.withAlphaComponent(0.5)
        background.alpha = 0
        background.layer.cornerRadius = layer.cornerRadius
        view.alpha = 0
        view.transform = .init(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.2) {
            background.alpha = 1
            
            UIView.animate(withDuration: 0.3) {
                view.alpha = 1
                view.transform = .identity
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(durationSeconds)) {
                    UIView.animate(withDuration: 0.3) {
                        view.alpha = 0
                        view.transform = .init(translationX: 0, y: 50)
                        background.alpha = 0
                    } completion: { _ in
                        background.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func showToastTop(_ text: String, image: UIImage? = .toastCheckmark, durationSeconds: Int = 1) {
        let view = ToastMessageView(text: text, image: image, theme: Theme.sunriseWave.theme)
        
        addSubview(view)
        view.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .top, padding: 30, safeArea: true)
        view.alpha = 0
        view.transform = .init(translationX: 0, y: -50)
        
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(durationSeconds)) {
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0
                    view.transform = .init(translationX: 0, y: -50)
                } completion: { _ in
                    view.removeFromSuperview()
                }
            }
        }
    }
}

class ToastMessageView: UIView {
    init(text: String, image: UIImage? = UIImage(named: "toastCheckmark"), theme: AppTheme = Theme.inverse) {
        super.init(frame: .zero)
        
        let icon = UIImageView(image: image)
        icon.tintColor = theme.foreground
        
        let label = UILabel()
        label.text = text
        label.textColor = theme.foreground
        label.font = .appFont(withSize: 16, weight: .semibold)
        label.numberOfLines = 0
        
        let stack = UIStackView([icon, label])
        stack.alignment = .center
        stack.spacing = 9
        
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12)
        
        backgroundColor = theme.background
        layer.cornerRadius = 22
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
