//
//  UIViewController+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

extension UIViewController {
    @objc func backButtonPressed() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
