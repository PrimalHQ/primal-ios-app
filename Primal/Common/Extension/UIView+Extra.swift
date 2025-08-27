//
//  UIView+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI

extension UIView {
    func takeScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    @discardableResult
    func dropShadow(scale: Bool = true) -> Self {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .init(width: 0, height: 3)
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        return self
    }

    func findAllSubviews<T>() -> [T] {
        var result = [T]()

        if let t = self as? T {
            result.append(t)
        }
        
        for subview in subviews {
            result += subview.findAllSubviews()
        }
        
        return result
    }
    
    func originDistanceVectorToView(_ view: UIView) -> CGPoint {
        let myCenter = superview?.convert(frame.origin, to: nil) ?? frame.origin
        let otherCenter = view.superview?.convert(view.frame.origin, to: nil) ?? view.frame.origin
        return CGPoint(x: otherCenter.x - myCenter.x, y: otherCenter.y - myCenter.y)
    }
    
    func centerDistanceVectorToView(_ view: UIView) -> CGPoint {
        let myCenter = superview?.convert(center, to: nil) ?? center
        let otherCenter = view.superview?.convert(view.center, to: nil) ?? view.center
        return CGPoint(x: otherCenter.x - myCenter.x, y: otherCenter.y - myCenter.y)
    }
    
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
    
    func resetAnchorPoint() {
        setAnchorPoint(.init(x: 0.5, y: 0.5))
    }
    
    // MARK: -- Simple Animations
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
    
    func pulse() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 2
        animation.values = [1.0, 1.02, 0.99, 1.0]
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "pulse")
    }
    
    func startPulsing() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.toValue = 1.07
        pulseAnimation.fromValue = 1.0
        pulseAnimation.duration = 0.8
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.isRemovedOnCompletion = false

        // Optional: Add slight opacity pulse too
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.8
        opacityAnimation.duration = 0.8
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.isRemovedOnCompletion = false

        layer.add(pulseAnimation, forKey: "pulse")
        layer.add(opacityAnimation, forKey: "pulseOpacity")
    }
    
    func stopPulsing() {
        layer.removeAnimation(forKey: "pulse")
        layer.removeAnimation(forKey: "pulseOpacity")
        layer.removeAnimation(forKey: "pulseXY")
    }
    
    // MARK: - Constraints
    
    @discardableResult
    func centerToSuperview(axis: Axis.Set = [.horizontal, .vertical], offset: CGFloat = 0) -> Self {
        guard let superview else { return self }
        return centerToView(superview, axis: axis, offset: offset)
    }
    
    @discardableResult
    func pinToSuperview(edges: Edge.Set = .all, padding: CGFloat = 0, safeArea: Bool = false) -> Self {
        guard let superview else { return self }
        return pin(to: superview, edges: edges, padding: padding, safeArea: safeArea)
    }
    
    @discardableResult
    func constrainToSize(_ size: CGFloat) -> Self {
        constrainToSize(width: size, height: size)
    }
    
    @discardableResult
    func constrainToAspect(_ aspect: CGFloat, priority: UILayoutPriority = .defaultHigh) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        let aspectC = widthAnchor.constraint(equalTo: heightAnchor, multiplier: aspect)
        aspectC.priority = priority
        aspectC.isActive = true
        return self
    }
    
    @discardableResult
    func pin(to view: UIView, edges: Edge.Set = .all, padding: CGFloat = 0, safeArea: Bool = false) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        if edges.contains(.top) {
            topAnchor.constraint(
                equalTo: safeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor,
                constant: padding
            ).isActive = true
        }
        if edges.contains(.bottom) {
            bottomAnchor.constraint(
                equalTo: safeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor,
                constant: -padding
            ).isActive = true
        }
        if edges.contains(.leading) {
            leadingAnchor.constraint(
                equalTo: safeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor,
                constant: padding
            ).isActive = true
        }
        if edges.contains(.trailing) {
            trailingAnchor.constraint(
                equalTo: safeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor,
                constant: -padding
            ).isActive = true
        }
        return self
    }
    
    @discardableResult
    func centerToView(_ view: UIView, axis: Axis.Set = [.horizontal, .vertical], offset: CGFloat = 0) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        if axis.contains(.vertical) {
            centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset).isActive = true
        }
        if axis.contains(.horizontal) {
            centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset).isActive = true
        }
        return self
    }
    
    @discardableResult
    func constrainToSize(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        return self
    }
}
