//
//  FadeTransition.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.1.24..
//

import UIKit

class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 8 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 4
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        // 5
        let container = transitionContext.containerView
        if presenting {
            container.addSubview(toView)
            toView.alpha = 0.0
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if self.presenting {
                toView.alpha = 1.0
            } else {
                fromView.alpha = 0.0
            }
        }) { _ in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }
    }

    init(presenting: Bool) {
        self.presenting = presenting
    }
}
