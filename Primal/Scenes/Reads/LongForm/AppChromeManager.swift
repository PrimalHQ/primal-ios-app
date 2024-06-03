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
    
    init(viewController: AnimatedChromeController, extraTopView: UIView? = nil) {
        self.viewController = viewController
        self.extraTopView = extraTopView
    }
    
    var topBarHeight: CGFloat {
        RootViewController.instance.view.safeAreaInsets.top + 55 + (extraTopView?.frame.height ?? 0)
    }
    var barsMaxTransform: CGFloat { topBarHeight }
    var prevPosition: CGFloat = 0
    var prevTransform: CGFloat = 0
    
    func viewWillDisappear(_ animated: Bool) {
        if animated {
            if prevTransform != 0 {
                animateBarsToVisible()
            }
        } else {
            if prevTransform != 0 {
                setBarsToTransform(0)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        let delta = newPosition - prevPosition
        prevPosition = newPosition
        
        if !scrollView.isTracking { return }
        
        let theoreticalNewTransform = (prevTransform - delta).clamped(to: -barsMaxTransform...0)
        let newTransform = newPosition <= -topBarHeight ? 0 : theoreticalNewTransform
        
        setBarsToTransform(newTransform)
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
    
    func setBarsToTransform(_ transform: CGFloat) {
        guard let controller = viewController else { return }
        prevTransform = transform
        controller.navigationController?.navigationBar.transform = .init(translationX: 0, y: transform)
        extraTopView?.transform = .init(translationX: 0, y: transform)
        controller.mainTabBarController?.vStack.transform = .init(translationX: 0, y: -transform)
    }
    
    func animateBarsToTransform(_ transform: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.setBarsToTransform(transform)
        }
    }
    
    func animateBarsToVisible() {
        animateBarsToTransform(0)
    }
    
    func animateBarsToInvisible() {
        animateBarsToTransform(-barsMaxTransform)
    }
    
    func setBarsDependingOnPosition() {
        guard let scrollView = viewController?.scrollView else { return }
        if prevTransform < -(barsMaxTransform / 2) && scrollView.contentOffset.y > 0 {
            animateBarsToInvisible()
        } else {
            animateBarsToVisible()
        }
    }
}
