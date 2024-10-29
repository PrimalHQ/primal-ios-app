//
//  UIViewController+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

extension UIViewController {
    var topSafeAreaSpacer: UIView {
        let spacer = UIView()
        view.insertSubview(spacer, at: 0)
        spacer.pinToSuperview(edges: [.horizontal, .top])
        spacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        return spacer
    }
}

extension UIViewController {
    func showErrorMessage(title: String = "Warning", _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func backButtonPressed() {
        if let navigationController {
            let textViews: [UITextField] = self.view.findAllSubviews()
            textViews.forEach { $0.resignFirstResponder() }
            
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    var customBackButton: UIBarButtonItem { backButtonWithColor(.foreground) }
    
    func customSearchButton(scope: SearchScope = .global, type: SearchType = .notes) -> UIBarButtonItem {
        let view = UIView().constrainToSize(44)
        let icon = UIImageView(image: UIImage(named: "navSearch"))
        icon.tintColor = .foreground
        view.addSubview(icon)
        icon.centerToSuperview(axis: .vertical).pinToSuperview(edges: .trailing)
        let button = UIButton()
        view.addSubview(button)
        button.pinToSuperview()
        button.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.fadeTo(SearchViewController(scope: scope, type: type))
        }), for: .touchUpInside)
        return .init(customView: view)
    }
    
    func backButtonWithColor(_ color: UIColor) -> UIBarButtonItem {
        let button = backButtonWithColorNoAction(color)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    func backButtonWithColorNoAction(_ color: UIColor) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.tintColor = color
        button.contentHorizontalAlignment = .leading
        button.constrainToSize(44)
        return button
    }
    
    func backButtonWithImage(_ image: UIImage?) -> UIBarButtonItem {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        return UIBarButtonItem(customView: button)
    }
    
    func findParent<T>() -> T? {
        return parent as? T ?? parent?.findParent()
    }
    
    func findInChildren<T>() -> T? {
        for child in children {
            if let t = child as? T ?? child.findInChildren() {
                return t
            }
        }
        return nil
    }
    
    func findAllChildren<T>() -> [T] {
        var result = [T]()
        for child in children {
            if let t = child as? T {
                result.append(t)
            }
            result += child.findAllChildren()
        }
        return result
    }
    
    func updateThemeIfThemeable() {
        (self as? Themeable)?.updateTheme()
        
        let themables: [Themeable] = view.findAllSubviews()
        themables.forEach { $0.updateTheme() }
    }
}
