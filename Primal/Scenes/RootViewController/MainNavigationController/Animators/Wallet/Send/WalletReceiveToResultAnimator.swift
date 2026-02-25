//
//  WalletReceiveToResultAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.2.26..
//

import UIKit

final class WalletReceiveToResultAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let receive: WalletReceiveViewController
    let result: WalletTransferSummaryController
    init?(receive: WalletReceiveViewController, result: WalletTransferSummaryController) {
        self.receive = receive
        self.result = result
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 16 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }

        let container = transitionContext.containerView

        let circle = UIView(frame: .init(
            origin: .init(x: container.bounds.midX, y: container.bounds.midY),
            size: .zero
        ))
        container.addSubview(circle)
        switch result.state {
        case .success:
            circle.backgroundColor = .receiveMoney
        case .failure:
            circle.backgroundColor = .black
        }

        container.addSubview(toView)
        toView.layoutIfNeeded()
        toView.alpha = 0
        toView.backgroundColor = .clear

        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeInOutQuart)

        UIView.animate(withDuration: 20 / 30) {
            circle.frame = .init(x: -500, y: -200, width: 1500, height: 1500)
            circle.layer.cornerRadius = 750
        } completion: { _ in
            circle.removeFromSuperview()
            switch self.result.state {
            case .success:
                toView.backgroundColor = .receiveMoney
            case .failure:
                toView.backgroundColor = .black
            }
        }

        CATransaction.commit()

        UIView.animate(withDuration: 8 / 30) {
            fromView.alpha = 0
        }

        UIView.animate(withDuration: 4 / 30, delay: 4 / 30) {
            toView.alpha = 1
        } completion: { [self] _ in
            fromView.alpha = 1

            result.animationView.play()

            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }

        let staggeredViews: [UIView] = (result.titleLabel.isHidden ? [] : [result.titleLabel]) + result.subtitleStack.arrangedSubviews + [result.closeButton]

        staggeredViews.enumerated().forEach { (index, view) in
            view.alpha = 0.01

            UIView.animate(withDuration: 4 / 30, delay: 6 / 30 + TimeInterval(2 * index) / 30) {
                view.alpha = 1
            }
        }
    }
}
