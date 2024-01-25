//
//  ViewAnimations.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.1.24..
//

import UIKit

extension CAMediaTimingFunction {
    static let easeInOutQuart = CAMediaTimingFunction(controlPoints: 0.76, 0, 0.24, 1)
}

extension UILabel {
    @discardableResult
    func animateTransitionTo(_ otherLabel: UILabel, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart) -> UILabel {
        alpha = 0.01
        otherLabel.alpha = 0.01
        
        let animatingLabel = UILabel()
        animatingLabel.text = text
        animatingLabel.font = font
        animatingLabel.textColor = textColor
        animatingLabel.textAlignment = textAlignment
        animatingLabel.numberOfLines = numberOfLines
        animatingLabel.frame = convert(bounds, to: root)
        root.addSubview(animatingLabel)
        
        let actionTranslation = animatingLabel.centerDistanceVectorToView(otherLabel)
        let scale: CGFloat
        if animatingLabel.frame.height > otherLabel.frame.height {
            scale = min(otherLabel.frame.width / animatingLabel.frame.width, otherLabel.frame.height / animatingLabel.frame.height)
        } else {
            scale = max(otherLabel.frame.width / animatingLabel.frame.width, otherLabel.frame.height / animatingLabel.frame.height)
        }
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)

        UIView.animate(withDuration: duration) {
            animatingLabel.transform = .init(translationX: actionTranslation.x, y: actionTranslation.y).scaledBy(x: scale, y: scale)
        } completion: { _ in
            otherLabel.alpha = 1
            animatingLabel.removeFromSuperview()
        }
        
        CATransaction.commit()
        
        return animatingLabel
    }
}

extension UIImageView {
    @discardableResult
    func animateTransitionTo(_ other: UIView?, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart) -> UIImageView? {
        guard let other else { return nil }
        alpha = 0.01
        other.alpha = 0.01
        
        let animatingIV = UIImageView()
        animatingIV.image = image
        animatingIV.tintColor = tintColor
        animatingIV.contentMode = contentMode
        animatingIV.layer.cornerRadius = layer.cornerRadius
        animatingIV.clipsToBounds = clipsToBounds
        animatingIV.frame = convert(bounds, to: root)
        root.addSubview(animatingIV)
        
        let actionTranslation = animatingIV.centerDistanceVectorToView(other)
        let scale: CGFloat
        if animatingIV.frame.width > other.frame.width {
            scale = min(other.frame.width / animatingIV.frame.width, other.frame.height / animatingIV.frame.height)
        } else {
            scale = max(other.frame.width / animatingIV.frame.width, other.frame.height / animatingIV.frame.height)
        }
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        
        UIView.animate(withDuration: duration) {
            animatingIV.transform = .init(translationX: actionTranslation.x, y: actionTranslation.y).scaledBy(x: scale, y: scale)
        } completion: { _ in
            other.alpha = 1
            animatingIV.removeFromSuperview()
        }
        
        CATransaction.commit()
        
        return animatingIV
    }
}

extension UIView {
    @discardableResult
    func animateViewTo(_ other: UIView?, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart) -> UIView? {
        guard let other else { return nil }
        
        alpha = 0.01
        other.alpha = 0.01
        
        let animating = UIView()
        animating.backgroundColor = backgroundColor
        animating.layer.cornerRadius = layer.cornerRadius
        animating.frame = convert(bounds, to: root)
        root.addSubview(animating)
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        
        UIView.animate(withDuration: duration) {
            animating.layer.cornerRadius = other.layer.cornerRadius
            animating.frame = other.convert(other.bounds, to: root)
        } completion: { _ in
            other.alpha = 1
            animating.removeFromSuperview()
        }
        
        CATransaction.commit()
        
        return animating
    }
    
    @discardableResult
    func animateViewTo(_ frame: CGRect, radius: CGFloat, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart) -> UIView? {
        alpha = 0.01
        
        let animating = UIView()
        animating.backgroundColor = backgroundColor
        animating.layer.cornerRadius = layer.cornerRadius
        animating.frame = convert(bounds, to: root)
        root.addSubview(animating)
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        
        UIView.animate(withDuration: duration) {
            animating.layer.cornerRadius = radius
            animating.frame = frame
        } completion: { _ in
            animating.removeFromSuperview()
        }
        
        CATransaction.commit()
        
        return animating
    }
}
