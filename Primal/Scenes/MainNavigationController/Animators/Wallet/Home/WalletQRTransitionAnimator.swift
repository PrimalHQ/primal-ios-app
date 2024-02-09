//
//  WalletQRTransitionAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.1.24..
//

import UIKit

class WalletQRTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    private let home: WalletHomeViewController
    private let qrController: WalletQRCodeViewController
    
    init(home: WalletHomeViewController, qrController: WalletQRCodeViewController, presenting: Bool) {
        self.presenting = presenting
        self.home = home
        self.qrController = qrController
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
            toView.alpha = 0.0
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        
        if self.presenting {
            let width = container.frame.width
            let rect = CGRect(x: -width * 0.4, y: 0, width: width * 1.8, height: width * 1.8)
            
            let backgroundAnimatingView = home.transitionButton?.imageView?.superview?.animateViewTo(rect, radius: rect.width / 2, duration: 12 / 30, in: container)
            UIView.animate(withDuration: 6 / 30, delay: 6 / 30) {
                backgroundAnimatingView?.alpha = 0
            }
            
            qrController.importImageButton.transform = .init(translationX: 0, y: 20)
            qrController.importImageButton.alpha = 0
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(.easeInOutQuart)
            
            UIView.animate(withDuration: 6 / 30, delay: 6 / 30) {
                self.qrController.importImageButton.transform = .identity
                self.qrController.importImageButton.alpha = 1
            } completion: { _ in
                transitionContext.completeTransition(true)
            }
            
            CATransaction.commit()
            
            UIView.animate(withDuration: 6 / 30, delay: 6 / 30) {
                toView.alpha = 1
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
    }
    
    func animatePresenting() {
        
    }
    
    func animateDismiss() {
        
    }
}
