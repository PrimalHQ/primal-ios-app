//
//  ArticleTransition.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.6.24..
//

import UIKit

protocol ArticleCellController: UIViewController {
    var articles: [Article] { get }
    var table: SafeTableView { get }
    var articleSection: Int { get }
}

class ArticleTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    private let listVC: ArticleCellController
    private let lfController: ArticleViewController
    
    init?(listVCs: [ArticleCellController], longFormController: ArticleViewController, presenting: Bool) {
        if !presenting && longFormController.scrollView.contentOffset.y > 500 {
            return nil
        }
        
        guard let listVC = listVCs.first(where: { vc in
            guard
                let index = vc.articles.firstIndex(where: { $0.event.id == longFormController.content.event.id }),
                let contentCell = vc.table.cellForRow(at: .init(row: index, section: vc.articleSection)) as? ArticleCell
            else { return false }
            
            let point = contentCell.contentView.convert(CGPoint.zero, to: longFormController.view)
            if point.x < -200 || point.x > 200 {
                return false
            }
            
            return true
        })
        else { return nil }
        
        self.presenting = presenting
        self.listVC = listVC
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
        
        var contentCell: ArticleCell?
        if let index = listVC.articles.firstIndex(where: { $0.event.id == lfController.content.event.id }) {
            contentCell = listVC.table.cellForRow(at: .init(row: index, section: listVC.articleSection)) as? ArticleCell
        }
        
        let topInfoView = lfController.topInfoView
        let contentViews = [lfController.contentStack, lfController.infoVC.view, lfController.commentsVC.view]
        let navButtons = [lfController.navExtension.followButton, lfController.navExtension.unfollowButton]
        
        if presenting {
            contentCell?.avatar.animateTransitionTo(lfController.navExtension.profileIcon, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            contentCell?.titleLabel.animateTransitionTo(topInfoView.titleLabel, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            contentCell?.nameLabel.animateTransitionTo(lfController.navExtension.nameLabel, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            
            if topInfoView.imageView.isHidden, lfController.content.image?.isEmpty == false, let image = contentCell?.contentImageView.image {
                topInfoView.imageView.image = image
                topInfoView.imageView.isHidden = false
                let hC = topInfoView.imageView.widthAnchor.constraint(equalTo: topInfoView.imageView.heightAnchor, multiplier: image.size.width / image.size.height)
                hC.isActive = true
                hC.priority = .defaultHigh
                lfController.view.layoutIfNeeded()
            }
            
            if !topInfoView.imageView.isHidden {
                contentCell?.contentImageView.animateTransitionTo(topInfoView.imageView, duration: 16 / 30, in: container, timing: .postsEaseInOut)
            }
            
            UIView.animate(withDuration: 10 / 30) {
                toView.alpha = 1
                background.alpha = 1
            }
            
            navButtons.forEach { $0.transform = .init(translationX: 20, y: 0) }
            topInfoView.dateLabel.transform = .init(translationX: 0, y: 20)
            navButtons.forEach { $0.alpha = 0 }
            topInfoView.dateLabel.alpha = 0
            
            UIView.animate(withDuration: 4 / 30, delay: 12 / 30) {
                navButtons.forEach { $0.transform = .identity }
                topInfoView.dateLabel.transform = .identity
                navButtons.forEach { $0.alpha = 1 }
                topInfoView.dateLabel.alpha = 1
            }
            
            let summary = lfController.topInfoView.summary
            summary.transform = .init(translationX: 0, y: 10)
            summary.alpha = 0
                
            UIView.animate(withDuration: 4 / 30, delay: 9 / 30) {
                summary.transform = .identity
                summary.alpha = 1
            }
            
            lfController.navExtension.secondaryLabel.alpha = 0
            let zapGallery = topInfoView.zapEmbededController.view
            zapGallery?.transform = .init(translationX: 0, y: 40)
            zapGallery?.alpha = 0
            
            contentViews.forEach {
                $0?.alpha = 0
                $0?.transform = .init(translationX: 0, y: 40)
            }
            
            UIView.animate(withDuration: 3.5 / 30, delay: 12 / 30) {
                zapGallery?.transform = .identity
                zapGallery?.alpha = 1
                self.lfController.navExtension.secondaryLabel.alpha = 1
            } 
        
            UIView.animate(withDuration: 4 / 30, delay: 12 / 30) {
                contentViews.forEach {
                    $0?.alpha = 1
                    $0?.transform = .identity
                }
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
            if let contentCell {
                lfController.navExtension.profileIcon.isHidden = true
                lfController.navExtension.profileIcon.animatedImageView.animateTransitionTo(contentCell.avatar.animatedImageView, duration: 16 / 30, in: container, timing: .postsEaseInOut)
                topInfoView.titleLabel.animateTransitionTo(contentCell.titleLabel, duration: 16 / 30, in: container, timing: .postsEaseInOut)
                lfController.navExtension.nameLabel.animateTransitionTo(contentCell.nameLabel, duration: 16 / 30, in: container, timing: .postsEaseInOut)
                if !topInfoView.imageView.isHidden {
                    topInfoView.imageView.animateTransitionTo(contentCell.contentImageView, duration: 16 / 30, in: container, timing: .postsEaseInOut)
                }
            }
            
            UIView.animate(withDuration: 10 / 30) {
                toView.alpha = 1
                background.alpha = 1
            }
            
            UIView.animate(withDuration: 4 / 30, delay: 12 / 30) {
                navButtons.forEach { $0.transform = .init(translationX: 20, y: 0) }
                topInfoView.dateLabel.transform = .init(translationX: 0, y: 20)
                navButtons.forEach { $0.alpha = 0 }
                topInfoView.dateLabel.alpha = 0
            }
            
            let summary = topInfoView.summary
            UIView.animate(withDuration: 4 / 30, delay: 9 / 30) {
                summary.transform = .init(translationX: 0, y: 10)
                summary.alpha = 0
            }
            
            let zapGallery = topInfoView.zapEmbededController.view
            
            UIView.animate(withDuration: 3.5 / 30, delay: 12 / 30) {
                zapGallery?.transform = .init(translationX: 0, y: 40)
                zapGallery?.alpha = 0
                contentViews.forEach {
                    $0?.alpha = 0
                    $0?.transform = .init(translationX: 0, y: 40)
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
