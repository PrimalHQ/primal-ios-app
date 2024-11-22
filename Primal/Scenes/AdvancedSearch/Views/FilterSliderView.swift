//
//  FilterSliderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.24..
//

import UIKit

class FilterSliderView: UIControl {
    private let control = FilterSlidingControl()
    private let valueLabel = UILabel()
    
    @Published var currentValue: Int {
        didSet {
            updateView()
        }
    }
    
    let maxValue: Int
    
    init(title: String, maxValue: Int = 600, currentValue: Int = 0) {
        self.maxValue = maxValue
        self.currentValue = currentValue
        super.init(frame: .zero)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        titleLabel.textColor = .foreground2
        
        let labelParent = UIView()
        labelParent.addSubview(valueLabel)
        labelParent.constrainToSize(width: 60, height: 36)
        labelParent.backgroundColor = .background3
        labelParent.layer.cornerRadius = 18
        
        valueLabel.centerToSuperview(axis: .vertical).pinToSuperview(edges: .trailing, padding: 14)
        valueLabel.font = .appFont(withSize: 16, weight: .regular)
        valueLabel.textColor = .foreground
        
        let stack = UIStackView([control, labelParent])
        stack.spacing = 12
        
        let mainStack = UIStackView(axis: .vertical, [titleLabel, stack])
        mainStack.spacing = 8
        
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        control.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.currentValue = Int(control.value * CGFloat(maxValue))
        }), for: .valueChanged)
        
        updateView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateView() {
        valueLabel.text = "\(currentValue)"
        if Int(control.value * CGFloat(maxValue)) != currentValue {
            control.value = (CGFloat(currentValue) / CGFloat(maxValue))
        }
        
        if currentValue == 0 {
            valueLabel.textColor = .foreground5
        } else {
            valueLabel.textColor = .foreground
        }
    }
}

private class FilterSlidingControl: UIControl {
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
