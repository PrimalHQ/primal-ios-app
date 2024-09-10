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
    var prevTransformTop: CGFloat = 0
    var prevTransformBot: CGFloat = 0
    
    func viewWillDisappear(_ animated: Bool) {
        if animated {
            if prevTransformTop != 0 {
                animateBarsToVisible()
            }
        } else {
            if prevTransformTop != 0 {
                setBarsToTransform(0, 0)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        let delta = newPosition - prevPosition
        prevPosition = newPosition
        
        if !scrollView.isTracking { return }
        
        let theoreticalNewTransformTop = (prevTransformTop - delta).clamped(to: -topBarHeight...0)
        let newTransformTop = newPosition <= -topBarHeight ? 0 : theoreticalNewTransformTop
        
        let newTransformBot = (prevTransformBot - delta).clamped(to: -bottomBarHeight...0)
        setBarsToTransform(newTransformTop, newTransformBot)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < -0.1 {
            animateBarsToVisible()
        } else if velocity.y > 0.1 {
            animateBarsToInvisible()
        } else {
            setBarsDependingOnPosition()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setBarsDependingOnPosition()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        animateBarsToVisible()
        return true
    }
    
    func setBarsToTransform(_ topTransform: CGFloat, _ botTransform: CGFloat) {
        guard let controller = viewController else { return }
        prevTransformTop = topTransform
        prevTransformBot = botTransform
        
        let topTransform = max(topTransform, -topBarHeight)
        let botTransform = min(-botTransform, bottomBarHeight)
        
        controller.navigationController?.navigationBar.transform = .init(translationX: 0, y: topTransform)
        extraTopView?.transform = .init(translationX: 0, y: topTransform)
        controller.mainTabBarController?.vStack.transform = .init(translationX: 0, y: botTransform)
        extraBottomView?.transform = .init(translationX: 0, y: botTransform)
    }
    
    func animateBarsToTransform(_ transformTop: CGFloat, _ transformBot: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.setBarsToTransform(transformTop, transformBot)
        }
    }
    
    func animateBarsToVisible() {
        animateBarsToTransform(0, 0)
    }
    
    func animateBarsToInvisible() {
        animateBarsToTransform(-topBarHeight, -bottomBarHeight)
    }
    
    func setBarsDependingOnPosition() {
        guard let scrollView = viewController?.scrollView else { return }
        if prevTransformTop < -(topBarHeight / 2) && scrollView.contentOffset.y > 0 {
            animateBarsToInvisible()
        } else {
            animateBarsToVisible()
        }
    }
}
