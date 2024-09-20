//
//  DropdownNavigationView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.8.24..
//

import UIKit

class DropdownNavigationView: UIView, Themeable {
    var title: String {
        didSet {
            updateTheme()
        }
    }
    
    let button = UIButton()
    
    weak var transitionView: UIView?
    var transitionConstraint: NSLayoutConstraint?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        updateTheme()
        
        addSubview(button)
        button.pinToSuperview(edges: .vertical).centerToSuperview()
        let leadingC = button.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingC.priority = .required
        leadingC.isActive = true
        
        button.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 135).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        button.configuration = .navChevronButton(title: title)
    }
    
    func startTransition(left: Bool, newTitle: String) {
        transitionView?.removeFromSuperview()
        
        let view = UIView()
        view.backgroundColor = .background
        view.clipsToBounds = true
        addSubview(view)
        view.pinToSuperview(edges: .vertical).pinToSuperview(/*to: button, */edges: left ? .leading : .trailing)
        transitionView = view
        transitionConstraint = view.widthAnchor.constraint(equalToConstant: 0)
        transitionConstraint?.isActive = true
        
        let transButton = UIButton(configuration: .navChevronButton(title: newTitle))
        view.addSubview(transButton)
        transButton.pinToSuperview(edges: .vertical).centerToView(button)
        transButton.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 135).isActive = true
        if newTitle.count > title.count {
            let leadingC = transButton.leadingAnchor.constraint(equalTo: leadingAnchor)
            leadingC.priority = .defaultHigh
            leadingC.isActive = true
        }
        
        let border = UIView()
        border.backgroundColor = .background
        view.addSubview(border)
        border
            .pinToSuperview(edges: .vertical).constrainToSize(width: 12)
            .pinToSuperview(edges: left ? .trailing : .leading)
    }
    
    func updateTransition(percent: CGFloat) {
        transitionConstraint?.constant = (frame.width + 12) * percent.clamped(to: 0...1)
    }
    
    func cancelTransition() {
        transitionConstraint?.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    func completeTransitionAnimated(newTitle: String) {
        transitionConstraint?.constant = (frame.width + 12)
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.transitionView?.removeFromSuperview()
            self.title = newTitle
        }
    }
    
    func completeTransition(newTitle: String) {
        transitionView?.removeFromSuperview()
        title = newTitle
    }
}

protocol DropdownNavigationViewGestureController: UIViewController {
    var pageVC: UIPageViewController { get }
    var navTitleView: DropdownNavigationView { get }
    
    func feedNameLeftOfCurrentFeed() -> String?
    func feedNameRightOfCurrentFeed() -> String?
}

class DropdownNavigationViewGesture: UIPanGestureRecognizer {
    weak var vc: DropdownNavigationViewGestureController?
    
    var oldTransition: (left: Bool, String)?
    
    init(vc: DropdownNavigationViewGestureController) {
        self.vc = vc
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
        delegate = self
    }

    @objc private func execute() {
        guard let pageVC = vc?.pageVC, let navTitleView = vc?.navTitleView else { return }
        
        if let scroll: UIScrollView = pageVC.view.findAllSubviews().first, scroll.contentOffset.x == scroll.frame.width {
            return
        }
        
        let x = translation(in: view).x
        let left = x > 0
        
        guard let transitionFeedName = left ? vc?.feedNameLeftOfCurrentFeed() : vc?.feedNameRightOfCurrentFeed() else { return }
        
        if let oldTransition, oldTransition.left == left && oldTransition.1 == transitionFeedName {
            // Do Nothing
        } else {
            self.oldTransition = (left, transitionFeedName)
            navTitleView.startTransition(left: left, newTitle: transitionFeedName)
        }
        
        switch state {
        case .possible, .began, .changed:
            navTitleView.updateTransition(percent: abs(x) / pageVC.view.frame.width)
        case .ended, .cancelled, .failed:
            let velocity = velocity(in: view).x
            
            let halfWidth = pageVC.view.frame.width / 2
            
            if (velocity > 300 && x > 0) || (velocity < -300 && x < 0) || (velocity < 200 && x < -halfWidth) || (velocity > -200 && x > halfWidth) {
                navTitleView.completeTransitionAnimated(newTitle: transitionFeedName)
            } else {
                navTitleView.cancelTransition()
            }
        @unknown default:
            break
        }
    }
}

extension DropdownNavigationViewGesture: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, abs(pan.translation(in: view).y) >= 0.01 {
            return false
        }
        
        return true
    }
}
