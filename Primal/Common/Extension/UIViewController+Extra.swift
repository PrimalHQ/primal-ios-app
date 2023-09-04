//
//  UIViewController+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

extension UIViewController {
    func showErrorMessage(title: String = "Error", _ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func backButtonPressed() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    var customBackButton: UIBarButtonItem {
        let button = UIButton()
        button.setImage(Theme.current.backButtonImage, for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        return UIBarButtonItem(customView: button)
    }
    
    var customRedBackButton: UIBarButtonItem {
        let button = UIButton()
        button.setImage(SunriseWave.instance.backButtonImage, for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        return UIBarButtonItem(customView: button)
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
