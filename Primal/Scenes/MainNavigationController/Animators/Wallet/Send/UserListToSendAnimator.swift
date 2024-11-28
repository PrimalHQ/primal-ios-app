//
//  UserListToSendAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.1.24..
//

import UIKit

final class UserListToSendAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let userList: WalletPickUserController
    let sendController: WalletSendAmountController
    let isPresenting: Bool
    
    init(userListController: WalletPickUserController, sendController: WalletSendAmountController, isPresenting: Bool) {
        userList = userListController
        self.sendController = sendController
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 18 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }
        
        let container = transitionContext.containerView
        
        let background = UIView()
        background.backgroundColor = .background
        
        background.frame = toView.frame
        
        if isPresenting {
            container.addSubview(background)
            background.alpha = 0
            
            container.addSubview(toView)
            toView.layoutIfNeeded()
            toView.alpha = 0
        } else {
            container.insertSubview(toView, at: 0)
            container.insertSubview(background, at: 1)
        }
        
        var userCell: UserInfoTableCell?
        if let user = sendController.destination.user, let index = userList.users.firstIndex(where: { $0.data.pubkey == user.data.pubkey }) {
            userCell = userList.userTable.cellForRow(at: .init(row: index, section: 0)) as? UserInfoTableCell
        }
        
        if isPresenting {
            userCell?.profileIcon.animateTransitionTo(sendController.profilePictureView, duration: 18 / 30, in: container)
            userCell?.nameLabel.animateTransitionTo(sendController.nameLabel, duration: 18 / 30, in: container)
            userCell?.secondaryLabel.animateTransitionTo(sendController.nipLabel, duration: 18 / 30, in: container)
            
            UIView.animate(withDuration: 8 / 30) {
                background.alpha = 1
            }
            
            UIView.animate(withDuration: 10 / 30, delay: 8 / 30) {
                toView.alpha = 1
            } completion: { _ in
                background.removeFromSuperview()
                
                userCell?.profileIcon.alpha = 1
                userCell?.nameLabel.alpha = 1
                userCell?.secondaryLabel.alpha = 1
                
                let success = !transitionContext.transitionWasCancelled
                if !success {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        } else {
            sendController.profilePictureView.animateTransitionTo(userCell?.profileIcon, duration: 18 / 30, in: container)
            sendController.nameLabel.animateTransitionTo(userCell?.nameLabel, duration: 18 / 30, in: container)
            sendController.nipLabel.animateTransitionTo(userCell?.secondaryLabel, duration: 18 / 30, in: container)
            
            UIView.animate(withDuration: 10 / 30) {
                fromView.alpha = 0
            }
            
            UIView.animate(withDuration: 8 / 30, delay: 10 / 30) {
                background.alpha = 0
            } completion: { _ in
                background.removeFromSuperview()
                
                let success = !transitionContext.transitionWasCancelled
                if !success {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        }
    }
}
