//
//  WalletSendTransitionAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.1.24..
//

import UIKit

class WalletSendTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    private let home: WalletHomeViewController
    private let userController: WalletPickUserController
    
    init(home: WalletHomeViewController, userController: WalletPickUserController, presenting: Bool) {
        self.presenting = presenting
        self.home = home
        self.userController = userController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 12 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 4
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        // 5
        let container = transitionContext.containerView
        if presenting {
            container.addSubview(toView)
            toView.alpha = 0
            toView.layoutIfNeeded()
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        
        if self.presenting {
            let width = container.frame.width
            
            var endFrame = toView.frame
            endFrame.size.height -= 200
            endFrame.origin.y += 100
            endFrame.size.width = endFrame.height
            endFrame.origin.x = (width - endFrame.height) / 2
            
            let backgroundAnimatingView = home.transitionButton?.imageView?.superview?.animateViewTo(endFrame, radius: endFrame.width / 2, duration: 12 / 30, in: container)
            UIView.animate(withDuration: 6 / 30, delay: 6 / 30) {
                backgroundAnimatingView?.alpha = 0
            }
            
            
            userController.searchBackground.setAnchorPoint(.init(x: 0, y: 0.5))
            userController.searchBackground.transform = .init(scaleX: 0, y: 1)
            userController.searchInput.alpha = 0
            
            userController.userTable.transform = .identity.scaledBy(x: 0.8, y: 0.8)
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(.easeInOutQuart)
            
            UIView.animate(withDuration: 6 / 30, delay: 6 / 30) {
                self.userController.searchBackground.transform = .identity
                self.userController.userTable.transform = .identity
            }
            
            CATransaction.commit()
            
            UIView.animate(withDuration: 6 / 30) {
                fromView.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 6 / 30) {
                    toView.alpha = 1
                    self.userController.searchInput.alpha = 1
                } completion: { _ in
                    fromView.alpha = 1
                    self.userController.searchBackground.resetAnchorPoint()
                    transitionContext.completeTransition(true)
                }
            }
            
            if let imageView = home.transitionButton?.imageView {
                let animatingIV = UIImageView()
                animatingIV.image = imageView.image
                animatingIV.tintColor = imageView.tintColor
                animatingIV.contentMode = .scaleAspectFit
                animatingIV.layer.cornerRadius = imageView.layer.cornerRadius
                animatingIV.clipsToBounds = imageView.clipsToBounds
                animatingIV.frame = imageView.convert(imageView.bounds, to: container)
                container.addSubview(animatingIV)
                
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.easeInOutQuart)
                
                UIView.animate(withDuration: 12 / 30) {
                    animatingIV.frame = CGRect(x: width * 0.15, y: container.frame.height * 0.3, width: width * 0.7, height: width * 0.7)
                } completion: { _ in
                    animatingIV.removeFromSuperview()
                    self.home.transitionButton?.imageView?.superview?.alpha = 1
                }
                
                CATransaction.commit()
                
                UIView.animate(withDuration: 8 / 30) {
                    animatingIV.alpha = 0
                }
            }
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView.alpha = 0.0
            }) { _ in
                let success = !transitionContext.transitionWasCancelled
                if !success {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        }
    }
    
    func animatePresenting() {
        
    }
    
    func animateDismiss() {
        
    }
}
