//
//  WalletSendAmountSendAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.1.24..
//

import Foundation

import UIKit

class WalletSendAmountSendAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    private let sendAmount: WalletSendAmountController
    private let send: WalletSendViewController
    
    init(sendAmount: WalletSendAmountController, send: WalletSendViewController, presenting: Bool) {
        self.presenting = presenting
        self.sendAmount = sendAmount
        self.send = send
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 12 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 4
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        // 5
        let container = transitionContext.containerView
        
        let translationX: CGFloat = 400
        
        send.view.backgroundColor = .clear
        sendAmount.infoParent.alpha = 0.01
        sendAmount.input.alpha = 0.01
        
        if presenting {
            container.addSubview(toView)
            
            UIView.performWithoutAnimation {
                send.input.isBitcoinPrimary = sendAmount.input.isBitcoinPrimary
            }
            
            send.messageParent.transform = .init(translationX: translationX, y: 0)
            send.feeView.transform = .init(translationX: translationX, y: 0)
            
            send.messageParent.alpha = 0
            send.feeView.alpha = 0
            
            send.sendButton.alpha = 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.sendAmount.sendButton.animateViewTo(self.send.sendButton, duration: 6 / 30, in: container)
            }
        } else {
            container.insertSubview(toView, belowSubview: fromView)
            
            sendAmount.input.isBitcoinPrimary = send.input.isBitcoinPrimary
            
            sendAmount.cancelButton.alpha = 0
            sendAmount.keyboard.transform = .init(translationX: -translationX, y: 0)
            sendAmount.keyboard.alpha = 0
            send.messageParent.alpha = 1
            send.feeView.alpha = 1
            
            send.sendButton.animateViewTo(sendAmount.sendButton, duration: 6 / 30, in: container)
        }
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeInOutQuart)
        
        UIView.animate(withDuration: 6 / 30) { [self] in
            if presenting {
                sendAmount.keyboard.transform = .init(translationX: -translationX, y: 0)
            }
        }
        
        UIView.animate(withDuration: 6 / 30, delay: 3 / 30) { [self] in
            send.messageParent.transform = presenting ? .identity : .init(translationX: translationX, y: 0)
            send.feeView.transform = presenting ? .identity : .init(translationX: translationX, y: 0)
        }
        
        UIView.animate(withDuration: 6 / 30, delay: 6 / 30) { [self] in
            if presenting {
            } else {
                sendAmount.keyboard.transform = .identity
            }
        }
        
        CATransaction.commit()
        
        UIView.animate(withDuration: 6 / 30) { [self] in
            if presenting {
                sendAmount.keyboard.alpha = 0
            } else {
            }
        }
        
        UIView.animate(withDuration: 6 / 30, delay: 6 / 30) { [self] in
            if presenting {
            } else {
                sendAmount.keyboard.alpha = 1
            }
        }
        
        UIView.animate(withDuration: 6 / 30, delay: 3 / 30) { [self] in
            sendAmount.cancelButton.alpha = presenting ? 0 : 1
        }
        
        UIView.animate(withDuration: 12 / 30) { [self] in
            send.messageParent.alpha = presenting ? 1 : 0
            send.feeView.alpha = presenting ? 1 : 0
        } completion: { [self] _ in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            
            send.view.backgroundColor = .background
            
            sendAmount.cancelButton.alpha = 1
            sendAmount.keyboard.transform = .identity
            sendAmount.keyboard.alpha = 1
            
            sendAmount.infoParent.alpha = 1
            sendAmount.input.alpha = 1
            sendAmount.sendButton.alpha = 1
            
            transitionContext.completeTransition(success)
        }
    }
}
