//
//  SlideDownTransition.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.1.24..
//

import UIKit

class SlideDownAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 8 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 4
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        // 5
        let container = transitionContext.containerView
        if presenting {
            container.addSubview(toView)
            toView.transform = .init(translationX: 0, y: -toView.frame.height)
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if self.presenting {
                toView.transform = .identity
            } else {
                fromView.transform = .init(translationX: 0, y: fromView.frame.height)
            }
        }) { _ in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            fromView.transform = .identity
            transitionContext.completeTransition(success)
        }
    }
}
