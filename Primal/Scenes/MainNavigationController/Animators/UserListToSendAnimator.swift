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
    init(userListController: WalletPickUserController, sendController: WalletSendAmountController) {
        userList = userListController
        self.sendController = sendController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 18 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let user = sendController.destination.user,
            let index = userList.users.firstIndex(where: { $0.data.pubkey == user.data.pubkey }),
            let userCell = userList.userTable.cellForRow(at: .init(row: index, section: 0)) as? UserInfoTableCell
        else { return }

        let container = transitionContext.containerView
        
        let background = UIView()
        background.backgroundColor = .background
        
        container.addSubview(background)
        background.frame = toView.frame
        background.alpha = 0
        
        container.addSubview(toView)
        toView.alpha = 0
        
        userCell.profileIcon.animateTransitionTo(sendController.profilePictureView, duration: 18 / 30, in: container)
        userCell.nameLabel.animateTransitionTo(sendController.nameLabel, duration: 18 / 30, in: container)
        userCell.secondaryLabel.animateTransitionTo(sendController.nipLabel, duration: 18 / 30, in: container)
        
        UIView.animate(withDuration: 8 / 30) {
            background.alpha = 1
        }
        
        UIView.animate(withDuration: 10 / 30, delay: 8 / 30) {
            toView.alpha = 1
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
