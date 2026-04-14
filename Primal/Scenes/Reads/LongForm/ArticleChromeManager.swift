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

        let navTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: -topBarHeight) : .identity
        let tabTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: bottomBarHeight) : .identity

        let apply = { [self] in
            controller.navigationController?.navigationBar.transform = navTransform
            controller.mainTabBarController?.tabBarContainerView.transform = tabTransform

            if hidden {
                extraBottomView?.subviews.first?.alpha = 0
                extraBottomView?.transform = .init(translationX: 0, y: bottomBarHeight).scaledBy(x: 0, y: 0)
                extraBottomView?.alpha = 0
            } else {
                extraBottomView?.subviews.first?.alpha = 1
                extraBottomView?.transform = .identity
                extraBottomView?.alpha = 1
            }
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: apply)
        } else {
            apply()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        extraTopView?.transform = .init(
            translationX: 0,
            y: (-(viewController?.scrollView.contentOffset.y ?? 0) - 64).clamped(to: -64...96)
        )
    }
}
