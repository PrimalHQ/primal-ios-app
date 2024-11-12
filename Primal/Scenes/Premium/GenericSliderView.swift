//
//  GenericSliderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.11.24..
//

import UIKit

class GenericSliderView: UIControl {
    private let knob = UIView().constrainToSize(24)
    private let filledBar = UIView().constrainToSize(height: 4)
    private let path = UIView().constrainToSize(height: 4)
    
    private var knobConstraint: NSLayoutConstraint?
    
    var value: CGFloat = 0 {
        didSet {
            updateKnobConstraint()
            updateKnobColors()
        }
    }
    
    private var slidingWidth: CGFloat { frame.width - 24 }
    
    init() {
        super.init(frame: .zero)
        
        addSubview(path)
        path.pinToSuperview(edges: .horizontal).centerToSuperview(axis: .vertical)
        path.backgroundColor = .background3
        path.layer.cornerRadius = 2
        
        addSubview(filledBar)
        filledBar.pinToSuperview(edges: .leading).centerToSuperview(axis: .vertical)
        filledBar.layer.cornerRadius = 2
        
        addSubview(knob)
        knob.pinToSuperview(edges: .vertical, padding: 6)
        filledBar.rightAnchor.constraint(equalTo: knob.centerXAnchor).isActive = true
        knob.layer.cornerRadius = 12
        
        path.isUserInteractionEnabled = false
        filledBar.isUserInteractionEnabled = false
        knob.isUserInteractionEnabled = false
        
        updateKnobConstraint()
        updateKnobColors()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            let current = touch.location(in: self).x
            let prev = touch.previousLocation(in: self).x
            let delta = current - prev
            
            value = (value + (delta / slidingWidth)).clamped(to: 0...1)
            sendActions(for: .valueChanged)
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view as? UIScrollView != nil {
            return true
        }
        return false
    }
    
    func updateKnobColors() {
        if value == 0 {
            knob.backgroundColor = .foreground6
            filledBar.backgroundColor = .foreground6
            return
        }
        knob.backgroundColor = .foreground2
        filledBar.backgroundColor = .accent
    }

    func updateKnobConstraint() {
        if let knobConstraint {
            knobConstraint.isActive = false
            removeConstraint(knobConstraint)
        }
        
        let newC = NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: knob,
            attribute: .leading,
            multiplier: 1 / max(value, 0.0001),
            constant: 24
        )
        knobConstraint = newC
        addConstraint(newC)
    }
}
