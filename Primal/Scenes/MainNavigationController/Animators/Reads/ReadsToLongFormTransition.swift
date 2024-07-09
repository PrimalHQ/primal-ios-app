//
//  ReadsToLongFormTransition.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.6.24..
//

import UIKit

class ReadsToLongFormTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    private let reads: ReadsViewController
    private let lfController: LongFormContentController
    
    init(reads: ReadsViewController, longFormController: LongFormContentController, presenting: Bool) {
        self.presenting = presenting
        self.reads = reads
        self.lfController = longFormController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 16 / 30 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }
        
        let container = transitionContext.containerView
        
        let background = UIView()
        background.backgroundColor = .background
        
        background.frame = toView.frame
        
        if presenting {
            container.addSubview(background)
            background.alpha = 0
            
            container.addSubview(toView)
            toView.layoutIfNeeded()
            toView.alpha = 0
        } else {
            container.insertSubview(toView, at: 0)
            container.insertSubview(background, at: 1)
        }
        
        var contentCell: LongFormContentCell?
        if let index = reads.posts.firstIndex(where: { $0.event.id == lfController.content.event.id }) {
            contentCell = reads.table.cellForRow(at: .init(row: index, section: 0)) as? LongFormContentCell
        }
        
        if presenting {
            contentCell?.avatar.animateTransitionTo(lfController.navExtension.profileIcon, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            contentCell?.titleLabel.animateTransitionTo(lfController.titleLabel, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            contentCell?.nameLabel.animateTransitionTo(lfController.navExtension.nameLabel, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            if lfController.imageView.superview != nil {
                contentCell?.contentImageView.animateTransitionTo(lfController.imageView, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            }
            
            UIView.animate(withDuration: 10 / 30) {
                toView.alpha = 1
                background.alpha = 1
            }
            
            lfController.navExtension.subscribeButton.transform = .init(translationX: 20, y: 0)
            lfController.dateLabel.transform = .init(translationX: 0, y: 20)
            lfController.navExtension.subscribeButton.alpha = 0
            lfController.dateLabel.alpha = 0
            
            UIView.animate(withDuration: 4 / 30, delay: 12 / 30) {
                self.lfController.navExtension.subscribeButton.transform = .identity
                self.lfController.dateLabel.transform = .identity
                self.lfController.navExtension.subscribeButton.alpha = 1
                self.lfController.dateLabel.alpha = 1
            }
            
            if let summary = lfController.summary {
                summary.transform = .init(translationX: 0, y: 10)
                summary.alpha = 0
                
                UIView.animate(withDuration: 4 / 30, delay: 9 / 30) {
                    summary.transform = .identity
                    summary.alpha = 1
                }
            }
            
            lfController.navExtension.secondaryLabel.alpha = 0
            let zapGallery = lfController.zapEmbededController.view
            zapGallery?.transform = .init(translationX: 0, y: 40)
            zapGallery?.alpha = 0
            lfController.contentParent.alpha = 0
            lfController.contentParent.transform = .init(translationX: 0, y: 40)
            
            UIView.animate(withDuration: 3.5 / 30, delay: 12 / 30) {
                zapGallery?.transform = .identity
                zapGallery?.alpha = 1
                self.lfController.navExtension.secondaryLabel.alpha = 1
            } 
        
            UIView.animate(withDuration: 4 / 30, delay: 12 / 30) {
                self.lfController.contentParent.alpha = 1
                self.lfController.contentParent.transform = .identity
            } completion: { _ in
                background.removeFromSuperview()
                
                contentCell?.avatar.alpha = 1
                contentCell?.titleLabel.alpha = 1
                contentCell?.nameLabel.alpha = 1
                contentCell?.contentImageView.alpha = 1
                
                let success = !transitionContext.transitionWasCancelled
                if !success {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        } else {
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
