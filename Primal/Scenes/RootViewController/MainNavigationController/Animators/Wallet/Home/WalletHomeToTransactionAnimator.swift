//
//  WalletHomeToTransactionAnimator.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.2.24..
//

import UIKit

final class WalletHomeToTransactionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let home: WalletHomeViewController
    let transactionController: TransactionViewController
    let isPresenting: Bool
    
    init(home: WalletHomeViewController, transactionController: TransactionViewController, isPresenting: Bool) {
        self.home = home
        self.transactionController = transactionController
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
            toView.layoutIfNeeded()
            container.insertSubview(background, at: 1)
        }
        
        var cell: TransactionCell?
        if let index = home.selectedIndexPath {
            cell = home.table.cellForRow(at: index) as? TransactionCell
        }
        
        var infoCell: TransactionUserInfoCell?
        if let index = transactionController.cells.firstIndex(where: { $0.isMainInfoCell }) {
            infoCell = transactionController.table.cellForRow(at: .init(row: index, section: 0)) as? TransactionUserInfoCell
        }
        
        var amountCell: TransactionAmountCell?
        if let index = transactionController.cells.firstIndex(where: { $0.isAmountCell }) {
            amountCell = transactionController.table.cellForRow(at: .init(row: index, section: 0)) as? TransactionAmountCell
        }
        
        UIView.animate(withDuration: 2 / 30) {
            amountCell?.visibleLabel.alpha = 0.01
        }
        
        if isPresenting {
            if let infoCell {
                cell?.profileImage.animateTransitionTo(infoCell.avatar, duration: 18 / 30, in: container)
                
                if cell?.nameLabel.text == infoCell.mainLabel.text {
                    cell?.nameLabel.animateTransitionTo(infoCell.mainLabel, duration: 18 / 30, in: container)
                }
                
                if infoCell.messageLabel.text?.isEmpty == false {
                    cell?.messageLabel.animateTransitionTo(infoCell.messageLabel, duration: 18 / 30, in: container)
                }
            }
            
            if let amountCell {
                cell?.amountLabel.animateTransitionTo(amountCell.label, duration: 18 / 30, in: container)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                    let otherAnimatingLabel = UILabel()
                    if let attributedText = amountCell.label.attributedText {
                        otherAnimatingLabel.attributedText = attributedText
                    } else {
                        otherAnimatingLabel.text = amountCell.label.text
                        otherAnimatingLabel.font = amountCell.label.font
                        otherAnimatingLabel.textColor = amountCell.label.textColor
                    }
                    otherAnimatingLabel.textAlignment = amountCell.label.textAlignment
                    otherAnimatingLabel.numberOfLines = amountCell.label.numberOfLines
                    otherAnimatingLabel.anchorPoint = .zero //init(x: 0, y: 1)
                    otherAnimatingLabel.frame = amountCell.label.convert(amountCell.label.bounds, to: container)
                    
                    container.addSubview(otherAnimatingLabel)
                    
                    UIView.animate(withDuration: 4 / 30, delay: 0.3) {
                        amountCell.visibleLabel.alpha = 1
                        otherAnimatingLabel.alpha = 0.5
                    } completion: { _ in
                        otherAnimatingLabel.removeFromSuperview()
                    }
                }
            }
            
            UIView.animate(withDuration: 8 / 30) {
                background.alpha = 1
            }
            
            UIView.animate(withDuration: 10 / 30, delay: 8 / 30) {
                toView.alpha = 1
            } completion: { _ in
                background.removeFromSuperview()
                
                cell?.profileImage.alpha = 1
                cell?.nameLabel.alpha = 1
                cell?.messageLabel.alpha = 1
                cell?.amountLabel.alpha = 1
                
                self.transactionController.didFinishAppear = true
                
                let success = !transitionContext.transitionWasCancelled
                if !success {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        } else {
            if let cell {
                infoCell?.avatar.animateTransitionTo(cell.profileImage, duration: 14 / 30, in: container)
                
                if cell.nameLabel.text == infoCell?.mainLabel.text {
                    infoCell?.mainLabel.animateTransitionTo(cell.nameLabel, duration: 14 / 30, in: container)
                }
                
                amountCell?.label.animateTransitionTo(cell.amountLabel, duration: 14 / 30, in: container)
                
                if infoCell?.messageLabel.text?.isEmpty == false {
                    infoCell?.messageLabel.animateTransitionTo(cell.messageLabel, duration: 14 / 30, in: container)
                }
            }
            
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
