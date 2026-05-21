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
    var prevDelta: CGFloat = 0
    var accumulatedDelta: CGFloat = 0
    var barsHidden: Bool = false

    func viewWillDisappear(_ animated: Bool) {
        if barsHidden {
            updateBarsHidden(false, animated: animated)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        let delta = newPosition - prevPosition
        defer {
            prevPosition = newPosition
            prevDelta = delta
        }

        // Ignore large system-driven jumps (layout changes, inset adjustments).
        if abs(delta) > 100 || (delta.sign != prevDelta.sign && prevDelta != 0) {
            return
        }

        // Only react to user-driven scrolls — content insertions / programmatic scrolls fire
        // scrollViewDidScroll with deltas that would otherwise toggle the chrome incorrectly.
        guard scrollView.isDragging || scrollView.isDecelerating else { return }

        if newPosition < extraTopView?.frame.height ?? 0 && delta > 0 {
            // NO OP because we don't want to hide the header if we over-scrolled on top
        } else {
            accumulatedDelta += delta
        }
        
        if !barsHidden && accumulatedDelta < 0 {
            accumulatedDelta = 0
        }

        let threshold: CGFloat = 80
        if accumulatedDelta < -threshold {
            updateBarsHidden(false)
            accumulatedDelta = 0
        } else if accumulatedDelta > threshold {
            updateBarsHidden(true)
            accumulatedDelta = 0
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
        let tabBar = controller.mainTabBarController
        let tabTransform = tabBar?.targetTransformForTabBarState(hidden: hidden, excited: tabBar?.isExcited ?? false) ?? .identity
        let extraBottomTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: bottomBarHeight) : .identity

        let apply = { [self] in
            controller.navigationController?.navigationBar.transform = navTransform
            extraTopView?.transform = navTransform
            tabBar?.tabBarContainerView.transform = tabTransform
            extraBottomView?.transform = extraBottomTransform
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
