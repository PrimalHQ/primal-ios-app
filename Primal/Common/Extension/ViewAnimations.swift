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
    func animateTransitionTo(_ otherLabel: UILabel?, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart) -> UILabel? {
        guard let otherLabel else { return nil }
        
        alpha = 0.01
        otherLabel.alpha = 0.01
        
        let animatingLabel = UILabel()
        if let attributedText {
            animatingLabel.attributedText = attributedText
        } else {
            animatingLabel.text = text
            animatingLabel.font = font
            animatingLabel.textColor = textColor
        }
        animatingLabel.textAlignment = textAlignment
        animatingLabel.numberOfLines = numberOfLines
        animatingLabel.anchorPoint = (.zero)
        animatingLabel.frame = bounds
        animatingLabel.tintColor = tintColor
        
        let scale = otherLabel.font.pointSize / font.pointSize
        
        let otherAnimatingLabel = UILabel()
        if let attributedText = otherLabel.attributedText {
            otherAnimatingLabel.attributedText = attributedText
        } else {
            otherAnimatingLabel.text = otherLabel.text
            otherAnimatingLabel.font = otherLabel.font
            otherAnimatingLabel.textColor = otherLabel.textColor
        }
        otherAnimatingLabel.textAlignment = otherLabel.textAlignment
        otherAnimatingLabel.numberOfLines = otherLabel.numberOfLines
        otherAnimatingLabel.anchorPoint = .zero //init(x: 0, y: 1)
        otherAnimatingLabel.frame = otherLabel.bounds
        otherAnimatingLabel.alpha = 0
        otherAnimatingLabel.transform = .init(scaleX: 1 / scale, y: 1 / scale)
        otherAnimatingLabel.tintColor = otherLabel.tintColor
        
        let parent = UIView()
        parent.clipsToBounds = true
        parent.frame = convert(bounds, to: root)
        parent.addSubview(animatingLabel)
        parent.addSubview(otherAnimatingLabel)
        root.addSubview(parent)
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)

        UIView.animate(withDuration: duration) {
            animatingLabel.transform = .init(scaleX: scale, y: scale)
            otherAnimatingLabel.transform = .identity
            
            parent.frame = otherLabel.convert(otherLabel.bounds, to: root)
            
            animatingLabel.alpha = 0
            otherAnimatingLabel.alpha = 1
        } completion: { _ in
            otherLabel.alpha = 1
            parent.removeFromSuperview()
        }
        
        CATransaction.commit()
        
        return animatingLabel
    }
}

extension UIImageView {
    @discardableResult
    func animateTransitionTo(_ other: UIView?, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart, fade: Bool = false) -> UIImageView? {
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
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        
        UIView.animate(withDuration: duration) {
            animatingIV.tintColor = other.tintColor
            animatingIV.contentMode = other.contentMode
            animatingIV.layer.cornerRadius = other.layer.cornerRadius
            animatingIV.clipsToBounds = other.clipsToBounds
            animatingIV.frame = other.convert(other.bounds, to: root)
            if fade {
                animatingIV.alpha = 0
            }
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

extension UserImageView {
    @discardableResult
    func animateTransitionTo(_ other: UIView?, duration: TimeInterval, in root: UIView, timing: CAMediaTimingFunction = .easeInOutQuart, fade: Bool = false) -> UserImageView? {
        guard let other else { return nil }
        alpha = 0.01
        other.alpha = 0.01
        
        let scale = other.bounds.height / height
        let distance = centerDistanceVectorToView(other)
        
        let animatingIV = UserImageView(height: height)
        animatingIV.image = image
        animatingIV.contentMode = contentMode
        root.addSubview(animatingIV)
        animatingIV.centerToView(self)
        
        if let cachedLegendTheme {
            animatingIV.legendaryGradient.setLegendGradient(cachedLegendTheme)
            animatingIV.legendaryGradient.isHidden = false
        }
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        
        UIView.animate(withDuration: duration) {
            animatingIV.transform = .init(translationX: distance.x, y: distance.y).scaledBy(x: scale, y: scale)
            
            if fade {
                animatingIV.alpha = 0
            }
        } completion: { _ in
            other.alpha = 1
            animatingIV.removeFromSuperview()
        }
        
        CATransaction.commit()
        
        return animatingIV
    }
}
