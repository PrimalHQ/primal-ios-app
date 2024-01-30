//
//  WalletSendSpinnerAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.1.24..
//

import UIKit

final class WalletSendSpinnerAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let spinner: WalletSpinnerViewController
    let sendController: WalletSendViewController
    init?(sendController: WalletSendViewController, spinner: WalletSpinnerViewController) {
        self.spinner = spinner
        self.sendController = sendController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 12 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }

        let container = transitionContext.containerView
        
        container.addSubview(toView)
        toView.layoutIfNeeded()
        toView.alpha = 0
        
        let imageView = UIImageView(image: UIImage(named: "transitionSpinner"))
        switch Theme.current.kind {
        case .sunriseWave, .sunsetWave: return
        case .midnightWave, .iceWave:
            imageView.image = UIImage(named: "transitionSpinner")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(rgb: 0x2554ED)
        }
        
        imageView.frame = sendController.profilePictureView.convert(sendController.profilePictureView.bounds, to: container).enlarge(60)
        container.addSubview(imageView)
        
        sendController.profilePictureView.animateTransitionTo(spinner.spinner, duration: 12 / 30, in: container, fade: true)
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeInOutQuart)
        
        UIView.animate(withDuration: 12 / 30) { [self] in
            imageView.frame = spinner.spinner.convert(spinner.spinner.bounds, to: container).enlarge(150)
        }
        
        CATransaction.commit()
        
        spinner.titleLabel.alpha = 0.01
        
        UIView.animate(withDuration: 8 / 30) {
            fromView.alpha = 0
        }
        
        UIView.animate(withDuration: 8 / 30, delay: 4 / 30) {
            self.spinner.titleLabel.alpha = 1
            imageView.alpha = 0
            toView.alpha = 1
        } completion: { [self] _ in
            toView.backgroundColor = .background
            sendController.profilePictureView.alpha = 1
            sendController.input.largeAmountLabel.alpha = 1
            sendController.nameLabel.alpha = 1
            fromView.alpha = 1
            
            imageView.removeFromSuperview()
            
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }
    }
}
