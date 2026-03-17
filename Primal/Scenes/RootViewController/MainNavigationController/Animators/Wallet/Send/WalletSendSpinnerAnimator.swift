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
        
        let backgroundParent = UIView()
        container.addSubview(backgroundParent)
        backgroundParent.pinToSuperview()
        
        let backgroundColor = Theme.current.isDarkTheme ? UIColor.black : .white
        
        let top = UIView().constrainToSize(1000)
        let bottom = UIView().constrainToSize(1000)
        [top, bottom].forEach {
            backgroundParent.addSubview($0)
            $0.centerToSuperview(axis: .horizontal)
            $0.backgroundColor = backgroundColor
        }
        
        let right = UIView().constrainToSize(width: 600)
        let left = UIView().constrainToSize(width: 600)
        [right, left].forEach {
            backgroundParent.addSubview($0)
            $0.pinToSuperview(edges: .vertical)
            $0.backgroundColor = backgroundColor
        }
        
        NSLayoutConstraint.activate([
            top.bottomAnchor.constraint(equalTo: backgroundParent.topAnchor),
            bottom.topAnchor.constraint(equalTo: backgroundParent.bottomAnchor),
            left.trailingAnchor.constraint(equalTo: backgroundParent.leadingAnchor),
            right.leadingAnchor.constraint(equalTo: backgroundParent.trailingAnchor)
        ])
        backgroundParent.layoutIfNeeded()
        
        spinner.navTitle.alpha = 0.01
        spinner.infoLabel.alpha = 0.01
        spinner.infoLabel.transform = .init(translationX: 100, y: 0)
        
        backgroundParent.alpha = 0
        toView.transform = .init(scaleX: 0.3, y: 0.3).translatedBy(x: 0, y: 200)
        backgroundParent.transform = toView.transform
        
        spinner.spinner.startPlayback()
        
        UIView.animate(withDuration: 2 / 30, delay: 10 / 30) {
            self.spinner.navTitle.alpha = 1
            self.spinner.infoLabel.alpha = 1
            self.spinner.infoLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 12 / 30, delay: 0) {
            toView.transform = .identity
            toView.alpha = 1
            backgroundParent.alpha = 1
            backgroundParent.transform = .identity
        } completion: { _ in
            toView.backgroundColor = Theme.current.isDarkTheme ? .black : .white
            backgroundParent.removeFromSuperview()
            
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }
    }
}
