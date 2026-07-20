//
//  ArticleChromeManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.7.24..
//

import Foundation
import UIKit

class ArticleChromeManager: AppChromeManager {
    override func setBarsHidden(_ hidden: Bool, animated: Bool) {
        guard let controller = viewController else { return }

        controller.navigationController?.setNavigationBarHidden(hidden, animated: animated)
        controller.mainTabBarController?.setTabBarHidden(hidden, animated: animated)

        if animated, let extraBottomView {
            let offset = bottomBarHeight + 30
            extraBottomView.isHidden = false
            extraBottomView.transform = hidden ? .identity : .init(translationX: 0, y: offset)
            UIView.animate(withDuration: 0.3) {
                if hidden {
                    extraBottomView.transform = .init(translationX: 0, y: offset)
                } else {
                    extraBottomView.transform = .identity
                }
            }
        } else {
            extraBottomView?.isHidden = hidden
        }
    }
}
