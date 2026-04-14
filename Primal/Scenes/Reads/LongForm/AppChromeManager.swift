//
//  AppChromeManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 31.5.24..
//

import UIKit

protocol AnimatedChromeController: UIViewController {
    var scrollView: UIScrollView { get }
}

class AppChromeManager: NSObject, UIScrollViewDelegate {
    weak var viewController: AnimatedChromeController?
    weak var extraTopView: UIView?
    weak var extraBottomView: UIView?
    
    init(
        viewController: AnimatedChromeController,
        extraTopView: UIView? = nil,
        extraBottomView: UIView? = nil,
        topBarHeight: CGFloat = 94,
        bottomBarHeight: CGFloat = 89
    ) {
        self.viewController = viewController
        self.extraTopView = extraTopView
        self.extraBottomView = extraBottomView
        self.topBarHeight = topBarHeight
        self.bottomBarHeight = bottomBarHeight
    }
    
    var topBarHeight: CGFloat
    var bottomBarHeight: CGFloat

    var prevPosition: CGFloat = 0
    var barsHidden: Bool = false

    func viewWillDisappear(_ animated: Bool) {
        if barsHidden {
            updateBarsHidden(false, animated: animated)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        let delta = newPosition - prevPosition
        prevPosition = newPosition

        if !scrollView.isTracking { return }

        if newPosition <= 0 {
            updateBarsHidden(false)
        } else if delta > 0 {
            updateBarsHidden(true)
        } else if delta < 0 {
            updateBarsHidden(false)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        updateBarsHidden(false)
        return true
    }

    /// Override point for subclasses. Applies the hidden/shown state to bars.
    func setBarsHidden(_ hidden: Bool, animated: Bool) {
        guard let controller = viewController else { return }

        let navTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: -topBarHeight) : .identity
        let tabTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: bottomBarHeight) : .identity

        let apply = { [self] in
            controller.navigationController?.navigationBar.transform = navTransform
            extraTopView?.transform = navTransform
            controller.mainTabBarController?.tabBarContainerView.transform = tabTransform
            extraBottomView?.transform = tabTransform
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: apply)
        } else {
            apply()
        }
    }

    func updateBarsHidden(_ hidden: Bool, animated: Bool = true) {
        guard barsHidden != hidden else { return }
        barsHidden = hidden
        setBarsHidden(hidden, animated: animated)
    }
}
